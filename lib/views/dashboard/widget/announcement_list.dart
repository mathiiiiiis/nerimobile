import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:nerimobile/stores/dashboard/announcement_store.dart';
import 'package:nerimobile/theme/core/theme_data.dart';
import 'package:nerimobile/theme/core/token.dart';
import 'package:nerimobile/theme/sizing/border.dart';
import 'package:nerimobile/theme/sizing/dimens.dart';
import 'package:nerimobile/theme/sizing/radius.dart';
import 'package:nerimobile/theme/sizing/spacing.dart';
import 'package:nerimobile/views/post/post_card.dart';

class AnnouncementList extends ConsumerWidget {
  const AnnouncementList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(announcementsProvider).value ?? const [];
    final sizing = context.neriSize;

    if (posts.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.all(sizing.space(NeriSpacingRole.md)),
      child: Column(
        spacing: sizing.space(NeriSpacingRole.md),
        children: [
          for (final post in posts)
            PostCard(
              post: post,
              action: Transform.translate(
                offset: const Offset(4.0, 0.0),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () =>
                      ref.read(announcementsProvider.notifier).dismiss(post.id),
                  child: Container(
                    padding: EdgeInsets.all(sizing.space(NeriSpacingRole.xs)),
                    decoration: BoxDecoration(
                      color: context.neri[NeriToken.background],
                      borderRadius: sizing.rounded(NeriRadiusRole.image),
                      border: Border.all(
                        color: context.neri[NeriToken.border],
                        width: sizing.border(NeriBorderRole.hairline),
                      ),
                    ),
                    child: Icon(
                      Symbols.close_rounded,
                      size: sizing.dimen(NeriDimen.iconSm),
                      color: context.neri[NeriToken.alert],
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
