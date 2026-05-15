import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:nerimobile/services/socket_service.dart';
import 'package:nerimobile/stores/channel_store.dart';
import 'package:nerimobile/stores/drawer_store.dart';
import 'package:nerimobile/stores/media_query_store.dart';
import 'package:nerimobile/stores/server_store.dart';
import 'package:nerimobile/utils/secure_storage.dart';
import 'package:nerimobile/views/app/server_channel_list/server_channel_list.dart';
import 'package:nerimobile/views/app/server_member_list/server_member_list.dart';
import 'package:signals/signals_flutter.dart';
import '../app/server_list/server_list.dart';

class AppShell extends StatefulWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  @override
  void initState() {
    super.initState();
    connect();
  }

  void connect() async {
    final token = await getToken();
    if (token != null) {
      SocketService.instance.connect(token);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      return Material(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,

        child: Row(
          children: [
            if (!isMobile.value || drawer.opened.value == DrawerSide.left)
              ServerList(),
            Expanded(child: widget.child),
          ],
        ),
      );
    });
  }
}

class ChatLayout extends StatefulWidget {
  final Widget child;
  const ChatLayout({required this.child, super.key});

  @override
  State<ChatLayout> createState() => _ChatLayoutState();
}

class _ChatLayoutState extends State<ChatLayout> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final serverId = GoRouterState.of(context).pathParameters['serverId'];
    final channelId = GoRouterState.of(context).pathParameters['channelId'];
    if (serverStore.currentServerId.value != serverId) {
      serverStore.setCurrentServerId(serverId);
    }

    if (channelStore.currentChannelId.value != channelId) {
      channelStore.setCurrentChannelId(channelId);
    }
  }

  @override
  void dispose() {
    channelStore.setCurrentChannelId(null);
    serverStore.setCurrentServerId(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      return Material(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        child: Row(
          children: [
            if (!isMobile.value || drawer.opened.value == DrawerSide.left)
              ServerChannelList(),
            Expanded(
              child: Column(
                children: [
                  Header(),
                  if (!isMobile.value || drawer.opened.value == null)
                    Expanded(child: widget.child),
                ],
              ),
            ),
            if (!isMobile.value || drawer.opened.value == DrawerSide.right)
              ServerMemberList(),
          ],
        ),
      );
    });
  }
}

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      color: Theme.of(context).colorScheme.surfaceContainer,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Ink(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(999)),
            child: Material(
              borderRadius: BorderRadius.circular(999),
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: () {
                  drawer.toggle(DrawerSide.left);
                },
                child: Container(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Symbols.menu,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ),
          Ink(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(999)),
            child: Material(
              borderRadius: BorderRadius.circular(999),
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: () {
                  drawer.toggle(DrawerSide.right);
                },
                child: Container(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Symbols.menu,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
