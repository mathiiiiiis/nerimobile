import 'package:flutter_riverpod/flutter_riverpod.dart';

enum DashboardPage {
  directMessages('Direct Messages'), //TODO: add l10n
  dashboard('Dashboard'); //TODO: add l10n

  const DashboardPage(this.label);

  final String label;
}

final dashboardPageProvider =
    NotifierProvider<DashboardPageNotifier, DashboardPage>(
      DashboardPageNotifier.new,
    );

class DashboardPageNotifier extends Notifier<DashboardPage> {
  @override
  DashboardPage build() => DashboardPage.dashboard;

  void setPage(DashboardPage page) => state = page;
}
