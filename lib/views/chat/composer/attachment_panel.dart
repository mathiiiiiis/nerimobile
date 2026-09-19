import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:photo_manager/photo_manager.dart';

import 'package:nerimobile/stores/composer/composer_store.dart';
import 'package:nerimobile/stores/media/recent_media_store.dart';
import 'package:nerimobile/theme/colors/derive.dart';
import 'package:nerimobile/theme/core/theme_data.dart';
import 'package:nerimobile/theme/core/token.dart';
import 'package:nerimobile/theme/sizing/border.dart';
import 'package:nerimobile/theme/sizing/dimens.dart';
import 'package:nerimobile/theme/sizing/radius.dart';
import 'package:nerimobile/theme/sizing/spacing.dart';
import 'package:nerimobile/theme/typography/text_styles.dart';
import 'package:nerimobile/utils/format.dart';
import 'package:nerimobile/views/press_scale.dart';

const _columns = 3;
const _loadMoreRows = 3;
const _visibleRows = 2;
const _filesPressScale = 0.97;
const _markerOpacity = 0.55;
const _selectedOpacity = 0.3;

enum AttachmentPicker { closed, collapsed, expanded }

class AttachmentPickerState {
  const AttachmentPickerState({required this.mode, this.selected});

  final AttachmentPicker mode;
  final AssetEntity? selected;

  bool get expanded => mode == AttachmentPicker.expanded;
  bool get open => mode != AttachmentPicker.closed;
}

final attachmentPickerProvider =
    NotifierProvider.family<
      AttachmentPickerNotifier,
      AttachmentPickerState,
      String
    >(AttachmentPickerNotifier.new);

class AttachmentPickerNotifier extends Notifier<AttachmentPickerState> {
  AttachmentPickerNotifier(this.channelId);

  final String channelId;

  @override
  AttachmentPickerState build() =>
      const AttachmentPickerState(mode: AttachmentPicker.closed);

  void toggle() => state.open ? close() : collapse();

  void expand() => _mode(AttachmentPicker.expanded);
  void collapse() => _mode(AttachmentPicker.collapsed);

  void close() =>
      state = const AttachmentPickerState(mode: AttachmentPicker.closed);

  void select(AssetEntity? asset) => state = AttachmentPickerState(
    mode: state.mode,
    selected: state.selected?.id == asset?.id ? null : asset,
  );

  void _mode(AttachmentPicker mode) =>
      state = AttachmentPickerState(mode: mode, selected: state.selected);
}

class AttachmentPanel extends ConsumerWidget {
  const AttachmentPanel({super.key, required this.channelId});

  final String channelId;

  AttachmentPickerNotifier _picker(WidgetRef ref) =>
      ref.read(attachmentPickerProvider(channelId).notifier);

  Future<void> _pickFile(WidgetRef ref) async {
    await PhotoManager.requestPermissionExtend(
      requestOption: PermissionRequestOption(
        androidPermission: AndroidPermission(
          type: RequestType.common | RequestType.audio,
          mediaLocation: false,
        ),
      ),
    );

    final picked = await FilePicker.pickFile();
    _use(ref, picked?.path);
  }

  Future<void> _takePhoto(WidgetRef ref) async {
    final photo = await ImagePicker().pickImage(source: ImageSource.camera);
    _use(ref, photo?.path);
  }

  Future<void> _useAsset(WidgetRef ref, AssetEntity asset) async =>
      _use(ref, (await asset.file)?.path);

  void _use(WidgetRef ref, String? path) {
    if (path == null) return;

    ref.read(composerProvider(channelId).notifier).attach(path);
    _picker(ref).close();
  }

  void _tapAsset(WidgetRef ref, AssetEntity asset, {required bool expanded}) {
    if (expanded) return _picker(ref).select(asset);

    _useAsset(ref, asset);
  }

  void _onDragEnd(WidgetRef ref, DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity < 0) return _picker(ref).expand();
    if (velocity <= 0) return;

    ref.read(attachmentPickerProvider(channelId)).expanded
        ? _picker(ref).collapse()
        : _picker(ref).close();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sizing = context.neriSize;
    final gap = sizing.space(NeriSpacingRole.sm);
    final recents = ref.watch(recentMediaProvider);
    final picker = ref.watch(attachmentPickerProvider(channelId));
    final expanded = picker.expanded;
    final selected = picker.selected;
    final radius = Radius.circular(sizing.radius(NeriRadiusRole.xl));

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: context.neri[NeriToken.pane],
        borderRadius: expanded
            ? BorderRadius.only(topLeft: radius, topRight: radius)
            : null,
      ),
      child: SafeArea(
        top: false,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onVerticalDragEnd: (details) => _onDragEnd(ref, details),
          child: Padding(
            padding: EdgeInsets.fromLTRB(gap, expanded ? gap : 0, gap, gap),
            child: Column(
              mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: gap,
              children: [
                const _DragHandle(),
                if (expanded)
                  _ExpandedHeader(
                    onBack: _picker(ref).collapse,
                    onAlbums: () => _pickFile(ref),
                  )
                else
                  _FilesButton(onTap: () => _pickFile),
                if (recents.hasError)
                  _AccessNotice(onTap: PhotoManager.openSetting)
                else if (expanded)
                  Expanded(
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: _grid(context, ref, recents, expanded: true),
                        ),
                        if (selected case final selected?)
                          Positioned(
                            right: gap,
                            bottom: gap,
                            child: _SendButton(
                              onTap: () => _useAsset(ref, selected),
                            ),
                          ),
                      ],
                    ),
                  )
                else
                  _grid(context, ref, recents, expanded: false),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _grid(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<AssetEntity>> recents, {
    required bool expanded,
  }) {
    final sizing = context.neriSize;
    final gap = sizing.space(NeriSpacingRole.sm);
    final selected = ref.watch(
      attachmentPickerProvider(channelId).select((p) => p.selected),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = (constraints.maxWidth - gap * (_columns - 1)) / _columns;

        final grid = GridView.builder(
          padding: EdgeInsets.zero,
          physics: expanded
              ? const AlwaysScrollableScrollPhysics()
              : const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _columns,
            mainAxisSpacing: gap,
            crossAxisSpacing: gap,
          ),
          itemCount: (recents.value?.length ?? 0) + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return _Card(
                onTap: () => _takePhoto(ref),
                child: Center(
                  child: Icon(
                    Symbols.photo_camera_rounded,
                    fill: 1,
                    size: sizing.dimen(NeriDimen.iconMd),
                    color: context.neri[NeriToken.textSecondary],
                  ),
                ),
              );
            }

            final asset = recents.value?.elementAtOrNull(index - 1);
            if (asset == null) return const _Card();

            return _Card(
              onTap: () => _tapAsset(ref, asset, expanded: expanded),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _Thumbnail(asset: asset, size: size),
                  if (asset.type == AssetType.video)
                    _VideoMarker(duration: asset.videoDuration),
                  if (selected?.id == asset.id) const _Selected(),
                ],
              ),
            );
          },
        );

        if (expanded) {
          return NotificationListener<ScrollUpdateNotification>(
            onNotification: (notification) {
              final metrics = notification.metrics;
              final trigger = (size + gap) * _loadMoreRows;
              if (metrics.extentAfter < trigger) {
                ref.read(recentMediaProvider.notifier).loadMore();
              }

              return false;
            },
            child: grid,
          );
        }

        return SizedBox(
          height: size * _visibleRows + gap * (_visibleRows - 1),
          child: grid,
        );
      },
    );
  }
}

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    final sizing = context.neriSize;
    final height = sizing.border(NeriBorderRole.thick);

    return Center(
      child: Container(
        width: sizing.space(NeriSpacingRole.xxl),
        height: height,
        decoration: BoxDecoration(
          color: context.neri[NeriToken.divider],
          borderRadius: BorderRadius.circular(height),
        ),
      ),
    );
  }
}

class _Thumbnail extends ConsumerStatefulWidget {
  const _Thumbnail({required this.asset, required this.size});

  final AssetEntity asset;
  final double size;

  @override
  ConsumerState<_Thumbnail> createState() => _ThumbnailState();
}

class _ThumbnailState extends ConsumerState<_Thumbnail> {
  late final RecentMediaNotifier _media = ref.read(
    recentMediaProvider.notifier,
  );
  late final Future<Uint8List?> _data = _media.thumbnail(widget.asset);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _data,
      initialData: _media.cachedThumbnail(widget.asset),
      builder: (context, snapshot) {
        final thumbnail = snapshot.data;
        if (thumbnail == null) return const SizedBox.shrink();

        return Image.memory(
          thumbnail,
          fit: BoxFit.cover,
          gaplessPlayback: true,
          cacheWidth: (widget.size * MediaQuery.devicePixelRatioOf(context))
              .round(),
        );
      },
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({this.child, this.onTap});

  final Widget? child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final sizing = context.neriSize;

    return GestureDetector(
      onTap: onTap,
      child: PressScale(
        scale: _filesPressScale,
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: context.neri[NeriToken.card],
            borderRadius: sizing.rounded(NeriRadiusRole.md),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _VideoMarker extends StatelessWidget {
  const _VideoMarker({required this.duration});

  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final sizing = context.neriSize;
    final gap = sizing.space(NeriSpacingRole.xs);

    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: EdgeInsets.all(gap),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: gap, vertical: gap / 2),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: _markerOpacity),
            borderRadius: BorderRadius.circular(
              sizing.radius(NeriRadiusRole.full),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: gap / 2,
            children: [
              Icon(
                Symbols.play_arrow_rounded,
                fill: 1,
                size: sizing.dimen(NeriDimen.mentionIcon),
                color: Colors.white,
              ),
              Text(
                formatDuration(duration),
                style: context.neriText[NeriTextRole.labelSmall].copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilesButton extends StatelessWidget {
  const _FilesButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.neri;
    final sizing = context.neriSize;

    return GestureDetector(
      onTap: onTap,
      child: PressScale(
        scale: _filesPressScale,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: sizing.space(NeriSpacingRole.md),
            vertical: sizing.space(NeriSpacingRole.md),
          ),
          decoration: BoxDecoration(
            color: colors[NeriToken.card],
            borderRadius: sizing.rounded(NeriRadiusRole.lg),
          ),
          child: Row(
            spacing: sizing.space(NeriSpacingRole.sm),
            children: [
              Icon(
                Symbols.attach_file_rounded,
                size: sizing.dimen(NeriDimen.iconSm),
                color: colors[NeriToken.textSecondary],
              ),
              Text(
                'Files', //TODO: add l10n
                style: context.neriText[NeriTextRole.bodyLarge].copyWith(
                  color: colors[NeriToken.textSecondary],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Selected extends StatelessWidget {
  const _Selected();

  @override
  Widget build(BuildContext context) {
    final colors = context.neri;
    final sizing = context.neriSize;

    return Container(
      color: colors[NeriToken.primary].withValues(alpha: _selectedOpacity),
      alignment: Alignment.center,
      child: Icon(
        Symbols.check_circle_rounded,
        fill: 1,
        size: sizing.dimen(NeriDimen.iconMd),
        color: colors[NeriToken.primary],
      ),
    );
  }
}

class _ExpandedHeader extends StatelessWidget {
  const _ExpandedHeader({required this.onBack, required this.onAlbums});

  final VoidCallback onBack;
  final VoidCallback onAlbums;

  @override
  Widget build(BuildContext context) {
    final colors = context.neri;
    final sizing = context.neriSize;
    return Row(
      children: [
        GestureDetector(
          onTap: onBack,
          child: PressScale(
            child: Icon(
              Symbols.arrow_back_rounded,
              size: sizing.dimen(NeriDimen.iconSm),
              color: colors[NeriToken.text],
            ),
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: onAlbums,
          child: PressScale(
            scale: _filesPressScale,
            child: Text(
              'All albums', //TODO: add l10n
              style: context.neriText[NeriTextRole.bodyLarge].copyWith(
                color: colors[NeriToken.primary],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.neri;
    final sizing = context.neriSize;
    final size = sizing.dimen(NeriDimen.avatarMd);

    return GestureDetector(
      onTap: onTap,
      child: PressScale(
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colors[NeriToken.primary],
            shape: BoxShape.circle,
          ),
          child: Icon(
            Symbols.send_rounded,
            fill: 1,
            size: sizing.dimen(NeriDimen.iconMd),
            color: onColor(colors[NeriToken.primary]),
          ),
        ),
      ),
    );
  }
}

class _AccessNotice extends StatelessWidget {
  const _AccessNotice({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.neri;

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.all(context.neriSize.space(NeriSpacingRole.md)),
        child: Text(
          'Allow photo access to pick from your gallery', //TODO: add l10n
          textAlign: TextAlign.center,
          style: context.neriText[NeriTextRole.bodyMedium].copyWith(
            color: colors[NeriToken.textSecondary],
          ),
        ),
      ),
    );
  }
}
