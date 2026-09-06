enum ThemeCategory {
  surface,
  overlay,
  input,
  message,
  accent,
  alert,
  warn,
  success,
  status,
  text,
  markup,
  drawer,
  navigation,
  state,
}

enum NeriToken {
  background(ThemeCategory.surface),
  pane(ThemeCategory.surface),
  card(ThemeCategory.surface),
  sidePane(ThemeCategory.surface),
  rail(ThemeCategory.surface),

  header(ThemeCategory.overlay),
  headerBlurDisabled(ThemeCategory.overlay),
  tooltip(ThemeCategory.overlay),
  scrim(ThemeCategory.overlay),
  shadow(ThemeCategory.overlay),

  chatInputBackground(ThemeCategory.input),
  chatInputBackgroundBlurDisabled(ThemeCategory.input),
  chatMarkupBarBackground(ThemeCategory.input),
  chatMarkupBarBackgroundBlurDisabled(ThemeCategory.input),

  messageHoverBackground(ThemeCategory.message),
  messageFloatingOptionsBackground(ThemeCategory.message),
  messagePending(ThemeCategory.message),
  messageMentionBackground(ThemeCategory.message),
  messageMentionIndicator(ThemeCategory.message),

  primary(ThemeCategory.accent),
  primaryDark(ThemeCategory.accent),

  alert(ThemeCategory.alert),
  alertDark(ThemeCategory.alert),

  warn(ThemeCategory.warn),
  warnDark(ThemeCategory.warn),

  success(ThemeCategory.success),
  successDark(ThemeCategory.success),

  statusOffline(ThemeCategory.status),
  statusOnline(ThemeCategory.status),
  statusLookingToPlay(ThemeCategory.status),
  statusAwayFromKeyboard(ThemeCategory.status),
  statusDoNotDisturb(ThemeCategory.status),

  text(ThemeCategory.text),
  textSecondary(ThemeCategory.text),
  textTertiary(ThemeCategory.text),
  textPlaceholder(ThemeCategory.text),
  content(ThemeCategory.text),
  sidePaneText(ThemeCategory.text),
  typingIndicator(ThemeCategory.text),
  typingIndicatorSecondary(ThemeCategory.text),

  markupCodeBackground(ThemeCategory.markup),
  markupCodeblockBackground(ThemeCategory.markup),
  markupMentionBackground(ThemeCategory.markup),
  markupMentionBackgroundHover(ThemeCategory.markup),
  markupSpoilerBackground(ThemeCategory.markup),
  markupSpoilerBackgroundHover(ThemeCategory.markup),

  drawerItemBackground(ThemeCategory.drawer),
  drawerItemHoverBackground(ThemeCategory.drawer),
  drawerItemText(ThemeCategory.drawer),

  navBackground(ThemeCategory.navigation),
  navIndicator(ThemeCategory.navigation),

  surfaceHover(ThemeCategory.state),
  surfacePressed(ThemeCategory.state),
  divider(ThemeCategory.state),
  border(ThemeCategory.state),
  focusRing(ThemeCategory.state),
  unreadDot(ThemeCategory.state),
  mentionBadge(ThemeCategory.state),
  avatarPlaceholder(ThemeCategory.state);

  const NeriToken(this.category);

  final ThemeCategory category;
}
