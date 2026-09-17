import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nerimobile/models/user.dart';
import 'package:nerimobile/stores/channel/typing_store.dart';
import 'package:nerimobile/stores/user/user_store.dart';
import 'package:nerimobile/theme/core/theme_data.dart';
import 'package:nerimobile/theme/core/token.dart';
import 'package:nerimobile/theme/sizing/dimens.dart';
import 'package:nerimobile/theme/sizing/spacing.dart';
import 'package:nerimobile/theme/typography/text_styles.dart';

const _named = 2;
const _resize = Duration(milliseconds: 150);
const _bounce = Duration(milliseconds: 1200);
const _dotSize = 4.0;
const _dotStagger = 0.15;
const _dotBounce = 0.45;
const _dotLift = 2.0;

class TypingIndicator extends ConsumerStatefulWidget {
  const TypingIndicator({super.key, required this.channelId});

  final String channelId;

  @override
  ConsumerState<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends ConsumerState<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bounceController;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(vsync: this, duration: _bounce);
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.neri;
    final sizing = context.neriSize;
    final typing = ref.watch(
      typingProvider.select((t) => t[widget.channelId] ?? const <String>[]),
    );
    final users = ref.watch(usersProvider);

    if (typing.isEmpty) {
      _bounceController.stop();
    } else if (!_bounceController.isAnimating) {
      _bounceController.repeat();
    }

    return AnimatedSize(
      duration: _resize,
      curve: Curves.easeOut,
      alignment: Alignment.bottomCenter,
      child: typing.isEmpty
          ? const SizedBox(width: double.infinity)
          : SizedBox(
              height: sizing.dimen(NeriDimen.replyHeight),
              child: Padding(
                padding: EdgeInsets.only(
                  left: sizing.space(NeriSpacingRole.md),
                ),
                child: Row(
                  spacing: sizing.space(NeriSpacingRole.xs),
                  children: [
                    Flexible(
                      child: Text(
                        _label(typing, users),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.neriText[NeriTextRole.bodySmall]
                            .copyWith(color: colors[NeriToken.textSecondary]),
                      ),
                    ),
                    _Dots(
                      animation: _bounceController,
                      color: colors[NeriToken.textSecondary],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

//TODO: add l10n
String _label(List<String> typing, Map<String, User> users) {
  final names = [
    for (final id in typing.take(_named)) users[id]?.username ?? 'Someone',
  ];
  final rest = typing.length - names.length;

  final who = switch ((names.length, rest)) {
    (1, 0) => '${names.first} is',
    (_, 0) => '${names.first} and ${names.last} are',
    (_, 1) => '${names.join(', ')} and 1 other are',
    _ => '${names.join(', ')} and $rest others are',
  };
  return '$who typing';
}

class _Dots extends StatelessWidget {
  const _Dots({required this.animation, required this.color});

  final Animation<double> animation;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) => Row(
        spacing: _dotSize / 2,
        children: [for (var dot = 0; dot < 3; dot++) _dot(dot)],
      ),
    );
  }

  Widget _dot(int index) {
    final phase = (animation.value - index * _dotStagger) % 1;
    final lift = phase < _dotBounce ? sin(phase / _dotBounce * pi) : 0.0;

    return Transform.translate(
      offset: Offset(0, -lift * _dotLift),
      child: Container(
        width: _dotSize,
        height: _dotSize,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.4 + lift * 0.6),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
