import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nerimobile/theme/core/theme_data.dart';
import 'package:nerimobile/theme/core/token.dart';
import 'package:nerimobile/theme/sizing/border.dart';
import 'package:nerimobile/theme/sizing/breakpoints.dart';
import 'package:nerimobile/theme/sizing/radius.dart';
import 'package:nerimobile/theme/sizing/spacing.dart';
import 'package:nerimobile/views/chat/channel/channel_header.dart';
import 'package:nerimobile/views/chat/composer/attachment_panel.dart';
import 'package:nerimobile/views/chat/composer/composer.dart';
import 'package:nerimobile/views/chat/composer/emoji_panel.dart';
import 'package:nerimobile/views/chat/message/message_list.dart';
import 'package:nerimobile/views/dashboard/dm_list.dart';
import 'package:nerimobile/views/shell/app_scaffold.dart';
import 'package:nerimobile/views/shell/destinations.dart';
import 'package:nerimobile/views/size_reporter.dart';

const _panelMotion = Duration(milliseconds: 300);
const _panelCurve = Curves.easeOutCubic;
const _flingVelocity = 400.0;
const _expandedHeight = 0.85;
const _emojiHeight = 0.4;

enum _Dock { attachments, emoji }

enum _Snap { closed, collapsed, expanded }

double _expansion(double visible, double collapsed, double expanded) =>
    ((visible - collapsed) / (expanded - collapsed)).clamp(0.0, 1.0);

class ChannelPane extends StatelessWidget {
  const ChannelPane({super.key, required this.channelId});

  final String channelId;

  @override
  Widget build(BuildContext context) {
    final dualPane = NeriWindow.of(context).isDualPane;
    final chat = _Chat(channelId: channelId, showBack: !dualPane);
    final sizing = context.neriSize;

    if (!dualPane) {
      return ColoredBox(
        color: context.neri[NeriToken.background],
        child: SafeArea(bottom: false, child: chat),
      );
    }

    return AppScaffold(
      branch: NeriBranch.dashboard,
      listPane: const DmListPane(),
      content: Padding(
        padding: EdgeInsets.only(
          top: sizing.space(NeriSpacingRole.sm),
          right: sizing.space(NeriSpacingRole.sm),
          bottom: sizing.space(NeriSpacingRole.sm),
        ),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: context.neri[NeriToken.background],
            borderRadius: sizing.rounded(NeriRadiusRole.md),
            border: Border.all(
              color: context.neri[NeriToken.border],
              width: sizing.border(NeriBorderRole.hairline),
            ),
          ),
          child: chat,
        ),
      ),
    );
  }
}

class _Chat extends ConsumerStatefulWidget {
  const _Chat({required this.channelId, required this.showBack});

  final String channelId;
  final bool showBack;

  @override
  ConsumerState<_Chat> createState() => _ChatState();
}

class _ChatState extends ConsumerState<_Chat> with WidgetsBindingObserver {
  double _composerHeight = 0;
  double _keyboard = 0;
  double? _drag;

  //keeps closing panel visible until it slides away
  _Dock _dock = _Dock.attachments;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  //scaffold hides view insets from the body
  @override
  void didChangeMetrics() {
    final view = View.of(context);
    final keyboard = view.viewInsets.bottom / view.devicePixelRatio;
    if (keyboard != _keyboard) setState(() => _keyboard = keyboard);
  }

  void _onDragStart(double height) => setState(() => _drag = height);

  void _onDragUpdate(DragUpdateDetails details, double max) =>
      setState(() => _drag = ((_drag ?? 0) - details.delta.dy).clamp(0.0, max));

  //snap to nearest height unless flinging
  void _onDragEnd(
    DragEndDetails details, {
    required bool attachments,
    required double collapsed,
    required double expanded,
  }) {
    final height = _drag ?? 0;
    final velocity = details.primaryVelocity ?? 0;

    setState(() => _drag = null);

    final snap = switch (velocity) {
      < -_flingVelocity => _Snap.expanded,
      > _flingVelocity => height > collapsed ? _Snap.collapsed : _Snap.closed,
      _ when height > (collapsed + expanded) / 2 => _Snap.expanded,
      _ when height > collapsed / 2 => _Snap.collapsed,
      _ => _Snap.closed,
    };

    if (attachments) {
      final picker = ref.read(
        attachmentPickerProvider(widget.channelId).notifier,
      );
      return switch (snap) {
        _Snap.expanded => picker.expand(),
        _Snap.collapsed => picker.collapse(),
        _Snap.closed => picker.close(),
      };
    }

    final pane = ref.read(emojiPaneProvider(widget.channelId).notifier);
    switch (snap) {
      case _Snap.expanded:
        pane.expand();
      case _Snap.collapsed:
        pane.collapse();
      case _Snap.closed:
        pane.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(emojiPaneProvider(widget.channelId), (_, pane) {
      if (pane.open) _dock = _Dock.emoji;
    });
    ref.listen(
      attachmentPickerProvider(widget.channelId).select((p) => p.open),
      (_, open) {
        if (open) _dock = _Dock.attachments;
      },
    );

    return LayoutBuilder(
      builder: (context, constraints) => _pane(context, constraints.biggest),
    );
  }

  Widget _pane(BuildContext context, Size pane) {
    final emoji = ref.watch(emojiPaneProvider(widget.channelId));
    final keyboard = emoji.searching ? 0.0 : _keyboard;
    final attachments = _dock == _Dock.attachments;
    final picker = ref.watch(attachmentPickerProvider(widget.channelId));
    final collapsed = collapsedPanelHeight(context, pane.width);
    final expanded = pane.height * _expandedHeight;
    final emojiHeight = pane.height * _emojiHeight;
    final safeBottom = MediaQuery.paddingOf(context).bottom;
    final dockCollapsed = attachments ? collapsed : emojiHeight;
    final target =
        _drag ??
        (attachments
            ? switch (picker.mode) {
                AttachmentPicker.closed => 0.0,
                AttachmentPicker.collapsed => collapsed,
                AttachmentPicker.expanded => expanded,
              }
            : switch (emoji.mode) {
                EmojiPane.closed => 0.0,
                EmojiPane.collapsed => emojiHeight,
                EmojiPane.expanded => expanded,
              });

    //keeps list, composer and panel in sync
    return TweenAnimationBuilder<double>(
      tween: Tween(end: target),
      duration: _drag == null ? _panelMotion : Duration.zero,
      curve: _panelCurve,
      builder: (context, shown, _) {
        //panel fills space above the keyboard
        final visible = max(0.0, shown - keyboard);
        final lift = min(visible, dockCollapsed);
        final frame = max(visible, dockCollapsed);

        return Stack(
          children: [
            Positioned.fill(
              child: MessageList(
                channelId: widget.channelId,
                bottomInset: _composerHeight + lift,
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: ChannelHeader(
                channelId: widget.channelId,
                showBack: widget.showBack,
              ),
            ),
            //collapsed panel lifts the composer, expanded one covers it
            Positioned(
              left: 0,
              right: 0,
              bottom: lift,
              child: SizeReporter(
                onSize: (size) {
                  if (mounted) setState(() => _composerHeight = size.height);
                },
                child: Composer(
                  channelId: widget.channelId,
                  bottomInset: max(0.0, safeBottom - visible),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: GestureDetector(
                behavior: HitTestBehavior.deferToChild,
                onVerticalDragStart: (_) => _onDragStart(visible),
                onVerticalDragUpdate: (details) =>
                    _onDragUpdate(details, expanded),
                onVerticalDragEnd: (details) => _onDragEnd(
                  details,
                  attachments: attachments,
                  collapsed: dockCollapsed,
                  expanded: expanded,
                ),
                child: SizedBox(
                  height: visible,
                  child: ClipRect(
                    child: OverflowBox(
                      alignment: Alignment.topCenter,
                      minHeight: frame,
                      maxHeight: frame,
                      child: attachments
                          ? AttachmentPanel(
                              channelId: widget.channelId,
                              expansion: _expansion(
                                visible,
                                dockCollapsed,
                                expanded,
                              ),
                            )
                          : EmojiPanel(
                              channelId: widget.channelId,
                              expansion: _expansion(
                                visible,
                                dockCollapsed,
                                expanded,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
