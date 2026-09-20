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
import 'package:nerimobile/views/chat/message/message_list.dart';
import 'package:nerimobile/views/dashboard/dm_list.dart';
import 'package:nerimobile/views/shell/app_scaffold.dart';
import 'package:nerimobile/views/shell/destinations.dart';
import 'package:nerimobile/views/size_reporter.dart';

const _panelResize = Duration(milliseconds: 200);
const _flingVelocity = 400.0;
const _expandedHeight = 0.85;

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

class _ChatState extends ConsumerState<_Chat> {
  double _composerHeight = 0;
  double? _drag;

  void _onDragStart(double height) => setState(() => _drag = height);

  void _onDragUpdate(DragUpdateDetails details, double max) =>
      setState(() => _drag = ((_drag ?? 0) - details.delta.dy).clamp(0.0, max));

  //snap to nearest height unless flinging
  void _onDragEnd(
    DragEndDetails details, {
    required double collapsed,
    required double expanded,
  }) {
    final height = _drag ?? 0;
    final velocity = details.primaryVelocity ?? 0;
    final picker = ref.read(
      attachmentPickerProvider(widget.channelId).notifier,
    );

    setState(() => _drag = null);

    if (velocity < -_flingVelocity) return picker.expand();
    if (velocity > _flingVelocity) {
      return height > collapsed ? picker.collapse() : picker.close();
    }

    if (height > (collapsed + expanded) / 2) return picker.expand();
    height > collapsed / 2 ? picker.collapse() : picker.close();
  }

  @override
  Widget build(BuildContext context) {
    final picker = ref.watch(attachmentPickerProvider(widget.channelId));
    final collapsed = collapsedPanelHeight(context);
    final expanded = MediaQuery.sizeOf(context).height * _expandedHeight;
    final height =
        _drag ??
        switch (picker.mode) {
          AttachmentPicker.closed => 0.0,
          AttachmentPicker.collapsed => collapsed,
          AttachmentPicker.expanded => expanded,
        };
    final duration = _drag == null ? _panelResize : Duration.zero;

    return Stack(
      children: [
        Positioned.fill(
          child: MessageList(
            channelId: widget.channelId,
            bottomInset: _composerHeight + (picker.open ? collapsed : 0),
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
        AnimatedPositioned(
          duration: duration,
          curve: Curves.easeOut,
          left: 0,
          right: 0,
          bottom: min(height, collapsed),
          child: SizeReporter(
            onSize: (size) {
              if (mounted) setState(() => _composerHeight = size.height);
            },
            child: Composer(channelId: widget.channelId),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: GestureDetector(
            behavior: HitTestBehavior.deferToChild,
            onVerticalDragStart: (_) => _onDragStart(height),
            onVerticalDragUpdate: (details) => _onDragUpdate(details, expanded),
            onVerticalDragEnd: (details) =>
                _onDragEnd(details, collapsed: collapsed, expanded: expanded),
            child: AnimatedContainer(
              duration: duration,
              curve: Curves.easeOut,
              height: height,
              clipBehavior: Clip.hardEdge,
              decoration: const BoxDecoration(),
              child: OverflowBox(
                alignment: Alignment.topCenter,
                minHeight: 0,
                maxHeight: max(height, collapsed),
                child: AttachmentPanel(channelId: widget.channelId),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
