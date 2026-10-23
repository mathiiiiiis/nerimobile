import 'dart:math';

import 'package:flutter/material.dart';

import 'package:nerimobile/theme/core/theme_data.dart';
import 'package:nerimobile/theme/core/token.dart';
import 'package:nerimobile/theme/sizing/border.dart';
import 'package:nerimobile/theme/sizing/dimens.dart';
import 'package:nerimobile/theme/sizing/radius.dart';
import 'package:nerimobile/theme/sizing/spacing.dart';
import 'package:nerimobile/theme/typography/text_styles.dart';
import 'package:nerimobile/utils/colors.dart';
import 'package:nerimobile/views/core/press_scale.dart';

const _disabledOpacity = 0.4;
const _maxSheetHeight = 0.6;
const _closeFraction = 0.25;
const _closeVelocity = 700.0;
const _settleTime = Duration(milliseconds: 200);
const _bannerSpace = 56.0;
const _handleWidth = 32.0;
const _handleHeight = 4.0;
const _onBanner = Colors.white;
const _onBannerSecondary = Color(0xCCFFFFFF);
const _dimTop = Color(0x26000000);
const _dimBottom = Color(0x99000000);

typedef SheetTrailing = ({IconData icon, String label, VoidCallback onTap});

class SheetAction {
  const SheetAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.hint,
    this.trailing,
    this.enabled = true,
    this.destructive = false,
    this.filled = false,
    this.dismiss = true,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? hint;
  final SheetTrailing? trailing;
  final bool enabled;
  final bool destructive;
  final bool filled;
  final bool dismiss;
}

class SheetGroup {
  const SheetGroup(this.actions);

  final List<SheetAction> actions;
}

Future<T?> showSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool dragHandle = true,
}) async {
  final colors = context.neri;
  final radius = Radius.circular(context.neriSize.radius(NeriRadiusRole.xl));

  return showModalBottomSheet<T>(
    context: context,
    useSafeArea: true,
    showDragHandle: dragHandle,
    isScrollControlled: true,
    backgroundColor: colors[NeriToken.pane],
    barrierColor: colors[NeriToken.scrim],
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(topLeft: radius, topRight: radius),
    ),
    builder: (context) => _GrowingSheet(child: builder(context)),
  );
}

class _GrowingSheet extends StatefulWidget {
  const _GrowingSheet({required this.child});

  final Widget child;

  @override
  State<_GrowingSheet> createState() => _GrowingSheetState();
}

class _GrowingSheetState extends State<_GrowingSheet>
    with SingleTickerProviderStateMixin {
  final _scroll = ScrollController();
  late final _settle = AnimationController(vsync: this, duration: _settleTime)
    ..addListener(_settled);
  double? _height;
  var _available = double.infinity;

  double? _pulledFrom;
  Animation<double>? _settleTo;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_grow);
  }

  @override
  void dispose() {
    _scroll.dispose();
    _settle.dispose();
    super.dispose();
  }

  void _grow() {
    final height = _height;
    final offset = _scroll.offset;
    if (height == null || offset <= 0 || height >= _available) return;

    final grown = min(_available, height + offset);
    _scroll.position.correctBy(-(grown - height));
    setState(() => _height = grown);
  }

  bool _onScroll(ScrollNotification notification) {
    final height = _height;
    if (height == null ||
        notification.depth != 0 ||
        notification.metrics.axis != Axis.vertical) {
      return false;
    }

    switch (notification) {
      case OverscrollNotification(:final overscroll, dragDetails: _?)
          when overscroll < 0:
        _settle.stop();
        _pulledFrom ??= height;
        setState(() => _height = max(0, height + overscroll));
      case ScrollEndNotification(:final dragDetails):
        _release(dragDetails?.velocity.pixelsPerSecond.dy ?? 0);
    }
    return false;
  }

  void _release(double velocity) {
    final from = _pulledFrom;
    final height = _height;
    _pulledFrom = null;
    if (from == null || height == null) return;

    if (velocity > _closeVelocity || from - height > from * _closeFraction) {
      Navigator.of(context).maybePop();
      return;
    }
    _settleTo = Tween(
      begin: height,
      end: from,
    ).animate(CurvedAnimation(parent: _settle, curve: Curves.easeOut));
    _settle.forward(from: 0);
  }

  void _settled() {
    final to = _settleTo;
    if (to != null) setState(() => _height = to.value);
  }

  @override
  Widget build(BuildContext context) {
    final cap = MediaQuery.sizeOf(context).height * _maxSheetHeight;

    return LayoutBuilder(
      builder: (context, constraints) {
        _available = constraints.maxHeight;
        final height = _height ??= min(cap, _available);

        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: height),
          child: NotificationListener<ScrollNotification>(
            onNotification: _onScroll,
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(
                context,
              ).copyWith(physics: const ClampingScrollPhysics()),
              child: PrimaryScrollController(
                controller: _scroll,
                child: widget.child,
              ),
            ),
          ),
        );
      },
    );
  }
}

Future<void> showActionSheet(
  BuildContext context, {
  List<SheetAction> actions = const [],
  List<SheetGroup> groups = const [],
  Widget? header,
}) async {
  final picked = await showSheet<SheetAction>(
    context,
    dragHandle: header is! SheetHeader || header.background == null,
    builder: (context) =>
        SheetActions(header: header, actions: actions, groups: groups),
  );
  picked?.onTap();
}

class SheetActions extends StatelessWidget {
  const SheetActions({
    super.key,
    this.actions = const [],
    this.groups = const [],
    this.header,
  });

  final List<SheetAction> actions;
  final List<SheetGroup> groups;
  final Widget? header;

  @override
  Widget build(BuildContext context) {
    final sizing = context.neriSize;
    final cards = [
      if (actions.isNotEmpty) SheetGroup(actions),
      for (final group in groups)
        if (group.actions.isNotEmpty) group,
    ];

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: sizing.space(NeriSpacingRole.md)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: sizing.space(NeriSpacingRole.sm),
          children: [
            ?header,
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: sizing.space(NeriSpacingRole.md),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: sizing.space(NeriSpacingRole.sm),
                children: [for (final group in cards) _GroupCard(group)],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SheetHeader extends StatelessWidget {
  const SheetHeader({
    super.key,
    required this.title,
    this.titleColor,
    this.leading,
    this.subtitle,
    this.caption,
    this.leadingRadius,
    this.background,
    this.embedded = false,
  });

  final String title;
  final String? titleColor;
  final Widget? leading;
  final String? subtitle;
  final Widget? caption;
  final BorderRadius? leadingRadius;
  final Widget? background;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final sizing = context.neriSize;
    final background = this.background;
    if (background == null) {
      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: sizing.space(NeriSpacingRole.md),
        ),
        child: _content(context, onBanner: false),
      );
    }

    final banner = Stack(
      children: [
        Positioned.fill(child: background),
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_dimTop, _dimBottom],
              ),
            ),
          ),
        ),
        Column(
          children: [
            if (!embedded)
              Padding(
                padding: EdgeInsets.only(top: sizing.space(NeriSpacingRole.sm)),
                child: Container(
                  width: _handleWidth,
                  height: _handleHeight,
                  decoration: BoxDecoration(
                    color: _onBannerSecondary,
                    borderRadius: sizing.rounded(NeriRadiusRole.full),
                  ),
                ),
              ),
            const SizedBox(height: _bannerSpace),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: sizing.space(NeriSpacingRole.xs),
              ),
              child: _content(context, onBanner: true),
            ),
          ],
        ),
      ],
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(
        sizing.space(NeriSpacingRole.md),
        sizing.space(NeriSpacingRole.md),
        sizing.space(NeriSpacingRole.md),
        0,
      ),
      child: ClipRRect(
        borderRadius: sizing.rounded(
          embedded ? NeriRadiusRole.md : NeriRadiusRole.lg,
        ),
        child: banner,
      ),
    );
  }

  Widget? get _subtitleText => switch (subtitle) {
    final subtitle? => Text(subtitle),
    null => null,
  };

  Widget _content(BuildContext context, {required bool onBanner}) {
    final colors = context.neri;
    final sizing = context.neriSize;
    final text = context.neriText;
    final leading = this.leading;
    final ring = sizing.border(NeriBorderRole.medium);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: sizing.space(NeriSpacingRole.xs),
        vertical: sizing.space(NeriSpacingRole.sm),
      ),
      child: Row(
        spacing: sizing.space(NeriSpacingRole.md),
        children: [
          if (leading != null)
            onBanner
                ? Container(
                    padding: EdgeInsets.all(ring),
                    decoration: BoxDecoration(
                      borderRadius:
                          (leadingRadius ??
                              sizing.rounded(NeriRadiusRole.full)) +
                          BorderRadius.circular(ring),
                      color: colors[NeriToken.border],
                    ),
                    child: leading,
                  )
                : leading,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                buildColoredName(
                  title,
                  hexColor: titleColor,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text[NeriTextRole.headlineSmall].copyWith(
                    color: onBanner ? _onBanner : colors[NeriToken.text],
                  ),
                ),
                if (caption ?? _subtitleText case final caption?)
                  DefaultTextStyle(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text[NeriTextRole.bodySmall].copyWith(
                      color: onBanner
                          ? _onBannerSecondary
                          : colors[NeriToken.textSecondary],
                    ),
                    child: caption,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard(this.group);

  final SheetGroup group;

  @override
  Widget build(BuildContext context) {
    final colors = context.neri;
    final sizing = context.neriSize;
    final dWidth = sizing.border(NeriBorderRole.medium);

    return Material(
      color: colors[NeriToken.cardBright],
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: sizing.rounded(NeriRadiusRole.lg),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (index, action) in group.actions.indexed) ...[
            if (index > 0)
              Divider(
                height: dWidth,
                thickness: dWidth,
                color: colors[NeriToken.pane],
              ),
            _ActionRow(action: action),
          ],
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.action});

  final SheetAction action;

  @override
  Widget build(BuildContext context) {
    final colors = context.neri;
    final sizing = context.neriSize;
    final text = context.neriText;
    final color = action.destructive
        ? colors[NeriToken.alert]
        : colors[NeriToken.text];

    return Opacity(
      opacity: action.enabled ? 1 : _disabledOpacity,
      child: InkWell(
        onTap: !action.enabled
            ? null
            : () => action.dismiss
                  ? Navigator.of(context).pop(action)
                  : action.onTap(),
        child: Padding(
          padding: EdgeInsets.all(sizing.space(NeriSpacingRole.md)),
          child: Row(
            spacing: sizing.space(NeriSpacingRole.lg),
            children: [
              Icon(
                action.icon,
                fill: action.filled ? 1 : 0,
                size: sizing.dimen(NeriDimen.iconSm),
                color: action.destructive
                    ? color
                    : colors[NeriToken.textSecondary],
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      action.label,
                      style: context.neriText[NeriTextRole.bodyLarge].copyWith(
                        color: color,
                      ),
                    ),
                    if (action.hint case final hint?)
                      Text(
                        hint,
                        style: text[NeriTextRole.bodySmall].copyWith(
                          color: colors[NeriToken.textTertiary],
                        ),
                      ),
                  ],
                ),
              ),
              if (action.trailing case final trailing?)
                Tooltip(
                  message: trailing.label,
                  child: GestureDetector(
                    onTap: action.enabled ? trailing.onTap : null,
                    child: PressScale(
                      child: Icon(
                        trailing.icon,
                        size: sizing.dimen(NeriDimen.iconSm),
                        color: colors[NeriToken.textTertiary],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
