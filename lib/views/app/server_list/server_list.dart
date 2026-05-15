import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nerimobile/theme/app_theme.dart';
// import 'package:nerimobile/utils/theme_notifier.dart';
import 'package:signals/signals_flutter.dart';
import '../../avatar.dart';
import 'package:nerimobile/stores/server_store.dart';

class ServerList extends StatefulWidget {
  const ServerList({super.key});

  @override
  State<ServerList> createState() => _ServerListState();
}

class _ServerListState extends State<ServerList> with SignalsMixin {
  late final Computed<List<String>> _serverIds;

  @override
  void initState() {
    super.initState();
    _serverIds = createComputed(() => serverStore.servers.keys.toList());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 68,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Column(
        children: [
          // IconButton(
          //   icon: const Icon(Symbols.brightness_6),
          //   onPressed: toggleTheme,
          //   iconSize: 10,
          // ),
          Expanded(
            child: Watch((context) {
              final ids = _serverIds.value;
              return ListView(
                itemExtent: AvatarSize.xl.value + 4,
                padding: const EdgeInsets.symmetric(vertical: 6),
                children: ids.map((id) => ServerItem(id: id)).toList(),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class ServerItem extends StatefulWidget {
  final String id;
  const ServerItem({required this.id, super.key});

  @override
  State<ServerItem> createState() => _ServerItemState();
}

class _ServerItemState extends State<ServerItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final server = serverStore.servers[widget.id];
      if (server == null) return const SizedBox.shrink();

      final isSelected = serverStore.currentServerId.value == widget.id;

      final notification = serverStore.notifications[widget.id];

      return MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                bottom: 2.0,
                left: 2.0,
                right: 2.0,
              ),
              child: Material(
                borderRadius: BorderRadius.circular(8),
                color: Colors.transparent,
                child: Ink(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.itemSelectedBg
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => context.go(
                      '/app/servers/${widget.id}/${server.defaultChannelId}',
                    ),
                    child: Center(
                      child: Avatar(
                        server: server,
                        size: AvatarSize.lg,
                        animate: _hovered,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (notification != null && notification > 0)
              Positioned(
                top: 8,
                right: 8,
                child: IgnorePointer(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.alertColor,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      constraints: const BoxConstraints(minWidth: 18),
                      child: Text(
                        '$notification',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),

            if (isSelected || notification != null)
              Positioned(
                top: 0,
                bottom: 0,
                left: 2,
                child: IgnorePointer(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      width: 3,
                      height: 14,

                      decoration: BoxDecoration(
                        color: notification != null
                            ? AppTheme.alertColor
                            : Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
}
