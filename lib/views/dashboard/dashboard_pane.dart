import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nerimobile/stores/dashboard/dashboard_page_store.dart';

import 'package:nerimobile/theme/core/theme_data.dart';
import 'package:nerimobile/theme/core/token.dart';
import 'package:nerimobile/theme/sizing/breakpoints.dart';
import 'package:nerimobile/theme/sizing/radius.dart';
import 'package:nerimobile/theme/sizing/spacing.dart';
import 'package:nerimobile/views/dashboard/dm_list.dart';
import 'package:nerimobile/views/shell/widgets/panes.dart';

const _indicatorHeight = 8.0;
const _indicatorInactiveWidth = 12.0;
const _indicatorActiveWidth = 40.0;
const _pageAnimation = Duration(milliseconds: 200);

class DashboardPane extends StatelessWidget {
  const DashboardPane({super.key});

  @override
  Widget build(BuildContext context) => NeriWindow.of(context).isDualPane
      ? const DashboardContent()
      : const _DashboardPager();
}

class DashboardContent extends StatelessWidget {
  const DashboardContent({super.key});

  @override
  Widget build(BuildContext context) =>
      const PlaceholderPane(label: 'Dashboard');
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
