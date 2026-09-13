# TODO

## Bugs

- [ ] Connection drops some time after switching apps
- [ ] Reconnect gets stuck on `Couldn't connect` until app is backgrounded
      and foregrounded a few times
- [ ] Messages sent while away do not appear after a reconnect
- [ ] Server channel mention counts undercount, `isMentioned` misses `[@:e]`,
      role mentions and reply mentions
- [ ] Scroll to message does not paginate to a target that is not loaded yet
- [ ] Inline code spans never form
- [ ] Heading in a custom status keeps its block spacer and font size

## Features

- [ ] DM list caching and skeleton loading, plus pattern for every new list
- [ ] Context menu(s)
- [ ] Typing Indicator
- [ ] Swipe to reply (short fast swipe), swipe to edit (longer swipe)
- [ ] Dashboard
- [ ] Servers:
  - [ ] Channel listing
  - [ ] Members list
  - [ ] Writing
  - [ ] `ChannelHeader` for not just DM
- [ ] YouTube Embed:
  - [ ] Hyprlink Title (stripped tracking)
  - [ ] Cover card: thumbnail, play button (`youtube_explore_dart` maybe?)

## Markup

- [ ] Custom entity types (some still render literal):
  - [ ] `r` role mentions
  - [ ] `q` quoted messages
  - [ ] `link` (with `->` syntax)
  - [ ] any kind of timestamp
  - [ ] `ruby`
  - [ ] `vertical`
- [ ] No `codeblock` or `blockquote` handling in `inline`
- [ ] Make links clickable
- [ ] Migrate everything to use App Tokens

## Improvements

- [ ] Chat open is laggy, cache parse markup per message id(?)
- [ ] Cap decoded size for small avatars with `memCacheWidth`
- [ ] Add tests in all areas some day
