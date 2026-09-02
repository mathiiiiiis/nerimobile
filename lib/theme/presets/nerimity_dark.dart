import 'package:nerimobile/theme/core/theme_spec.dart';
import 'package:nerimobile/theme/core/token.dart';

const nerimityDarkPreset = ThemeSpec(
  id: 'nerimity-dark',
  name: 'Nerimity',
  maintainers: ['<none>'],
  variables: {
    'background': 'black',
    'item-bg': 'rgba(255, 255, 255, 0.1)',
    'gray-50': 'hsl(220, 0%, 95%)',
    'gray-100': 'hsl(220, 0%, 90%)',
    'gray-200': 'hsl(220, 0%, 80%)',
    'gray-300': 'hsl(220, 0%, 70%)',
    'gray-400': 'hsl(220, 0%, 50%)',
    'gray-500': 'hsl(220, 0%, 40%)',
    'gray-600': 'hsl(220, 0%, 30%)',
    'gray-700': 'hsl(220, 0%, 20%)',
    'gray-800': 'hsl(220, 0%, 10%)',
    'gray-850': 'hsl(220, 0%, 7.5%)',
    'gray-900': 'hsl(0, 0%, 5%)',
  },
  values: {
    NeriToken.background: 'var(--background)',
    NeriToken.pane: 'var(--background)',
    NeriToken.sidePane: 'var(--background)',
    NeriToken.rail: 'var(--background)',

    NeriToken.tooltip: 'var(--gray-900)',

    NeriToken.chatInputBackground: 'black',
    NeriToken.chatInputBackgroundBlurDisabled: 'black',

    NeriToken.primary: '#3e88ff',
    NeriToken.primaryDark: '#0b1a33',

    NeriToken.alert: '#eb5c5c',
    NeriToken.warn: '#f1750f',
    NeriToken.success: '#4bba5b',

    NeriToken.statusOffline: '#adadad',
    NeriToken.statusOnline: '#78e380',
    NeriToken.statusLookingToPlay: '#3b82f6',
    NeriToken.statusAwayFromKeyboard: '#ff8f2c',
    NeriToken.statusDoNotDisturb: '#eb6e6e',

    NeriToken.text: '#ffffff',
    NeriToken.textSecondary: 'hsl(220, 6%, 50%)',
    NeriToken.textTertiary: 'var(--gray-400)',

    NeriToken.markupMentionBackground: 'var(--gray-800)',
    NeriToken.markupMentionBackgroundHover: 'var(--gray-700)',

    NeriToken.drawerItemBackground: 'var(--item-bg)',

    NeriToken.navBackground: 'var(--gray-900)',

    NeriToken.surfaceHover: 'var(--item-bg)',
    NeriToken.divider: 'var(--gray-700)',
    NeriToken.border: 'var(--gray-700)',
  },
);
