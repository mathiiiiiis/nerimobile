import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:nerimobile/stores/channel/last_opened_store.dart';
import 'package:nerimobile/views/shell/panes.dart';

class ServerLanding extends ConsumerWidget {
  const ServerLanding({super.key, required this.serverId});

  final String serverId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final channelId = ref.watch(serverChannelToOpenProvider(serverId));
    if (channelId == null) {
      return const PlaceholderPane(label: 'Server'); //TODO: add l10n
    }

    if (ModalRoute.isCurrentOf(context) ?? false) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted && (ModalRoute.isCurrentOf(context) ?? false)) {
          context.go('/app/servers/$serverId/$channelId');
        }
      });
    }
    return const SizedBox.shrink();
  }
}
