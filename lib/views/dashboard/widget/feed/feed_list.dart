import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:nerimobile/stores/dashboard/feed_store.dart';
import 'package:nerimobile/theme/core/theme_data.dart';
import 'package:nerimobile/theme/core/token.dart';
import 'package:nerimobile/theme/sizing/spacing.dart';
import 'package:nerimobile/theme/typography/text_styles.dart';
import 'package:nerimobile/views/dashboard/widget/feed/feed_skeleton.dart';
import 'package:nerimobile/views/empty_state.dart';
import 'package:nerimobile/views/post/post_card.dart';

class FeedList extends ConsumerWidget {
  const FeedList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feed = ref.watch(feedProvider);
    final gap = context.neriSize.space(NeriSpacingRole.md);

    return SliverPadding(
      padding: EdgeInsets.fromLTRB(gap, gap, gap, 0),
      sliver: SliverMainAxisGroup(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(bottom: gap),
              child: const _SectionLabel(label: 'Feed'), //TODO: add l10n
            ),
          ),
          SliverList.separated(
            itemCount: feed.posts.length,
            itemBuilder: (context, index) => PostCard(post: feed.posts[index]),
            separatorBuilder: (_, _) => SizedBox(height: gap),
          ),
          if (feed.posts.isEmpty && !feed.hasMore)
            const SliverToBoxAdapter(
              child: EmptyState(
                icon: Symbols.rss_feed_rounded,
                message: 'Nothing in your feed yet >_<', //TODO: add l10n
                hint: 'Posts from people you follow show up here.',
              ),
            ),
          if (feed.hasMore)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: feed.posts.isEmpty ? 0 : gap),
                child: const FeedSkeleton(),
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Text(
    label,
    style: context.neriText[NeriTextRole.titleLarge].copyWith(
      color: context.neri[NeriToken.text],
    ),
  );
}
