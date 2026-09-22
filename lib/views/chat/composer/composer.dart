import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:nerimobile/models/message.dart';
import 'package:nerimobile/stores/channel/channel_store.dart';
import 'package:nerimobile/stores/composer/composer_store.dart';
import 'package:nerimobile/stores/inbox/inbox_store.dart';

import 'package:nerimobile/stores/message/message_store.dart';
import 'package:nerimobile/theme/core/theme_data.dart';
import 'package:nerimobile/theme/core/token.dart';
import 'package:nerimobile/theme/sizing/border.dart';
import 'package:nerimobile/theme/sizing/breakpoints.dart';
import 'package:nerimobile/theme/sizing/dimens.dart';
import 'package:nerimobile/theme/sizing/radius.dart';
import 'package:nerimobile/theme/sizing/spacing.dart';
import 'package:nerimobile/theme/typography/text_styles.dart';
import 'package:nerimobile/views/chat/composer/attachment_panel.dart';
import 'package:nerimobile/views/chat/composer/composer_bar.dart';
import 'package:nerimobile/views/chat/composer/emoji_panel.dart';
import 'package:nerimobile/views/chat/composer/typing_indicator.dart';
import 'package:nerimobile/views/chat/file_too_large_dialog.dart';

const _fieldHeight = 48.0;
const _maxFieldLines = 6;
const _sendMorph = Duration(milliseconds: 150);
const _sendAppear = Duration(milliseconds: 200);
const _pressScale = 0.9;
const _sendGap = 4.0;
const _fieldRadius = _fieldHeight / 2;

class Composer extends ConsumerStatefulWidget {
  const Composer({super.key, required this.channelId, this.bottomInset = 0});

  final String channelId;
  //system inset not covered by attachment panel
  final double bottomInset;

  @override
  ConsumerState<Composer> createState() => _ComposerState();
}

class _ComposerState extends ConsumerState<Composer>
    with WidgetsBindingObserver {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  bool _sending = false;
  String? _draft;
  double _keyboardHeight = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller.addListener(_onChanged);
  }

  //system keyboard dismissal doesnt clear focus
  @override
  void didChangeMetrics() {
    final height = View.of(context).viewInsets.bottom;
    if (height == 0 && _keyboardHeight > 0) _focus.unfocus();
    _keyboardHeight = height;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  bool get _canSend {
    if (_sending) return false;
    if (_controller.text.trim().isNotEmpty) return true;

    final composer = ref.read(composerProvider(widget.channelId));
    return composer.editing == null && composer.attachment != null;
  }

  void _togglePicker() {
    final picker = ref.read(
      attachmentPickerProvider(widget.channelId).notifier,
    );
    ref.read(emojiPaneProvider(widget.channelId).notifier).close();

    //unfocus to reveal the panel above the keyboard
    if (_focus.hasFocus) {
      _focus.unfocus();
      picker.collapse();
    } else {
      picker.toggle();
    }
  }

  void _toggleEmojis() {
    final emojis = ref.read(emojiPaneProvider(widget.channelId).notifier);
    ref.read(attachmentPickerProvider(widget.channelId).notifier).close();

    if (_focus.hasFocus) {
      _focus.unfocus();
      emojis.open();
    } else {
      emojis.toggle();
    }
  }

  void _onChanged() {
    setState(() {});
    if (_controller.text.isNotEmpty) {
      ref.read(composerProvider(widget.channelId).notifier).typing();
    }
  }

  Future<void> _send() async {
    if (!_canSend) return;

    final content = _controller.text.trim();
    final composer = ref.read(composerProvider(widget.channelId));
    if (composer.editing case final editing?) return _save(editing, content);

    _controller.clear();
    ref.read(composerProvider(widget.channelId).notifier)
      ..resetTyping()
      ..clearReplies()
      ..removeAttachment();
    setState(() => _sending = true);

    final failure = await ref
        .read(messagesProvider(widget.channelId).notifier)
        .send(
          content,
          replyTo: [for (final m in composer.replyTo) PartialMessage.of(m)],
          mentionReplies: composer.mentionReplies,
          file: composer.attachment?.path,
        );
    if (!mounted) return;

    setState(() => _sending = false);
    if (failure == SendFailure.fileTooLarge) showFileTooLargeDialog(context);
  }

  Future<void> _save(Message editing, String content) async {
    setState(() => _sending = true);
    final saved = await ref
        .read(messagesProvider(widget.channelId).notifier)
        .edit(editing.id, content);
    if (!mounted) return;

    setState(() => _sending = false);
    final current = ref.read(composerProvider(widget.channelId)).editing;
    if (!saved || current?.id != editing.id) return;
    ref.read(composerProvider(widget.channelId).notifier).cancelEdit();
  }

  void _startEdit(Message message, {required bool fromDraft}) {
    if (fromDraft) _draft = _controller.text;
    _controller.value = TextEditingValue(
      text: message.content,
      selection: TextSelection.collapsed(offset: message.content.length),
    );
    _focus.requestFocus();
  }

  void _endEdit() {
    _controller.text = _draft ?? '';
    _draft = null;
  }

  void _insert(String text) {
    final value = _controller.value;
    final selection = value.selection.isValid
        ? value.selection
        : TextSelection.collapsed(offset: value.text.length);

    _controller.value = value.replaced(selection, text);
    if (ref.read(emojiPaneProvider(widget.channelId)) == EmojiPane.closed) {
      _focus.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.neri;
    final sizing = context.neriSize;
    final dual = NeriWindow.of(context).isDualPane;
    final radius = Radius.circular(sizing.radius(NeriRadiusRole.xl));

    ref.listen(
      composerProvider(widget.channelId).select((c) => c.replyTo.length),
      (previous, next) {
        if (next > (previous ?? 0)) _focus.requestFocus();
      },
    );
    ref.listen(composerProvider(widget.channelId).select((c) => c.editing), (
      previous,
      next,
    ) {
      if (next == null) return _endEdit();
      if (next.id == previous?.id) return;
      _startEdit(next, fromDraft: previous == null);
    });
    ref.listen(
      composerProvider(widget.channelId).select((c) => c.sendRequests),
      (_, _) => _send(),
    );
    ref.listen(
      composerProvider(widget.channelId).select((c) => c.pendingInsert),
      (_, next) {
        if (next == null) return;
        final text = ref
            .read(composerProvider(widget.channelId).notifier)
            .takeInsert();
        if (text != null) _insert(text);
      },
    );

    final editing = ref.watch(
      composerProvider(widget.channelId).select((c) => c.editing != null),
    );
    ref.watch(
      composerProvider(widget.channelId).select((c) => c.attachment != null),
    );
    final picker = ref.watch(attachmentPickerProvider(widget.channelId));
    final emojis =
        ref.watch(emojiPaneProvider(widget.channelId)) != EmojiPane.closed;
    final picking = picker.open;

    return PopScope(
      canPop: !editing && !picking && !emojis,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;

        final notifier = ref.read(
          attachmentPickerProvider(widget.channelId).notifier,
        );
        if (emojis) {
          return ref.read(emojiPaneProvider(widget.channelId).notifier).close();
        }
        if (picker.expanded) return notifier.collapse();
        if (picking) return notifier.close();

        ref.read(composerProvider(widget.channelId).notifier).cancelEdit();
      },
      child: Container(
        margin: dual
            ? EdgeInsets.all(sizing.space(NeriSpacingRole.sm))
            : EdgeInsets.zero,
        decoration: BoxDecoration(
          color: colors[NeriToken.pane],
          borderRadius: dual
              ? BorderRadius.all(
                  Radius.circular(sizing.radius(NeriRadiusRole.image)),
                )
              : BorderRadius.only(topLeft: radius, topRight: radius),
          border: dual
              ? Border.all(
                  color: colors[NeriToken.border],
                  width: sizing.border(NeriBorderRole.hairline),
                )
              : null,
        ),
        child: SafeArea(
          top: false,
          bottom: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              sizing.space(NeriSpacingRole.sm),
              sizing.space(NeriSpacingRole.sm),
              sizing.space(NeriSpacingRole.sm),
              sizing.space(NeriSpacingRole.sm) +
                  (dual ? 0 : widget.bottomInset),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TypingIndicator(channelId: widget.channelId),
                TextFieldTapRegion(
                  child: ComposerBar(channelId: widget.channelId),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TextFieldTapRegion(
                      child: _ActionButton(
                        icon: Symbols.add_rounded,
                        onTap: _togglePicker,
                      ),
                    ),
                    Expanded(
                      child: TextFieldTapRegion(
                        child: _Field(
                          controller: _controller,
                          focusNode: _focus,
                          hint: _hint(ref, widget.channelId),
                          onEmojis: _toggleEmojis,
                        ),
                      ),
                    ),
                    TextFieldTapRegion(
                      child: _SendButton(
                        visible: _canSend,
                        icon: editing
                            ? Symbols.check_rounded
                            : Symbols.send_rounded,
                        onTap: _send,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.focusNode,
    required this.hint,
    required this.onEmojis,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final VoidCallback onEmojis;

  @override
  Widget build(BuildContext context) {
    final colors = context.neri;
    final sizing = context.neriSize;

    return Container(
      constraints: const BoxConstraints(minHeight: _fieldHeight),
      padding: EdgeInsets.symmetric(
        horizontal: sizing.space(NeriSpacingRole.lg),
        vertical: sizing.space(NeriSpacingRole.md),
      ),
      decoration: BoxDecoration(
        color: colors[NeriToken.chatInputBackground],
        borderRadius: BorderRadius.circular(_fieldRadius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        spacing: sizing.space(NeriSpacingRole.sm),
        children: [
          Expanded(child: _input(context)),
          GestureDetector(
            onTap: onEmojis,
            behavior: HitTestBehavior.opaque,
            child: Icon(
              Symbols.mood_rounded,
              size: sizing.dimen(NeriDimen.iconSm),
              color: colors[NeriToken.textSecondary],
            ),
          ),
        ],
      ),
    );
  }

  Widget _input(BuildContext context) {
    final colors = context.neri;

    return TextField(
      controller: controller,
      focusNode: focusNode,
      onTapOutside: (_) => focusNode.unfocus(),
      maxLines: _maxFieldLines,
      minLines: 1,
      textInputAction: TextInputAction.newline,
      keyboardType: TextInputType.multiline,
      cursorColor: colors[NeriToken.primary],
      style: context.neriText[NeriTextRole.bodyLarge].copyWith(
        color: colors[NeriToken.text],
      ),
      decoration: InputDecoration(
        isDense: true,
        isCollapsed: true,
        border: InputBorder.none,
        hintText: hint, //TODO: add l10n
        hintStyle: context.neriText[NeriTextRole.bodyLarge].copyWith(
          color: colors[NeriToken.textPlaceholder],
        ),
      ),
    );
  }
}

//TODO: add l10n
String _hint(WidgetRef ref, String channelId) {
  final recipient = ref.watch(inboxProvider)[channelId]?.recipient;
  if (recipient != null) return 'Message ${recipient.username}';

  final name = ref.watch(channelsProvider)[channelId]?.name;
  return name == null ? 'Message' : 'Message in #$name';
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.neri;
    final sizing = context.neriSize;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: _fieldHeight,
        height: _fieldHeight,
        child: Icon(
          icon,
          size: sizing.dimen(NeriDimen.iconMd),
          color: colors[NeriToken.textSecondary],
        ),
      ),
    );
  }
}

class _SendButton extends StatefulWidget {
  const _SendButton({
    required this.visible,
    required this.icon,
    required this.onTap,
  });

  final bool visible;
  final IconData icon;
  final VoidCallback onTap;

  @override
  State<_SendButton> createState() => _SendButtonState();
}

class _SendButtonState extends State<_SendButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.neri;
    final sizing = context.neriSize;

    return AnimatedSize(
      duration: _sendAppear,
      curve: Curves.easeOut,
      alignment: Alignment.centerLeft,
      child: SizedBox(
        width: widget.visible ? _fieldHeight + _sendGap : 0,
        height: _fieldHeight,
        child: ClipRRect(
          child: OverflowBox(
            alignment: Alignment.centerRight,
            minWidth: _fieldHeight,
            maxWidth: _fieldHeight,
            child: GestureDetector(
              onTap: widget.onTap,
              onTapDown: (_) => setState(() => _down = true),
              onTapUp: (_) => setState(() => _down = false),
              onTapCancel: () => setState(() => _down = false),
              child: AnimatedScale(
                scale: _down ? _pressScale : 1,
                duration: _sendMorph,
                curve: Curves.easeOut,
                child: AnimatedContainer(
                  width: _fieldHeight,
                  height: _fieldHeight,
                  duration: _sendMorph,
                  decoration: BoxDecoration(
                    color: colors[NeriToken.primary],
                    borderRadius: _down
                        ? sizing.rounded(NeriRadiusRole.full)
                        : sizing.rounded(NeriRadiusRole.xl),
                  ),
                  child: Icon(
                    widget.icon,
                    fill: 1,
                    size: sizing.dimen(NeriDimen.iconSm),
                    color: colors[NeriToken.text],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
