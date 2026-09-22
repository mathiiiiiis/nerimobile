import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:nerimobile/stores/composer/composer_store.dart';

import 'package:nerimobile/theme/core/theme_data.dart';
import 'package:nerimobile/theme/core/token.dart';
import 'package:nerimobile/theme/sizing/dimens.dart';
import 'package:nerimobile/theme/sizing/radius.dart';
import 'package:nerimobile/theme/sizing/spacing.dart';
import 'package:nerimobile/theme/typography/text_styles.dart';
import 'package:nerimobile/utils/emoji_catalog.dart';
import 'package:nerimobile/utils/emoji_shortcodes.dart';
import 'package:nerimobile/views/app_text_field.dart';
import 'package:nerimobile/views/chat/composer/composer_panel.dart';
import 'package:nerimobile/views/chat/message/emoji/twemoji.dart';

const _headerEmoji = 16.0;
const _indicatorWidth = 2.0;
const _indicatorHeight = 0.4;
const _disabledOpacity = 0.4;
const _sidebarFollow = Duration(milliseconds: 200);

enum EmojiPane { closed, open, searching }

final emojiPaneProvider =
    NotifierProvider.family<EmojiPanelNotifier, EmojiPane, String>(
      EmojiPanelNotifier.new,
    );

class EmojiPanelNotifier extends Notifier<EmojiPane> {
  EmojiPanelNotifier(this.channelId);

  final String channelId;

  @override
  EmojiPane build() => EmojiPane.closed;

  void open() => state = EmojiPane.open;
  void close() => state = EmojiPane.closed;

  void toggle() =>
      state = state == EmojiPane.closed ? EmojiPane.open : EmojiPane.closed;

  void search(bool searching) {
    if (state == EmojiPane.closed) return;
    state = searching ? EmojiPane.searching : EmojiPane.open;
  }
}

final _entries = <String, CatalogEmoji>{
  for (final emojis in emojiCatalog.values)
    for (final emoji in emojis) emoji.emoji: emoji,
};

//aliases are searchable too
List<CatalogEmoji> _matches(String query) {
  final starts = <CatalogEmoji>[];
  final contains = <CatalogEmoji>[];
  final seen = <String>{};

  for (final MapEntry(key: name, value: emoji) in emojiShortcodes.entries) {
    final at = name.indexOf(query);
    final entry = _entries[emoji];
    if (at < 0 || entry == null || !seen.add(emoji)) continue;

    (at == 0 ? starts : contains).add(entry);
  }

  return [...starts, ...contains];
}

sealed class _Row {
  const _Row();
}

class _Header extends _Row {
  const _Header(this.category, this.icon);

  final String category;
  final CatalogEmoji icon;
}

class _Emojis extends _Row {
  const _Emojis(this.emojis);

  final List<CatalogEmoji> emojis;
}

List<_Row> _emojiRows(List<CatalogEmoji> emojis, int columns) => [
  for (var i = 0; i < emojis.length; i += columns)
    _Emojis(emojis.sublist(i, (i + columns).clamp(0, emojis.length))),
];

List<_Row> _rows(int columns) => [
  for (final MapEntry(key: category, value: emojis)
      in emojiCatalog.entries) ...[
    _Header(category, emojis.first),
    ..._emojiRows(emojis, columns),
  ],
];

class EmojiPanel extends ConsumerStatefulWidget {
  const EmojiPanel({super.key, required this.channelId});

  final String channelId;

  @override
  ConsumerState<EmojiPanel> createState() => _EmojiPanelState();
}

class _EmojiPanelState extends ConsumerState<EmojiPanel> {
  final _scroll = ScrollController();
  final _search = TextEditingController();
  final _searchFocus = FocusNode();
  var _columns = 0;
  var _query = '';
  var _rowList = const <_Row>[];
  var _headers = const <int>[];
  var _active = 0;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _searchFocus.addListener(
      () => ref
          .read(emojiPaneProvider(widget.channelId).notifier)
          .search(_searchFocus.hasFocus),
    );
  }

  @override
  void dispose() {
    _scroll.dispose();
    _search.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  double get _extent =>
      context.neriSize.dimen(NeriDimen.pickerEmoji) +
      context.neriSize.space(NeriSpacingRole.sm);

  void _layout(int columns) {
    if (columns == _columns) return;
    _columns = columns;
    _relayout();
  }

  void _relayout() {
    _rowList = _query.isEmpty
        ? _rows(_columns)
        : _emojiRows(_matches(_query), _columns);
    _headers = [
      for (var i = 0; i < _rowList.length; i++)
        if (_rowList[i] is _Header) i,
    ];
  }

  void _onQuery(String query) {
    setState(() => _query = query.trim().toLowerCase().replaceAll(' ', '_'));
    _relayout();
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  void _onScroll() {
    if (_query.isNotEmpty) return;

    final row = _scroll.offset / _extent;
    final active = _headers.lastIndexWhere((header) => header <= row + 0.5);
    if (active >= 0 && active != _active) setState(() => _active = active);
  }

  void _jumpTo(int category) {
    if (_query.isNotEmpty) {
      _search.clear();
      _onQuery('');
    }

    _scroll.jumpTo(_headers[category] * _extent);
  }

  void _pick(CatalogEmoji emoji) => ref
      .read(composerProvider(widget.channelId).notifier)
      .insert(':${emoji.name}: ');

  @override
  Widget build(BuildContext context) {
    ref.listen(emojiPaneProvider(widget.channelId), (_, pane) {
      if (pane != EmojiPane.closed) return;

      _searchFocus.unfocus();
      _search.clear();
      if (_query.isNotEmpty) _onQuery('');
    });

    final sizing = context.neriSize;
    final gap = sizing.space(NeriSpacingRole.sm);

    return ComposerPanelFrame(
      expansion: 0,
      child: Padding(
        padding: EdgeInsets.only(top: gap),
        child: Column(
          spacing: gap,
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: gap,
                children: [
                  _Sidebar(
                    active: _query.isEmpty ? _active : -1,
                    icons: [
                      for (final emojis in emojiCatalog.values) emojis.first,
                    ],
                    onTap: _jumpTo,
                  ),
                  Expanded(
                    child: Column(
                      spacing: gap,
                      children: [
                        AppTextField(
                          controller: _search,
                          focusNode: _searchFocus,
                          onChanged: _onQuery,
                          hintText: 'Search Emojis...', //TODO: add l10n
                        ),
                        Expanded(child: _list()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const _Tabs(),
          ],
        ),
      ),
    );
  }

  Widget _list() => LayoutBuilder(
    builder: (context, constraints) {
      _layout((constraints.maxWidth / _extent).floor().clamp(1, 99));
      return ListView.builder(
        controller: _scroll,
        itemExtent: _extent,
        itemCount: _rowList.length,
        itemBuilder: (context, index) => switch (_rowList[index]) {
          _Header(:final category, :final icon) => _GroupHeader(
            name: category,
            icon: icon,
          ),
          _Emojis(:final emojis) => Row(
            children: [
              for (final emoji in emojis)
                _EmojiCell(
                  emoji: emoji,
                  extent: _extent,
                  onTap: () => _pick(emoji),
                ),
            ],
          ),
        },
      );
    },
  );
}

class _Sidebar extends StatefulWidget {
  const _Sidebar({
    required this.active,
    required this.icons,
    required this.onTap,
  });

  final int active;
  final List<CatalogEmoji> icons;
  final ValueChanged<int> onTap;

  @override
  State<_Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<_Sidebar> {
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  //keeps the active category visible
  @override
  void didUpdateWidget(_Sidebar old) {
    super.didUpdateWidget(old);
    if (widget.active < 0 || widget.active == old.active || !_scroll.hasClients)
      return;

    final item = context.neriSize.dimen(NeriDimen.controlSize);
    final start = widget.active * item;
    final offset = _scroll.offset;
    final viewport = _scroll.position.viewportDimension;

    final target = start < offset
        ? start
        : start + item > offset + viewport
        ? start + item - viewport
        : null;
    if (target == null) return;

    _scroll.animateTo(
      target.clamp(0.0, _scroll.position.maxScrollExtent),
      duration: _sidebarFollow,
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.neri;
    final sizing = context.neriSize;
    final item = sizing.dimen(NeriDimen.controlSize);

    return Container(
      width: item,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors[NeriToken.card],
        borderRadius: sizing.rounded(NeriRadiusRole.md),
      ),
      child: ListView(
        controller: _scroll,
        padding: EdgeInsets.zero,
        children: [
          for (var i = 0; i < widget.icons.length; i++)
            GestureDetector(
              onTap: () => widget.onTap(i),
              child: Container(
                height: item,
                decoration: BoxDecoration(
                  color: i == widget.active
                      ? colors[NeriToken.drawerItemHoverBackground]
                      : null,
                  borderRadius: sizing.rounded(NeriRadiusRole.sm),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Twemoji(
                      unicode: widget.icons[i].emoji,
                      size: sizing.dimen(NeriDimen.iconSm),
                    ),
                    if (i == widget.active)
                      Positioned(
                        left: 0,
                        child: Container(
                          width: _indicatorWidth,
                          height: item * _indicatorHeight,
                          decoration: BoxDecoration(
                            color: colors[NeriToken.primary],
                            borderRadius: sizing.rounded(NeriRadiusRole.full),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.name, required this.icon});

  final String name;
  final CatalogEmoji icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.neri;
    final sizing = context.neriSize;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          sizing.space(NeriSpacingRole.xs),
          sizing.space(NeriSpacingRole.xs),
          sizing.space(NeriSpacingRole.sm),
          sizing.space(NeriSpacingRole.xs),
        ),
        decoration: BoxDecoration(
          color: colors[NeriToken.card],
          borderRadius: sizing.rounded(NeriRadiusRole.full),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: sizing.space(NeriSpacingRole.xs),
          children: [
            Twemoji(unicode: icon.emoji, size: _headerEmoji),
            Text(
              name,
              style: context.neriText[NeriTextRole.labelSmall].copyWith(
                color: colors[NeriToken.textSecondary],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmojiCell extends StatelessWidget {
  const _EmojiCell({
    required this.emoji,
    required this.extent,
    required this.onTap,
  });

  final CatalogEmoji emoji;
  final double extent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox.square(
        dimension: extent,
        child: Center(
          child: Twemoji(
            unicode: emoji.emoji,
            size: context.neriSize.dimen(NeriDimen.pickerEmoji),
          ),
        ),
      ),
    );
  }
}

class _Tabs extends StatelessWidget {
  const _Tabs();

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: context.neriSize.space(NeriSpacingRole.xs),
      children: const [
        Expanded(
          child: _Tab(
            icon: Symbols.sentiment_excited_rounded,
            label: 'Emojis', //TODO: add l10n
            selected: true,
          ),
        ),
        Expanded(
          child: Opacity(
            opacity: _disabledOpacity,
            child: _Tab(
              icon: Symbols.gif_rounded,
              label: 'GIFs', //TODO: add l10n
            ),
          ),
        ),
      ],
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({required this.icon, required this.label, this.selected = false});

  final IconData icon;
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = context.neri;
    final sizing = context.neriSize;

    return Container(
      height: sizing.dimen(NeriDimen.controlSize),
      decoration: BoxDecoration(
        color: selected ? colors[NeriToken.card] : null,
        borderRadius: sizing.rounded(NeriRadiusRole.md),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: sizing.space(NeriSpacingRole.xs),
        children: [
          Icon(
            icon,
            size: sizing.dimen(NeriDimen.iconSm),
            color: colors[NeriToken.text],
          ),
          Text(
            label,
            style: context.neriText[NeriTextRole.labelLarge].copyWith(
              color: colors[NeriToken.text],
            ),
          ),
        ],
      ),
    );
  }
}
