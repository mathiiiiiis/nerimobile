import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:nerimobile/models/message.dart';
import 'package:nerimobile/views/modal/bottom_sheet.dart';

Future<void> showMessageContextMenu(
  BuildContext context, {
  required Message message,
  required bool local,
}) async {
  final actions = [
    if (message.content.isNotEmpty)
      SheetAction(
        icon: Symbols.content_copy_rounded,
        label: 'Copy text', //TODO: add l10n
        onTap: () => Clipboard.setData(ClipboardData(text: message.content)),
      ),
    if (!local)
      SheetAction(
        icon: Symbols.id_card_rounded,
        label: 'Copy ID', //TODO: add l10n
        onTap: () => Clipboard.setData(ClipboardData(text: message.id)),
      ),
  ];
  if (actions.isEmpty) return;

  await showActionSheet(context, actions: actions);
}
