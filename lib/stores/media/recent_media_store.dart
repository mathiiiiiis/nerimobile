import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';

const _pageSize = 60;
const _thumbnail = ThumbnailSize.square(320);

final recentMediaProvider =
    AsyncNotifierProvider<RecentMediaNotifier, List<AssetEntity>>(
      RecentMediaNotifier.new,
    );

class RecentMediaNotifier extends AsyncNotifier<List<AssetEntity>> {
  final _thumbnails = <String, Uint8List?>{};

  AssetPathEntity? _album;
  var _hasMore = true;
  var _loadingMore = false;

  @override
  Future<List<AssetEntity>> build() {
    ref.keepAlive();
    PhotoManager.addChangeCallback(_onLibraryChanged);
    PhotoManager.startChangeNotify();
    ref.onDispose(() {
      PhotoManager.removeChangeCallback(_onLibraryChanged);
      PhotoManager.stopChangeNotify();
    });

    return _load();
  }

  Uint8List? cachedThumbnail(AssetEntity asset) => _thumbnails[asset.id];

  //load thumnails on demand to avoid stalling the first open
  Future<Uint8List?> thumbnail(AssetEntity asset) async {
    if (_thumbnails.containsKey(asset.id)) return _thumbnails[asset.id];

    return _thumbnails[asset.id] = await asset.thumbnailDataWithSize(
      _thumbnail,
    );
  }

  Future<void> loadMore() async {
    final album = _album;
    final loaded = state.value;
    if (album == null || loaded == null) return;
    if (!_hasMore || _loadingMore) return;

    _loadingMore = true;
    try {
      final next = await album.getAssetListRange(
        start: loaded.length,
        end: loaded.length + _pageSize,
      );
      _hasMore = next.length == _pageSize;
      state = AsyncValue.data([...loaded, ...next]);
    } finally {
      _loadingMore = false;
    }
  }

  void _onLibraryChanged(MethodCall _) => refresh();

  Future<void> refresh() async {
    _thumbnails.clear();
    _hasMore = true;
    state = AsyncValue.data(await _load());
  }

  Future<List<AssetEntity>> _load() async {
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

    final album = _album = albums.first;
    final assets = await album.getAssetListRange(start: 0, end: _pageSize);
    _hasMore = assets.length == _pageSize;

    return assets;
  }
}

class _NoAccess implements Exception {
  const _NoAccess();
}
