import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import 'package:nerimobile/config.dart';
import 'package:nerimobile/models/server.dart';
import 'package:nerimobile/models/server_invite.dart';
import 'package:nerimobile/services/api_client.dart';
import 'package:nerimobile/services/server_service.dart';
import 'package:nerimobile/stores/toast/toast_store.dart';
import 'package:nerimobile/stores/user/user_store.dart';
import 'package:nerimobile/theme/core/theme_data.dart';
import 'package:nerimobile/theme/sizing/dimens.dart';
import 'package:nerimobile/theme/sizing/radius.dart';
import 'package:nerimobile/views/user/avatar.dart';
import 'package:nerimobile/views/core/modal/bottom_sheet.dart';

Future<void> showInviteSheet(BuildContext context, Server server) async {
  final picked = await showSheet<SheetAction>(
    context,
    builder: (context) => _InviteSheet(server),
  );
  picked?.onTap();
}

String _link(ServerInvite invite) => '$inviteUrl${invite.code}';

String _errorMessage(DioException error) =>
    apiErrorMessage(error) ?? 'Could not reach the server'; //TODO: add l10n

class _InviteSheet extends ConsumerStatefulWidget {
  const _InviteSheet(this.server);

  final Server server;

  @override
  ConsumerState<_InviteSheet> createState() => _InviteSheetState();
}

class _InviteSheetState extends ConsumerState<_InviteSheet> {
  List<ServerInvite>? _invites;
  String? _loadError;
  String? _createError;
  var _creating = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loadError = null);
    try {
      final invites = await fetchServerInvites(
        ref.read(dioProvider),
        widget.server.id,
      );
      invites.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      if (mounted) setState(() => _invites = invites);
    } on DioException catch (error) {
      if (mounted) setState(() => _loadError = _errorMessage(error));
    }
  }

  Future<void> _create() async {
    setState(() {
      _creating = true;
      _createError = null;
    });
    try {
      final invite = await createServerInvite(
        ref.read(dioProvider),
        widget.server.id,
      );
      await ref
          .read(toastProvider.notifier)
          .copy(_link(invite), label: 'Invite link copied'); //TODO: add l10n
      if (mounted) setState(() => _invites = [invite, ...?_invites]);
    } on DioException catch (error) {
      if (mounted) setState(() => _createError = _errorMessage(error));
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  Future<void> _delete(ServerInvite invite) async {
    final toast = ref.read(toastProvider.notifier);
    final previous = _invites;
    setState(() {
      _invites = [...?_invites]..remove(invite);
      _createError = null;
    });
    try {
      await deleteServerInvite(
        ref.read(dioProvider),
        widget.server.id,
        invite.code,
      );
    } on DioException catch (error) {
      toast.error(
        apiErrorMessage(error) ?? 'Could not delete invite', //TODO: add l10n
      );
      //put it back, invite still works
      if (mounted) setState(() => _invites = previous);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sizing = context.neriSize;
    final me = ref.watch(currentUserIdProvider);
    final users = ref.watch(usersProvider);
    final invites = _invites;

    return SheetActions(
      header: SheetHeader(
        title: 'Invite people', //TODO: add l10n
        subtitle: widget.server.name,
        leading: Avatar(
          server: widget.server,
          size: sizing.dimen(NeriDimen.avatarMd),
          borderRadius: sizing.rounded(NeriRadiusRole.md),
        ),
      ),
      groups: [
        SheetGroup([
          SheetAction(
            icon: Symbols.add_link_rounded,
            label: _creating
                ? 'Creating invite…' //TODO: add l10n
                : 'Create invite link', //TODO: add l10n
            hint: _createError ?? 'The new link is copied', //TODO: add l10n
            enabled: !_creating && invites != null,
            dismiss: false,
            onTap: _create,
          ),
        ]),
        SheetGroup([
          if (_loadError case final error?)
            SheetAction(
              icon: Symbols.refresh_rounded,
              label: 'Could not load invites', //TODO: add l10n
              hint: error,
              dismiss: false,
              onTap: _load,
            )
          else if (invites == null)
            SheetAction(
              icon: Symbols.link_rounded,
              label: 'Loading invites…', //TODO: add l10n
              enabled: false,
              onTap: () {},
            )
          else
            for (final invite in invites)
              SheetAction(
                icon: Symbols.link_rounded,
                label: _link(invite).replaceFirst('https://', ''),
                hint: [
                  invite.uses == 1
                      ? ' 1 use'
                      : '${invite.uses} uses', //TODO: add l10n
                  if (invite.createdBy ?? users[invite.createdById]
                      case final creator?)
                    invite.createdById == me
                        ? 'by ${creator.username} (You)' //TODO: add l10n
                        : 'by ${creator.username}', //TODO: add l10n
                ].join(' • '),
                onTap: () => ref
                    .read(toastProvider.notifier)
                    .copy(
                      _link(invite),
                      label: 'Invite link copied', //TODO: add l10n
                    ),
                dismiss: false,
                trailing: (
                  icon: Symbols.delete_rounded,
                  label: 'Delete invite', //TODO: add l10n
                  onTap: () => _delete(invite),
                ),
              ),
        ]),
      ],
    );
  }
}
