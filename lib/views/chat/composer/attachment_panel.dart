import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:nerimobile/theme/sizing/border.dart';
import 'package:nerimobile/utils/format.dart';
import 'package:photo_manager/photo_manager.dart';

import 'package:nerimobile/stores/composer/composer_store.dart';
import 'package:nerimobile/stores/media/recent_media_store.dart';
import 'package:nerimobile/theme/core/theme_data.dart';
import 'package:nerimobile/theme/core/token.dart';
import 'package:nerimobile/theme/sizing/dimens.dart';
import 'package:nerimobile/theme/sizing/radius.dart';
import 'package:nerimobile/theme/sizing/spacing.dart';
import 'package:nerimobile/theme/typography/text_styles.dart';
import 'package:nerimobile/views/press_scale.dart';

const _columns = 3;
const _visibleRows = 2;
const _filesPressScale = 0.97;
const _markerOpacity = 0.55;

final attachmentPickerProvider =
    NotifierProvider.family<AttachmentPickerNotifier, bool, String>(
      AttachmentPickerNotifier.new,
    );

class AttachmentPickerNotifier extends Notifier<bool> {
  AttachmentPickerNotifier(this.channelId);

  final String channelId;

  @override
  bool build() => false;

  void toggle() => state = !state;
  void close() => state = false;
}

class AttachmentPanel extends ConsumerWidget {
  const AttachmentPanel({super.key, required this.channelId});

  final String channelId;

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
    ref.read(attachmentPickerProvider(channelId).notifier).close();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sizing = context.neriSize;
    final gap = sizing.space(NeriSpacingRole.sm);
    final recents = ref.watch(recentMediaProvider);

    return Container(
      color: context.neri[NeriToken.pane],
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(gap, 0, gap, gap),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: gap,
            children: [
              const _DragHandle(),
              _FilesButton(onTap: () => _pickFile(ref)),
              if (recents.hasError)
                _AccessNotice(onTap: PhotoManager.openSetting)
              else
                LayoutBuilder(
                  builder: (context, constraints) {
                    final size =
                        (constraints.maxWidth - gap * (_columns - 1)) /
                        _columns;

                    return SizedBox(
                      height: size * _visibleRows + gap * (_visibleRows - 1),
                      child: GridView.builder(
                        padding: EdgeInsets.zero,
                        physics: const NeverScrollableScrollPhysics(),
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
                                  size: sizing.dimen(NeriDimen.iconMd),
                                  color: context.neri[NeriToken.textSecondary],
                                ),
                              ),
                            );
                          }

                          final recent = recents.value?.elementAtOrNull(
                            index - 1,
                          );
                          final thumbnail = recent?.thumbnail;
                          if (thumbnail == null) return const _Card();

                          final asset = recent!.asset;

                          return _Card(
                            onTap: () => _useAsset(ref, asset),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.memory(
                                  thumbnail,
                                  fit: BoxFit.cover,
                                  gaplessPlayback: true,
                                  cacheWidth:
                                      (size *
                                              MediaQuery.devicePixelRatioOf(
                                                context,
                                              ))
                                          .round(),
                                ),
                                if (asset.type == AssetType.video)
                                  _VideoMarker(duration: asset.videoDuration),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
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
