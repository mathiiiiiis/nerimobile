import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import 'package:nerimobile/theme/colors/derive.dart';
import 'package:nerimobile/stores/connection/connection_store.dart';
import 'package:nerimobile/theme/core/theme_data.dart';
import 'package:nerimobile/theme/core/token.dart';
import 'package:nerimobile/theme/sizing/dimens.dart';
import 'package:nerimobile/theme/sizing/radius.dart';
import 'package:nerimobile/theme/sizing/spacing.dart';
import 'package:nerimobile/theme/typography/text_styles.dart';

const _successDuration = Duration(seconds: 1);
const _slide = Duration(milliseconds: 200);

class ConnectionBanner extends ConsumerStatefulWidget {
  const ConnectionBanner({super.key});

  @override
  ConsumerState<ConnectionBanner> createState() => _ConnectionBannerState();
}

class _ConnectionBannerState extends ConsumerState<ConnectionBanner> {
  Timer? _hide;
  bool _hidden = false;

  @override
  void dispose() {
    _hide?.cancel();
    super.dispose();
  }

  void _scheduleHide() {
    _hide?.cancel();
    _hide = Timer(_successDuration, () {
      if (mounted) setState(() => _hidden = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(connectionProvider, (_, next) {
      _hide?.cancel();
      setState(() => _hidden = false);
      if (next is Authenticated) _scheduleHide();
    });

    final connection = ref.watch(connectionProvider);
    final visible = connection is! Disconnected && !_hidden;

    final colors = context.neri;
    final (label, color, icon) = switch (connection) {
      Disconnected() => ('', colors[NeriToken.warn], Symbols.sync_rounded),
      Connecting(:final retrying, error: final String error) => (
        error,
        colors[NeriToken.alert],
        Symbols.cloud_off_rounded,
      ),
      Connecting(:final retrying) => (
        retrying ? 'Reconncting...' : 'Connecting...', //TODO: add l10n
        colors[NeriToken.warn],
        Symbols.sync_rounded,
      ),
      Authenticating(:final queuePosition) => (
        queuePosition == null
            ? 'Authenticating...'
            : 'In Queue: $queuePosition', //TODO: add l10n
        colors[NeriToken.warn],
        Symbols.hourglass_empty_rounded,
      ),
      Authenticated() => (
        'Connected!',
        colors[NeriToken.success],
        Symbols.check_rounded,
      ), //TODO: add l10n
      ConnectionFailed(:final message) => (
        message,
        colors[NeriToken.alert],
        Symbols.gpp_maybe_rounded,
      ),
    };

    return AnimatedSlide(
      duration: _slide,
      curve: Curves.easeOut,
      offset: visible ? Offset.zero : const Offset(0.2, 0),
      child: AnimatedOpacity(
        duration: _slide,
        opacity: visible ? 1 : 0,
        child: _Pill(label: label, color: color, icon: icon),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.color, required this.icon});

  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.neri;
    final sizing = context.neriSize;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: sizing.space(NeriSpacingRole.md),
        vertical: sizing.space(NeriSpacingRole.xs),
      ),
      decoration: BoxDecoration(
        color: mix(colors[NeriToken.background], color, 0.22),
        borderRadius: sizing.rounded(NeriRadiusRole.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: sizing.space(NeriSpacingRole.xs),
        children: [
          Icon(icon, size: sizing.dimen(NeriDimen.iconSm), color: color),
          Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: context.neriText[NeriTextRole.bodyMedium].copyWith(
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
