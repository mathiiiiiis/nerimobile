# TODO

## Bugs

- [x] Connection drops some time after switching apps
- [x] Reconnect gets stuck on `Couldn't connect` until app is backgrounded
      and foregrounded a few times
- [x] Messages sent while away do not appear after a reconnect
- [x] After a reconnect a deleted or edited message is never learned
- [ ] A channel opened while offline fails its initial load and nothing retries,
      so it sits on the skeleton until the user navigates away and back
- [ ] Server channel mention counts undercount, `isMentioned` misses `[@:e]`,
      role mentions and reply mentions
- [ ] Scroll to message does not paginate to a target that is not loaded yet
- [ ] Inline code spans never form
- [ ] Heading in a custom status keeps its block spacer and font size

## Features

- [x] DM list caching and skeleton loading, plus pattern for every new list
- [ ] Persist messages so they don't start empty on cold-start
- [ ] Context menu(s)
- [ ] Typing Indicator
- [ ] Swipe to reply (short fast swipe), swipe to edit (longer swipe)
- [ ] Dashboard:
  - [x] Activity list
  - [x] Pinned announcement
  - [x] Feed with paging
  - [ ] Post Composer
  - [ ] Feed, Discover and Notifications tabs
  - [ ] Refresh on reconnect
- Posts:
  - [ ] Add Polls Support
  - [ ] Post interactions (like, comment, repost, more)
- [ ] Servers:
  - [ ] Channel listing
  - [ ] Members list
  - [ ] Writing
  - [ ] `ChannelHeader` for not just DM
- [ ] YouTube Embed:
  - [ ] Hyperlink Title (stripped tracking)
  - [ ] Cover card: thumbnail, play button (`youtube_explode_dart` maybe?)

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

- [ ] Cap decoded size for small avatars with `memCacheWidth`
- [ ] Add tests in all areas some day
