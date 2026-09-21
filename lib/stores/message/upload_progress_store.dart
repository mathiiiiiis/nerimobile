import 'package:flutter_riverpod/flutter_riverpod.dart';

//keeps progress updates out of message list
final uploadProgressProvider = NotifierProvider.autoDispose
    .family<UploadProgressNotifier, double?, String>(
      UploadProgressNotifier.new,
    );

class UploadProgressNotifier extends Notifier<double?> {
  UploadProgressNotifier(this.localId);

  final String localId;

  @override
  double? build() => null;

  void report(double? progress) => state = progress;
}
