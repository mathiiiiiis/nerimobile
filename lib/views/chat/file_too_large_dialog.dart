import 'package:flutter/material.dart';
import 'package:nerimobile/views/modal/confirm_dialog.dart';

Future<void> showFileTooLargeDialog(BuildContext context) => showNoticeDialog(
  context,
  title: 'File too large', //TODO: add l10n
  message:
      'Nerimity stopped your upload. Try sending a smaller file.', //TODO: add l10n
);
