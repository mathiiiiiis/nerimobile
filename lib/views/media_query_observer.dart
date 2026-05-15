import 'package:flutter/material.dart';
import 'package:nerimobile/stores/media_query_store.dart';

class MediaQueryObserver extends StatelessWidget {
  final Widget child;
  const MediaQueryObserver({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    screenWidth.value = mq.size.width;
    screenHeight.value = mq.size.height;
    return child;
  }
}
