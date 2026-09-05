import 'package:flutter/material.dart';

import 'package:nerimobile/theme/core/theme_data.dart';
import 'package:nerimobile/theme/core/token.dart';
import 'package:nerimobile/theme/sizing/dimens.dart';
import 'package:nerimobile/theme/sizing/radius.dart';
import 'package:nerimobile/theme/typography/text_styles.dart';

class AppTextField extends StatefulWidget {
  final String? hintText;
  final String? label;
  final String? errorText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final bool obscureText;

  const AppTextField({
    super.key,
    this.label,
    this.hintText,
    this.errorText,
    this.controller,
    this.focusNode,
    this.onSubmitted,
    this.onChanged,
    this.obscureText = false,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late final FocusNode _focusNode;
  bool _ownsNode = false;

  @override
  void initState() {
    super.initState();
    if (widget.focusNode == null) {
      _focusNode = FocusNode();
      _ownsNode = true;
    } else {
      _focusNode = widget.focusNode!;
    }
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    if (_ownsNode) _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.neri;
    final sizing = context.neriSize;
    final radius = sizing.radius(NeriRadiusRole.md);
    final borderColor = widget.errorText != null
        ? colors[NeriToken.alert]
        : colors[NeriToken.border];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        if (widget.label != null)
          Text(
            widget.label!,
            style: context.neriText[NeriTextRole.labelLarge].copyWith(
              color: colors[NeriToken.textSecondary],
            ),
          ),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              TextField(
                controller: widget.controller,
                focusNode: _focusNode,
                onSubmitted: widget.onSubmitted,
                onChanged: widget.onChanged,
                obscureText: widget.obscureText,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 14,
                  ),

                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(radius),
                    borderSide: BorderSide(
                      color: borderColor,
                      width: sizing.dimen(NeriDimen.borderWidth),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(radius),
                    borderSide: BorderSide(
                      color: borderColor,
                      width: sizing.dimen(NeriDimen.borderWidth),
                    ),
                  ),
                  hintStyle: context.neriText[NeriTextRole.bodyMedium].copyWith(
                    color: colors[NeriToken.textPlaceholder],
                  ),
                  hintText: widget.hintText,
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 1,
                  decoration: BoxDecoration(
                    color: _focusNode.hasFocus
                        ? colors[NeriToken.primary]
                        : Colors.transparent,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(radius),
                      bottomRight: Radius.circular(radius),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (widget.errorText != null)
          Text(
            widget.errorText!,
            style: context.neriText[NeriTextRole.bodySmall].copyWith(
              color: colors[NeriToken.alert],
            ),
          ),
      ],
    );
  }
}
