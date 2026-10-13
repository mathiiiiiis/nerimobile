# Nerimobile

A custom mobile client for Nerimity.
Not official.

## What is Nerimobile?

Nerimobile is a Flutter client for [Nerimity](https://nerimity.com), built for Android
and iOS.

It is still in an early stage. Check `TODO.md` for open tasks.

If you run into any issues, contact me on Nerimity: `mathis:0000`
or open a GitHub issue.

## Handled Events

Socket events sent by the
[Nerimity server](https://github.com/Nerimity/nerimity-server/blob/main/src/common/ClientEventNames.ts)
and whether Nerimobile handles them yet.

- [x] `user:authenticate_error`
- [x] `user:auth_queue_position`
- [x] `user:authenticated`

- [ ] `user:updatedSelf`
- [ ] `user:updated`
- [ ] `user:notice_created`
- [ ] `user:updated_clan`

- [ ] `user:connection_added`
- [ ] `user:connection_removed`

- [ ] `user:notification_settings_update`

- [x] `user:presence_update`

- [ ] `user:blocked`
- [ ] `user:unblocked`

- [ ] `user:reminder_add`
- [ ] `user:reminder_update`
- [ ] `user:reminder_remove`

- [ ] `friend:request_sent`
- [ ] `friend:request_pending`
- [ ] `friend:request_accepted`
- [ ] `friend:removed`

- [x] `inbox:opened`
- [x] `inbox:closed`
- [x] `notification:dismissed`

- [x] `server:joined`
- [x] `server:left`
- [x] `server:updated`
- [ ] `server:order_updated`
- [ ] `server:folder_created`
- [ ] `server:folder_updated`
- [ ] `server:clan_updated`

- [x] `server:role_created`
- [x] `server:role_updated`
- [x] `server:role_deleted`
- [x] `server:role_order_updated`

- [x] `server:member_joined`
- [x] `server:member_left`
- [x] `server:member_updated`
- [ ] `server:members_fetched`

- [x] `server:channel_created`
- [x] `server:channel_updated`
- [x] `server:channel_deleted`
- [x] `server:channel_order_updated`
- [x] `server:channel_permissions_updated`

- [x] `server:emoji_add`
- [x] `server:emoji_remove`
- [x] `server:emoji_update`

- [ ] `server:schedule_delete`
- [ ] `server:remove_schedule_delete`

- [x] `channel:typing`

- [x] `message:created`
- [x] `message:updated`
- [x] `message:deleted`
- [ ] `message:deleted_batch`
- [ ] `message:mark_unread`

- [ ] `message:reaction_added`
- [ ] `message:reaction_removed`

- [ ] `message:button_clicked_callback`

- [ ] `post:mention`

- [ ] `voice:user_joined`
- [ ] `voice:user_left`
- [ ] `voice:signal_received`

## Building

```bash
flutter pub get
flutter run
```

A `flake.nix` exists if you want to use it. ;)

## Contributing

Contributions are welcome! Open a pull request with your changes, or open an issue if
you find a bug that has not already been reported (or contact me directly).

Not sure about a change? Open an issue first to discuss it!

## Disclaimer

To use this App, you need to agree and apply with the Nerimity's
[Privacy Policy](https://nerimity.com/privacy) and
[Terms and Conditions](https://nerimity.com/terms-and-conditions).

I asked for permission to work on this Project, and it was approved by the owner of
Nerimity.

**Please DO NOT contact the owner of Nerimity about issues with this Project!**
