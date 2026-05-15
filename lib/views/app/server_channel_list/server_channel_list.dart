import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:nerimobile/models/channel.dart';
import 'package:nerimobile/stores/channel_store.dart';
import 'package:nerimobile/stores/drawer_store.dart';
import 'package:nerimobile/stores/server_store.dart';
import 'package:nerimobile/theme/app_theme.dart';
import 'package:nerimobile/views/cdn_icon.dart';
import 'package:signals/signals_flutter.dart';

class ServerChannelList extends StatefulWidget {
  const ServerChannelList({super.key});
  @override
  State<ServerChannelList> createState() => _ServerChannelListState();
}

class _ServerChannelListState extends State<ServerChannelList>
    with SignalsMixin {
  late final _channelIds = createComputed(() {
    final channels = [...serverStore.currentServerChannels.value]
      ..sort((a, b) => (a.order ?? 0).compareTo(b.order ?? 0));

    final result = <Channel>[];
    for (final channel in channels) {
      if (channel.type == ChannelType.category.value) {
        result.add(channel);
        result.addAll(channels.where((c) => c.categoryId == channel.id));
      } else if (channel.categoryId == null) {
        result.add(channel);
      }
    }

    return result.map((c) => c.id).toList();
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: Column(
        children: [
          Expanded(
            child: Watch((context) {
              final channelIds = _channelIds.value;
              return ListView.builder(
                itemCount: channelIds.length,
                itemBuilder: (ctx, i) => ChannelItem(id: channelIds[i]),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class ChannelItem extends StatefulWidget {
  final String id;
  const ChannelItem({super.key, required this.id});

  @override
  State<ChannelItem> createState() => _ChannelItemState();
}

class _ChannelItemState extends State<ChannelItem> with SignalsMixin {
  late final _isHovered = createSignal(false);

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final channel = channelStore.channels[widget.id];
      if (channel == null) return const SizedBox.shrink();

      final isSelected = channelStore.currentChannelId.value == widget.id;
      final isActive = isSelected || _isHovered.value;

      final isCategory = channel.type == ChannelType.category.value;

      final notification = channelStore.channelNotifications.value[channel.id];

      return Stack(
        clipBehavior: Clip.none,

        children: [
          Padding(
            padding: EdgeInsets.only(
              bottom: 2.0,
              left: 8.0,
              right: 8.0,
              top: isCategory ? 10 : 0,
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              child: Ink(
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.itemSelectedBg
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: InkWell(
                  hoverColor: AppTheme.itemHoveredBg,
                  borderRadius: BorderRadius.circular(8),
                  onHover: (hovering) => _isHovered.value = hovering,
                  onTap: () {
                    drawer.opened.value = null;
                    context.go(
                      '/app/servers/${channel.serverId}/${channel.id}',
                    );
                  },
                  highlightColor: Colors.transparent,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 6.0,
                      horizontal: isCategory ? 6.0 : 12.0,
                    ),
                    child: Row(
                      spacing: 8,
                      children: [
                        if (isCategory)
                          Icon(Symbols.keyboard_arrow_down_rounded, size: 10),
                        CdnIcon(
                          fallbackIcon: Symbols.tag_rounded,
                          channel: channel,
                          size: channel.type == ChannelType.category.value
                              ? 12
                              : 16,
                        ),
                        Text(
                          channel.name ?? '',
                          style: TextStyle(
                            fontSize: isCategory ? 12 : 14,
                            color: Theme.of(context).colorScheme.onSurface
                                .withValues(alpha: isActive ? 1.0 : 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (notification != null && notification > 0)
            Positioned(
              top: 0,
              bottom: 2,
              right: 12,
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
              bottom: 2,
              left: 8,
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
      );
    });
  }
}
