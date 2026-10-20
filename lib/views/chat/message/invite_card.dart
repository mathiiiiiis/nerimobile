import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:nerimobile/models/server_invite.dart';
import 'package:nerimobile/services/api_client.dart';
import 'package:nerimobile/services/server_service.dart';
import 'package:nerimobile/stores/server/invite_preview_store.dart';
import 'package:nerimobile/stores/server/server_store.dart';
import 'package:nerimobile/theme/core/theme_data.dart';
import 'package:nerimobile/theme/core/token.dart';
import 'package:nerimobile/theme/sizing/border.dart';
import 'package:nerimobile/theme/sizing/dimens.dart';
import 'package:nerimobile/theme/sizing/radius.dart';
import 'package:nerimobile/theme/sizing/spacing.dart';
import 'package:nerimobile/theme/typography/text_styles.dart';
import 'package:nerimobile/utils/colors.dart';
import 'package:nerimobile/views/avatar.dart';
import 'package:nerimobile/views/banner_image.dart';
import 'package:nerimobile/views/modal/bottom_sheet.dart';
import 'package:nerimobile/views/press_scale.dart';
import 'package:nerimobile/views/skeleton/skeleton.dart';

const _buttonPressScale = 0.97;

class InviteCard extends ConsumerWidget {
  const InviteCard({super.key, required this.code});

  final String code;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sizing = context.neriSize;
    final preview = ref.watch(invitePreviewProvider(code));

    return Padding(
      padding: EdgeInsets.only(top: sizing.space(NeriSpacingRole.sm)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: sizing.dimen(NeriDimen.dialogWidth),
        ),
        child: switch (preview) {
          AsyncData(value: final preview?) => _Preview(
            code: code,
            preview: preview,
          ),
          AsyncData() => const _Status(
            icon: Symbols.error_rounded,
            label: 'This invite is invalid or expired', //TODO: add l10n
            alert: true,
          ),
          AsyncError() => GestureDetector(
            onTap: () => ref.invalidate(invitePreviewProvider(code)),
            child: const _Status(
              icon: Symbols.refresh_rounded,
              label: 'Could not load invite, tap to retry', //TODO: add l10n
            ),
          ),
          _ => const _Loading(),
        },
      ),
    );
  }
}

class _Frame extends StatelessWidget {
  const _Frame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.neri;
    final sizing = context.neriSize;

    return Material(
      color: colors[NeriToken.card],
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: sizing.rounded(NeriRadiusRole.lg),
        side: BorderSide(
          color: colors[NeriToken.border],
          width: sizing.border(NeriBorderRole.hairline),
        ),
      ),
      child: child,
    );
  }
}

class _Status extends StatelessWidget {
  const _Status({required this.icon, required this.label, this.alert = false});

  final IconData icon;
  final String label;
  final bool alert;

  @override
  Widget build(BuildContext context) {
    final colors = context.neri;
    final sizing = context.neriSize;
    final color = colors[alert ? NeriToken.alert : NeriToken.textPlaceholder];

    return _Frame(
      child: Padding(
        padding: EdgeInsets.all(sizing.space(NeriSpacingRole.md)),
        child: Row(
          spacing: sizing.space(NeriSpacingRole.sm),
          children: [
            Icon(icon, size: sizing.dimen(NeriDimen.iconSm), color: color),
            Flexible(
              child: Text(
                label,
                style: context.neriText[NeriTextRole.bodyMedium].copyWith(
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    final sizing = context.neriSize;

    return SkeletonScope(
      child: _Frame(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SheetHeader(
              title: '',
              leading: SkeletonBlock(
                height: sizing.dimen(NeriDimen.avatarMd),
                width: sizing.dimen(NeriDimen.avatarMd),
                shape: NeriRadiusRole.md,
              ),
              leadingRadius: sizing.rounded(NeriRadiusRole.md),
              background: ColoredBox(color: context.neri[NeriToken.skeleton]),
              embedded: true,
            ),
            Padding(
              padding: EdgeInsets.all(sizing.space(NeriSpacingRole.md)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: sizing.space(NeriSpacingRole.md),
                children: [
                  SkeletonBlock(
                    height: sizing.space(NeriSpacingRole.md),
                    width: sizing.dimen(NeriDimen.attachmentCard),
                  ),
                  SkeletonBlock(
                    height: sizing.dimen(NeriDimen.controlSize),
                    shape: NeriRadiusRole.md,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Preview extends ConsumerStatefulWidget {
  const _Preview({required this.code, required this.preview});

  final String code;
  final InvitePreview preview;

  @override
  ConsumerState<_Preview> createState() => _PreviewState();
}

class _PreviewState extends ConsumerState<_Preview> {
  var _joining = false;
  String? _error;

  void _open() => context.go('/app/servers/${widget.preview.server.id}');

  Future<void> _join() async {
    setState(() {
      _joining = true;
      _error = null;
    });
    try {
      await joinServerByInvite(ref.read(dioProvider), widget.code);
      //server:joined fills stores, server page waits for them
      if (mounted) context.go('/app/servers/${widget.preview.server.id}');
    } on DioException catch (error) {
      if (!mounted) return;
      setState(
        () => _error =
            apiErrorMessage(error) ??
            'Could not reach the server', //TODO: add l10n
      );
    } finally {
      if (mounted) setState(() => _joining = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.neri;
    final sizing = context.neriSize;
    final text = context.neriText;
    final server = widget.preview.server;
    final count = widget.preview.memberCount;
    final joined = ref.watch(
      serversProvider.select((servers) => servers.containsKey(server.id)),
    );
    final padding = sizing.space(NeriSpacingRole.md);

    return _Frame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SheetHeader(
            title: server.name,
            leading: Avatar(
              server: server,
              size: sizing.dimen(NeriDimen.avatarMd),
              borderRadius: sizing.rounded(NeriRadiusRole.md),
            ),
            subtitle: count == 1
                ? '1 member'
                : '$count members', //TODO: add l10n,
            leadingRadius: sizing.rounded(NeriRadiusRole.md),
            background: BannerImage(
              path: server.banner,
              fallback: idColor(server.id),
            ),
            embedded: true,
          ),
          Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: sizing.space(NeriSpacingRole.md),
              children: [
                if (_error case final error?)
                  Text(
                    error,
                    style: text[NeriTextRole.bodySmall].copyWith(
                      color: colors[NeriToken.alert],
                    ),
                  ),
                PressScale(
                  scale: _buttonPressScale,
                  child: FilledButton(
                    onPressed: _joining ? null : (joined ? _open : _join),
                    style: FilledButton.styleFrom(
                      backgroundColor: colors[NeriToken.primary],
                      foregroundColor: colors[NeriToken.text],
                      minimumSize: Size.fromHeight(
                        sizing.dimen(NeriDimen.controlSize),
                      ),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: sizing.rounded(NeriRadiusRole.md),
                      ),
                    ),
                    child: Text(
                      _joining
                          ? 'Joining…' //TODO: add l10n
                          : joined
                          ? 'Open server' //TODO: add l10n
                          : 'Join server', //TODO: add l10n
                    ),
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
