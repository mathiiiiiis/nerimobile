import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nerimobile/stores/user/user_store.dart';
import 'package:nerimobile/theme/core/theme_data.dart';
import 'package:nerimobile/theme/core/token.dart';
import 'package:nerimobile/theme/sizing/dimens.dart';
import 'package:nerimobile/views/avatar.dart';
import 'package:nerimobile/views/shell/destinations.dart';

class DestinationIcon extends ConsumerWidget {
  const DestinationIcon({
    super.key,
    required this.destination,
    required this.selected,
    required this.surface,
    required this.size,
  });

  final NeriDestination destination;
  final bool selected;
  final Color surface;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.neri;
    final sizing = context.neriSize;

    if (destination is AvatarDestination) {
      final user = ref.watch(currentUserProvider);
      return user == null
          ? _AvatarPlaceholder(size: size)
          : PresenceAvatar(user: user, size: size, surface: surface);
    }

    return Icon(
      destination.icon,
      fill: selected ? 1 : 0,
      size: sizing.dimen(NeriDimen.iconMd),
      color: selected ? colors[NeriToken.text] : colors[NeriToken.textTertiary],
    );
  }
}

class _AvatarPlaceholder extends StatelessWidget {
  const _AvatarPlaceholder({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: context.neri[NeriToken.textPlaceholder],
        shape: BoxShape.circle,
      ),
    );
  }
}
