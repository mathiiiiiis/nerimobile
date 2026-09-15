import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:nerimobile/stores/dashboard/announcement_store.dart';
import 'package:nerimobile/stores/dashboard/dashboard_page_store.dart';
import 'package:nerimobile/stores/dashboard/feed_store.dart';

import 'package:nerimobile/theme/core/theme_data.dart';
import 'package:nerimobile/theme/core/token.dart';
import 'package:nerimobile/theme/sizing/border.dart';
import 'package:nerimobile/theme/sizing/breakpoints.dart';
import 'package:nerimobile/theme/sizing/dimens.dart';
import 'package:nerimobile/theme/sizing/radius.dart';
import 'package:nerimobile/theme/sizing/spacing.dart';
import 'package:nerimobile/views/dashboard/dm_list.dart';
import 'package:nerimobile/views/dashboard/widget/activity_list.dart';
import 'package:nerimobile/views/dashboard/widget/announcement_list.dart';
import 'package:nerimobile/views/dashboard/widget/feed/feed_list.dart';
import 'package:nerimobile/views/shell/app_scaffold.dart';
import 'package:nerimobile/views/shell/destinations.dart';

const _indicatorHeight = 8.0;
const _indicatorInactiveWidth = 12.0;
const _indicatorActiveWidth = 40.0;
const _pageAnimation = Duration(milliseconds: 200);
const _loadMoreExtent = 400.0;
const _backToTopAnimation = Duration(milliseconds: 200);

class DashboardPane extends StatelessWidget {
  const DashboardPane({super.key});

  @override
  Widget build(BuildContext context) => AppScaffold(
    branch: NeriBranch.dashboard,
    listPane: const DmListPane(),
    content: NeriWindow.of(context).isDualPane
        ? const DashboardContent()
        : const _DashboardPager(),
  );
}

class DashboardContent extends ConsumerStatefulWidget {
  const DashboardContent({super.key});

  @override
  ConsumerState<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends ConsumerState<DashboardContent> {
  final _scroll = ScrollController();
  final _scrolledAway = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScrolled);
  }

  @override
  void dispose() {
    _scroll.dispose();
    _scrolledAway.dispose();
    super.dispose();
  }

  void _onScrolled() {
    final position = _scroll.position;

    if (position.extentAfter < _loadMoreExtent) {
      ref.read(feedProvider.notifier).loadMore();
    }

    _scrolledAway.value = position.pixels > position.viewportDimension / 2;
  }

  void _backToTop() {
    final position = _scroll.position;
    final lastScreen = position.viewportDimension;

    if (position.pixels > lastScreen) _scroll.jumpTo(lastScreen);

    _scroll.animateTo(
      0,
      duration: _backToTopAnimation,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final sizing = context.neriSize;
    final inset = _bottomInset(context);

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () => _refresh(ref),
          color: context.neri[NeriToken.primary],
          backgroundColor: context.neri[NeriToken.card],
          child: CustomScrollView(
            controller: _scroll,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: EdgeInsets.only(top: sizing.space(NeriSpacingRole.md)),
                sliver: const SliverToBoxAdapter(child: ActivityList()),
              ),
              const SliverToBoxAdapter(child: AnnouncementList()),
              SliverPadding(
                padding: EdgeInsets.only(
                  bottom: inset + sizing.dimen(NeriDimen.controlSize),
                ),
                sliver: const FeedList(),
              ),
            ],
          ),
        ),
        Positioned(
          right: sizing.space(NeriSpacingRole.md),
          bottom: sizing.space(NeriSpacingRole.md),
          child: ValueListenableBuilder(
            valueListenable: _scrolledAway,
            builder: (context, shown, child) => AnimatedScale(
              scale: shown ? 1 : 0,
              duration: _backToTopAnimation,
              curve: Curves.easeOutBack,
              child: IgnorePointer(ignoring: !shown, child: child),
            ),
            child: _BackToTopButton(onTap: _backToTop),
          ),
        ),
      ],
    );
  }
}

class _BackToTopButton extends StatelessWidget {
  const _BackToTopButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.neri;
    final sizing = context.neriSize;
    final size = sizing.dimen(NeriDimen.controlSize);

    return Material(
      color: colors[NeriToken.text],
      shape: RoundedRectangleBorder(
        borderRadius: sizing.rounded(NeriRadiusRole.md),
        side: BorderSide(
          color: colors[NeriToken.border],
          width: sizing.border(NeriBorderRole.hairline),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: sizing.rounded(NeriRadiusRole.md),
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(
            Symbols.arrow_upward_rounded,
            size: sizing.dimen(NeriDimen.iconSm),
            color: colors[NeriToken.primary],
          ),
        ),
      ),
    );
  }
}

Future<void> _refresh(WidgetRef ref) async {
  await Future.wait([
    ref.read(feedProvider.notifier).refresh(),
    ref.read(announcementsProvider.notifier).refresh(),
  ]);
}

double _bottomInset(BuildContext context) =>
    _indicatorClearance(context) + context.neriSize.space(NeriSpacingRole.md);

double _indicatorClearance(BuildContext context) {
  if (NeriWindow.of(context).isDualPane) return 0;

  final sizing = context.neriSize;

  return _indicatorHeight +
      sizing.space(NeriSpacingRole.sm) * 2 +
      sizing.space(NeriSpacingRole.md) * 2;
}

class _DashboardPager extends ConsumerStatefulWidget {
  const _DashboardPager();

  @override
  ConsumerState<_DashboardPager> createState() => _DashboardPagerState();
}

class _DashboardPagerState extends ConsumerState<_DashboardPager> {
  static const _initialPage = 1;

  void _onPageChanged(int page) {
    setState(() => _page = page);
    ref
        .read(dashboardPageProvider.notifier)
        .setPage(DashboardPage.values[page]);
  }

  final _controller = PageController(initialPage: _initialPage);
  int _page = _initialPage;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sizing = context.neriSize;

    return Stack(
      children: [
        PageView(
          controller: _controller,
          onPageChanged: _onPageChanged,
          children: const [DmListPane(), DashboardContent()],
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: sizing.space(NeriSpacingRole.md),
          child: _PageIndicator(page: _page, count: 2),
        ),
      ],
    );
  }
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({required this.page, required this.count});

  final int page;
  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = context.neri;
    final sizing = context.neriSize;

    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: sizing.space(NeriSpacingRole.sm),
          vertical: sizing.space(NeriSpacingRole.sm),
        ),
        decoration: BoxDecoration(
          color: colors[NeriToken.card],
          borderRadius: sizing.rounded(NeriRadiusRole.full),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: sizing.space(NeriSpacingRole.xs),
          children: [
            for (var index = 0; index < count; index += 1)
              AnimatedContainer(
                duration: _pageAnimation,
                curve: Curves.easeOut,
                width: index == page
                    ? _indicatorActiveWidth
                    : _indicatorInactiveWidth,
                height: _indicatorHeight,
                decoration: BoxDecoration(
                  color: index == page
                      ? colors[NeriToken.text]
                      : colors[NeriToken.textPlaceholder],
                  borderRadius: sizing.rounded(NeriRadiusRole.full),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
