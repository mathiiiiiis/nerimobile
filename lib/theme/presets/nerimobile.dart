import 'package:nerimobile/theme/core/theme_spec.dart';
import 'package:nerimobile/theme/core/token.dart';

const nerimobilePreset = ThemeSpec(
  id: 'nerimobile',
  name: 'Nerimobile',
  maintainers: ['mathis'],
  values: {
    NeriToken.background: '#222222',
    NeriToken.pane: '#2a2a2a',
    NeriToken.card: '#202020',
    NeriToken.sidePane: '#222222',
    NeriToken.rail: '#222222',

    NeriToken.tooltip: '#2d2d2d',

    NeriToken.chatInputBackground: '#8c8c8c',
    NeriToken.chatInputBackgroundBlurDisabled: '#8c8c8c',

    NeriToken.messageFloatingOptionsBackground: '#2d2d2d',

    NeriToken.primary: '#ff5d41',

    NeriToken.alert: '#e03b4b',

    NeriToken.success: '#78e380',

    NeriToken.statusOffline: '#adadad',
    NeriToken.statusOnline: '#78e380',
    NeriToken.statusLookingToPlay: '#78a5e3',
    NeriToken.statusAwayFromKeyboard: '#ffad4e',
    NeriToken.statusDoNotDisturb: '#e37878',

    NeriToken.text: '#ffffff',
    NeriToken.textSecondary: '#bbbbbb',
    NeriToken.textTertiary: '#939393',
    NeriToken.textPlaceholder: '#676767',
    NeriToken.messagePending: '#939393',

    NeriToken.markupSpoilerBackground: '#2a2a2a',
    NeriToken.markupSpoilerBackgroundHover: '#2d2d2d',

    NeriToken.drawerItemBackground: '#464646',
    NeriToken.drawerItemText: '#a4a4a4',

    NeriToken.navBackground: '#222222',

    NeriToken.divider: '#464646',
    NeriToken.border: '#474747',
  },
);
