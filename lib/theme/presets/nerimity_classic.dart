import 'package:nerimobile/theme/core/theme_spec.dart';
import 'package:nerimobile/theme/core/token.dart';

const nerimityClassicPreset = ThemeSpec(
  id: 'nerimity-classic',
  name: 'Nerimity (Classic)',
  maintainers: ['<none>'],
  values: {
    NeriToken.background: 'hsl(216deg 9% 8%)',
    NeriToken.pane: 'hsl(216deg 8% 15%)',
    NeriToken.sidePane: 'hsl(216deg 7.82% 12.55%)',

    NeriToken.header: 'hsla(216deg 8% 15% / 80%)',
    NeriToken.headerBlurDisabled: 'hsl(216deg 8% 15%)',
    NeriToken.tooltip: 'rgb(40, 40, 40)',

    NeriToken.chatInputBackground: 'rgba(0, 0, 0, 0.86)',
    NeriToken.chatInputBackgroundBlurDisabled: 'black',
    NeriToken.chatMarkupBarBackground: 'rgba(0, 0, 0, 0.86)',
    NeriToken.chatMarkupBarBackgroundBlurDisabled: 'black',

    NeriToken.messageHoverBackground: 'rgba(255, 255, 255, 0.03)',
    NeriToken.messageFloatingOptionsBackground: 'rgb(40, 40, 40)',

    NeriToken.primary: '#4c93ff',
    NeriToken.primaryDark: '#2d3746',

    NeriToken.alert: '#eb6e6e',
    NeriToken.alertDark: '#3e2626',

    NeriToken.warn: '#ff8f2c',
    NeriToken.warnDark: '#3a3229',

    NeriToken.success: '#78e380',
    NeriToken.successDark: '#1c221d',

    NeriToken.statusOffline: '#adadad',
    NeriToken.statusOnline: '#78e380',
    NeriToken.statusLookingToPlay: '#78a5e3',
    NeriToken.statusAwayFromKeyboard: '#e3a878',
    NeriToken.statusDoNotDisturb: '#e37878',

    NeriToken.text: 'white',
    NeriToken.content: 'rgba(255, 255, 255, 0.8)',
    NeriToken.sidePaneText: 'white',
    NeriToken.typingIndicator: 'white',
    NeriToken.typingIndicatorSecondary: 'rgba(255, 255, 255, 0.7)',

    NeriToken.markupCodeBackground: 'rgba(0, 0, 0, 0.6)',
    NeriToken.markupCodeblockBackground: 'rgba(0, 0, 0, 0.6)',
    NeriToken.markupMentionBackground: 'rgba(0, 0, 0, 0.2)',
    NeriToken.markupMentionBackgroundHover: 'rgba(0, 0, 0, 0.6)',
    NeriToken.markupSpoilerBackground: '#0e0f10',
    NeriToken.markupSpoilerBackgroundHover: '#1c1e20',

    NeriToken.drawerItemBackground: 'rgba(66, 70, 76, 0.6)',
    NeriToken.drawerItemHoverBackground: 'rgba(66, 70, 76, 0.4)',
  },
);
