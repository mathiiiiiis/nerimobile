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
- [ ] `isValidUrl` rejects urls without a path, so it never matches real links
- [x] Inline code spans never form
- [x] Heading in a custom status keeps its block spacer and font size
- [ ] Swiping a message to reply or edit closes the keyboard, the
      message field*s `onTapOutside` unfocus should go
- [ ] Resolve mentions in Channel Notice

## Features

- [x] DM list caching and skeleton loading, plus pattern for every new list
- [ ] Persist messages so they don't start empty on cold-start
- [x] Add Fullscreen Image viewing
- [x] Attachments:
  - [x] Picker sheet with camera and recent images, all albums opens file picker
  - [x] Upload to nerimity cdn with progress
  - [x] Send one attachment per message, retry a failed upload
- [ ] Voice messages, record in compose and play back in the message
- [x] Emoji anf GIF bottom modal (idea is the nerimity web vanilla version)
- [ ] Markup bar above compose for bold, italic, strikethrough, headings, links,
      todo items, hidden text, timestamps and colors, later hideable in settings
- [ ] Make every nerimity.com/app/ link open inside the app and have custom
      styling instead of an embed
- [x] Context menu(s)
  - [ ] Reactions, pin and mark unread
  - [ ] Report messages
  - [x] Delete other people's messages with manage messages permission
  - [x] Copy message link
- [x] Typing Indicator
- [x] Swipe to reply (short fast swipe), swipe to edit (longer swipe)
- [x] Toast for copies, failed deletes, edits and sends
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
- [ ] Style system messages (member joined, left, kicked, banned, call
      started, server bumped, message pinned)
- [ ] Style webhook messages (especially GitHub)
- [x] Edited indicator on messages
- [x] Scroll to bottom button
- [ ] Servers:
  - [x] Channel listing
  - [x] Members list
  - [x] Writing
  - [x] `ChannelHeader` for not just DM
  - [ ] Files tab in the members pane
  - [ ] Search tab in the members pane
  - [x] Server banner and channel notice in the members pane
  - [x] Collapsible member groups and categories
  - [x] Channels and categories ordered together, empty private categories
        hidden
  - [x] Unread dot on channel rows
  - [x] Remembers the last opened channel per server and DM
  - [x] Restore the last opened channel on start
  - [x] Swipe left on the channel list to open the last channel
  - [ ] Context menus:
    - [x] Server: mark as read, copy ID, leave
    - [x] Channel: mark as read, copy ID
    - [x] Invites
    - [ ] Notification options for Servers and channels
    - [ ] Server and channel settings
    - [ ] Bump published servers
  - [x] Gate the composer on send permission: disables composer with a
        reason, no swipe to reply or edit, timer for mute expiry
  - [x] Slow mode cooldown in the composer
  - [x] Role colours and gradients or usernames in the message list
  - [ ] Persist collapsed categories and member groups
- [ ] Settings page:
  - [ ] Nerimity: Account, Profile, Sessions, Badges, Notifications,
        Connections, Privacy, Activity Status, Developer, (Experiments),
        Tickets
  - [ ] Nerimobile: Settings, App-Notifications, Interface, Language,
        Custom Activity, Accessibility
- [ ] User profiles: preview modal and full page
  - [ ] Avatar borders (badge rings, ears, etc.)
- [ ] YouTube Embed:
  - [ ] Hyperlink Title (stripped tracking)
  - [ ] Cover card: thumbnail, play button (`youtube_explode_dart` maybe?)

## Markup

- [x] Custom entity types:
  - [x] `r` role mentions
  - [x] `q` quoted messages
  - [x] `link` (with `->` syntax)
  - [x] any kind of timestamp
  - [x] `ruby`
  - [x] `vertical`
  - [ ] `@:s` someone ping
  - [ ] `@:e` everyone ping
- [x] No `codeblock` or `blockquote` handling in `inline`
- [x] Make links clickable
- [x] Migrate everything to use App Tokens
- [ ] Allow Channel Mentions to be clicked
- [ ] Render attachments inside a quote
- [ ] Offer a reminder when tapping a future timestamp
- [ ] Toggle checkboxes in own messages
- [ ] Syntax highlighting in codeblocks
- [ ] Translucent markup backgrounds wash out codeblocks in quotes
- [ ] Gradients in blockquotes measure against a placeholder square
      `IntrinsicHeight` and baseline rows also break around `MarkupView`

## Improvements

- [ ] Cap decoded size for small avatars with `memCacheWidth`
- [ ] Remove the unused `currentServer*`, `currentChannel*` and
      `currentPermissions` providers
- [ ] One rail around all branches instead of one per branch, phone
      slide-overs would move to the root navigator
- [ ] Add tests in all areas some day
