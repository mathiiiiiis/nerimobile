import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';

const _pageSize = 60;
const _thumbnail = ThumbnailSize.square(320);

class RecentMedia {
  const RecentMedia(this.asset, this.thumbnail);

  final AssetEntity asset;
  final Uint8List? thumbnail;
}

final recentMediaProvider =
    AsyncNotifierProvider<RecentMediaNotifier, List<RecentMedia>>(
      RecentMediaNotifier.new,
    );

class RecentMediaNotifier extends AsyncNotifier<List<RecentMedia>> {
  @override
  Future<List<RecentMedia>> build() {
    ref.keepAlive();
    PhotoManager.addChangeCallback(_onLibraryChanged);
    PhotoManager.startChangeNotify();
    ref.onDispose(() {
      PhotoManager.removeChangeCallback(_onLibraryChanged);
      PhotoManager.stopChangeNotify();
    });

    return _load();
  }

  void _onLibraryChanged(MethodCall _) => refresh();

  Future<void> refresh() async {
    state = AsyncValue.data(await _load());
  }

  Future<List<RecentMedia>> _load() async {
    final permission = await PhotoManager.requestPermissionExtend();
    if (!permission.hasAccess) throw const _NoAccess();

    final albums = await PhotoManager.getAssetPathList(
      onlyAll: true,
      type: RequestType.common,
      filterOption: FilterOptionGroup(
        orders: const [
          OrderOption(type: OrderOptionType.createDate, asc: false),
        ],
      ),
    );
    if (albums.isEmpty) return const [];

    final assets = await albums.first.getAssetListRange(
      start: 0,
      end: _pageSize,
    );
    return [
      for (final asset in assets)
        RecentMedia(asset, await asset.thumbnailDataWithSize(_thumbnail)),
    ];
  }
}

class _NoAccess implements Exception {
  const _NoAccess();
}
