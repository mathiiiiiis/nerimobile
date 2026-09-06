import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nerimobile/models/server.dart';
import 'package:nerimobile/models/user.dart';
import 'package:nerimobile/models/user_presence.dart';
import 'package:nerimobile/stores/user/user_presence_store.dart';
import 'package:nerimobile/theme/core/theme_data.dart';
import 'package:nerimobile/theme/sizing/dimens.dart';
import 'package:nerimobile/utils/colors.dart';
import 'package:nerimobile/utils/image.dart';

class Avatar extends StatelessWidget {
  final Server? server;
  final User? user;
  final double size;
  final bool? animate;
  const Avatar({
    super.key,
    this.server,
    this.user,
    this.animate,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final name = server?.name ?? user?.username ?? '';
    final hexColor = server?.hexColor ?? user?.hexColor ?? '';
    final avatar = server?.avatar ?? user?.avatar;
    final avatarExists = avatar != null && avatar.trim() != '';
    final avatarUrl = avatarExists
        ? buildImageUrl(
            avatar,
            size: _requestSize(context, size),
            animate: animate == true,
          )
        : null;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: avatarUrl == null ? hexToColor(hexColor) : null,
        borderRadius: BorderRadius.circular(99),
      ),
      alignment: Alignment.center,
      child: avatarUrl == null
          ? Text(
              name.substring(0, 1).toUpperCase(),
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w700,
                fontSize: 24,
              ),
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: Image.network(
                avatarUrl,
                fit: BoxFit.cover,
                width: size,
                height: size,
                errorBuilder: (context, error, stackTrace) =>
                    SizedBox(height: size, width: size),
              ),
            ),
    );
  }
}

int _requestSize(BuildContext context, double size) {
  final pixels = size * MediaQuery.devicePixelRatioOf(context);
  return max(_minRequestSize, (pixels / 32).ceil() * 32);
}

const _minRequestSize = 64;

const _presenceDotRatio = 0.25;

class PresenceAvatar extends ConsumerWidget {
  const PresenceAvatar({
    super.key,
    required this.user,
    required this.size,
    required this.surface,
  });

  final User user;
  final double size;
  final Color surface;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presence = ref.watch(presencesProvider)[user.id];
    final status =
        PresenceStatus.fromValue(presence?.status ?? 0) ??
        PresenceStatus.offline;
    final dot = size * _presenceDotRatio;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Avatar(user: user, size: size),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: dot,
              height: dot,
              decoration: BoxDecoration(
                color: context.neri[status.token],
                shape: BoxShape.circle,
                border: Border.all(
                  color: surface,
                  width: context.neriSize.dimen(NeriDimen.avatarRingWidth),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
