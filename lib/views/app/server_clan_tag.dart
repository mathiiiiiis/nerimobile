import 'package:flutter/material.dart';
import 'package:nerimobile/models/server.dart';
import 'package:nerimobile/theme/app_theme.dart';
import 'package:nerimobile/views/cdn_icon.dart';

class ServerClanTag extends StatelessWidget {
  final ServerClan clan;

  const ServerClanTag({super.key, required this.clan});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.itemSelectedBg,
        borderRadius: BorderRadius.circular(4),
      ),
      padding: EdgeInsets.symmetric(horizontal: 3, vertical: 0),
      child: Row(
        spacing: 2,
        children: [
          CdnIcon(size: 12, path: clan.icon),
          Text(
            clan.tag,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
