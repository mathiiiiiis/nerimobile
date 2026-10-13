import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nerimobile/stores/channel/restore_on_start.dart';

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
  //first read after splash when cache is loaded
  @override
  DashboardPage build() => switch (ref.read(lastPlaceProvider)) {
    (serverId: null, channelId: _) => DashboardPage.directMessages,
    _ => DashboardPage.dashboard,
  };

  void setPage(DashboardPage page) => state = page;
}
