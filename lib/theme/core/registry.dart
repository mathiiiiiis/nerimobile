import 'package:flutter/painting.dart';

import 'package:nerimobile/theme/colors/derive.dart';
import 'package:nerimobile/theme/core/token.dart';

typedef TokenResolve = Color Function(NeriToken token);
typedef TokenDerivation = Color Function(TokenResolve resolve);

Color deriveToken(NeriToken token, TokenResolve resolve) {
  final derivation = _derivations[token];
  assert(derivation != null, 'missing derivation for $token');
  return derivation?.call(resolve) ?? const Color(0xFF000000);
}

const _black = Color(0xFF000000);
const _white = Color(0xFFFFFFFF);

final Map<NeriToken, TokenDerivation> _derivations = {
  NeriToken.background: (_) => _black,
  NeriToken.pane: (resolve) => resolve(NeriToken.background),
  NeriToken.card: (resolve) => resolve(NeriToken.pane),
  NeriToken.sidePane: (resolve) => lift(resolve(NeriToken.background), 0.04),
  NeriToken.rail: (resolve) => resolve(NeriToken.sidePane),

  NeriToken.header: (resolve) => dim(resolve(NeriToken.pane), 0.8),
  NeriToken.headerBlurDisabled: (resolve) => resolve(NeriToken.pane),
  NeriToken.tooltip: (resolve) => lift(resolve(NeriToken.background), 0.08),
  NeriToken.scrim: (_) => const Color(0x80000000),
  NeriToken.shadow: (_) => const Color(0x66000000),

  NeriToken.chatInputBackground: (resolve) => resolve(NeriToken.pane),
  NeriToken.chatInputBackgroundBlurDisabled: (resolve) =>
      resolve(NeriToken.pane),
  NeriToken.chatMarkupBarBackground: (resolve) =>
      resolve(NeriToken.chatInputBackground),
  NeriToken.chatMarkupBarBackgroundBlurDisabled: (resolve) =>
      resolve(NeriToken.chatInputBackgroundBlurDisabled),

  NeriToken.messageHoverBackground: (resolve) =>
      dim(resolve(NeriToken.text), 0.04),
  NeriToken.messageFloatingOptionsBackground: (resolve) =>
      resolve(NeriToken.tooltip),
  NeriToken.messagePending: (resolve) => dim(resolve(NeriToken.text), 0.45),

  NeriToken.primary: (_) => const Color(0xFF4C93FF),
  NeriToken.primaryDark: (resolve) =>
      mix(resolve(NeriToken.background), resolve(NeriToken.primary), 0.22),

  NeriToken.alert: (_) => const Color(0xFFEB6E6E),
  NeriToken.alertDark: (resolve) =>
      mix(resolve(NeriToken.background), resolve(NeriToken.alert), 0.22),

  NeriToken.warn: (_) => const Color(0xFFFF8F2C),
  NeriToken.warnDark: (resolve) =>
      mix(resolve(NeriToken.background), resolve(NeriToken.warn), 0.22),

  NeriToken.success: (_) => const Color(0xFF78E280),
  NeriToken.successDark: (resolve) =>
      mix(resolve(NeriToken.background), resolve(NeriToken.success), 0.22),

  NeriToken.statusOffline: (_) => const Color(0xFFADADAD),
  NeriToken.statusOnline: (_) => const Color(0xFF78E380),
  NeriToken.statusLookingToPlay: (_) => const Color(0xFF78A5E3),
  NeriToken.statusAwayFromKeyboard: (_) => const Color(0xFFE3A878),
  NeriToken.statusDoNotDisturb: (_) => const Color(0xFFE37878),

  NeriToken.text: (_) => _white,
  NeriToken.textSecondary: (resolve) => dim(resolve(NeriToken.text), 0.7),
  NeriToken.textTertiary: (resolve) => dim(resolve(NeriToken.text), 0.5),
  NeriToken.textPlaceholder: (resolve) => dim(resolve(NeriToken.text), 0.38),
  NeriToken.content: (resolve) => dim(resolve(NeriToken.text), 0.8),
  NeriToken.sidePaneText: (resolve) => resolve(NeriToken.text),
  NeriToken.typingIndicator: (resolve) => resolve(NeriToken.text),
  NeriToken.typingIndicatorSecondary: (resolve) =>
      dim(resolve(NeriToken.text), 0.7),

  NeriToken.markupCodeBackground: (resolve) =>
      dim(resolve(NeriToken.text), 0.12),
  NeriToken.markupCodeblockBackground: (resolve) =>
      resolve(NeriToken.markupCodeBackground),
  NeriToken.markupMentionBackground: (resolve) =>
      dim(resolve(NeriToken.text), 0.1),
  NeriToken.markupMentionBackgroundHover: (resolve) =>
      dim(resolve(NeriToken.text), 0.16),
  NeriToken.markupSpoilerBackground: (resolve) =>
      lift(resolve(NeriToken.background), 0.06),
  NeriToken.markupSpoilerBackgroundHover: (resolve) =>
      lift(resolve(NeriToken.background), 0.12),

  NeriToken.drawerItemBackground: (resolve) =>
      dim(resolve(NeriToken.text), 0.06),
  NeriToken.drawerItemHoverBackground: (resolve) =>
      dim(resolve(NeriToken.text), 0.1),
  NeriToken.drawerItemText: (resolve) => dim(resolve(NeriToken.text), 0.65),

  NeriToken.navBackground: (resolve) => resolve(NeriToken.sidePane),
  NeriToken.navIndicator: (resolve) => dim(resolve(NeriToken.primary), 0.18),

  NeriToken.surfaceHover: (resolve) => dim(resolve(NeriToken.text), 0.05),
  NeriToken.surfacePressed: (resolve) => dim(resolve(NeriToken.text), 0.08),
  NeriToken.divider: (resolve) => dim(resolve(NeriToken.text), 0.1),
  NeriToken.border: (resolve) => dim(resolve(NeriToken.text), 0.14),
  NeriToken.focusRing: (resolve) => dim(resolve(NeriToken.text), 0.04),
  NeriToken.unreadDot: (resolve) => resolve(NeriToken.text),
  NeriToken.mentionBadge: (resolve) => resolve(NeriToken.alert),
  NeriToken.avatarPlaceholder: (resolve) => resolve(NeriToken.primaryDark),
};
