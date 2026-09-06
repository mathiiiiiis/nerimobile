import 'dart:math';

import 'package:flutter/material.dart';

import 'package:nerimobile/models/server.dart';
import 'package:nerimobile/models/user.dart';
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
