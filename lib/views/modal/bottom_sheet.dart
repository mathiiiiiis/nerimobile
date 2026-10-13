import 'package:flutter/material.dart';

import 'package:nerimobile/theme/core/theme_data.dart';
import 'package:nerimobile/theme/core/token.dart';
import 'package:nerimobile/theme/sizing/border.dart';
import 'package:nerimobile/theme/sizing/dimens.dart';
import 'package:nerimobile/theme/sizing/radius.dart';
import 'package:nerimobile/theme/sizing/spacing.dart';
import 'package:nerimobile/theme/typography/text_styles.dart';

const _disabledOpacity = 0.4;
const _bannerSpace = 56.0;
const _handleWidth = 32.0;
const _handleHeight = 4.0;
const _onBanner = Colors.white;
const _onBannerSecondary = Color(0xCCFFFFFF);
const _dimTop = Color(0x26000000);
const _dimBottom = Color(0x99000000);

class SheetAction {
  const SheetAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.hint,
    this.enabled = true,
    this.destructive = false,
    this.filled = false,
    this.dismiss = true,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? hint;
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
    builder: builder,
  );
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
    this.leading,
    this.subtitle,
    this.leadingRadius,
    this.background,
  });

  final String title;
  final Widget? leading;
  final String? subtitle;
  final BorderRadius? leadingRadius;
  final Widget? background;

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

    return Padding(
      padding: EdgeInsets.fromLTRB(
        sizing.space(NeriSpacingRole.md),
        sizing.space(NeriSpacingRole.md),
        sizing.space(NeriSpacingRole.md),
        0,
      ),
      child: ClipRRect(
        borderRadius: sizing.rounded(NeriRadiusRole.lg),
        child: Stack(
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
                Padding(
                  padding: EdgeInsets.only(
                    top: sizing.space(NeriSpacingRole.sm),
                  ),
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
                    horizontal: sizing.space(NeriSpacingRole.md),
                  ),
                  child: _content(context, onBanner: true),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

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
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text[NeriTextRole.headlineSmall].copyWith(
                    color: onBanner ? _onBanner : colors[NeriToken.text],
                  ),
                ),
                if (subtitle case final subtitle?)
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text[NeriTextRole.bodySmall].copyWith(
                      color: onBanner
                          ? _onBannerSecondary
                          : colors[NeriToken.textSecondary],
                    ),
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
    final dWidth = sizing.border(NeriBorderRole.thin);

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
            ],
          ),
        ),
      ),
    );
  }
}
