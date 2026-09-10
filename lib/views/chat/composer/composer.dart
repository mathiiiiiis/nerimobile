import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:nerimobile/stores/channel/channel_store.dart';
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

const _fieldHeight = 48.0;
const _maxFieldLines = 6;
const _sendMorph = Duration(milliseconds: 150);
const _sendAppear = Duration(milliseconds: 200);
const _pressScale = 0.9;
const _sendGap = 4.0;
const _fieldRadius = _fieldHeight / 2;

class Composer extends ConsumerStatefulWidget {
  const Composer({super.key, required this.channelId});

  final String channelId;

  @override
  ConsumerState<Composer> createState() => _ComposerState();
}

class _ComposerState extends ConsumerState<Composer> {
  final _controller = TextEditingController();
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _canSend => _controller.text.trim().isNotEmpty && !_sending;

  Future<void> _send() async {
    if (!_canSend) return;

    final content = _controller.text.trim();
    _controller.clear();
    setState(() => _sending = true);

    await ref.read(messagesProvider(widget.channelId).notifier).send(content);
    if (mounted) setState(() => _sending = false);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.neri;
    final sizing = context.neriSize;
    final dual = NeriWindow.of(context).isDualPane;
    final radius = Radius.circular(sizing.radius(NeriRadiusRole.xl));

    return Container(
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
        bottom: !dual,
        child: Padding(
          padding: EdgeInsets.all(sizing.space(NeriSpacingRole.sm)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _ActionButton(
                icon: Symbols.add_rounded,
                //TODO: attachment menu
                onTap: () {},
              ),
              Expanded(
                child: _Field(
                  controller: _controller,
                  hint: _hint(ref, widget.channelId),
                ),
              ),
              _SendButton(visible: _canSend, onTap: _send),
            ],
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.controller, required this.hint});

  final TextEditingController controller;
  final String hint;

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
      child: TextField(
        controller: controller,
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
  const _SendButton({required this.visible, required this.onTap});

  final bool visible;
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
                    Symbols.send_rounded,
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
