import 'package:flutter/material.dart';

/// A [TextFormField] that provides focus-aware callbacks.
///
/// [FocusInputField] wraps a [TextFormField] and adds two behaviors on top
/// of it:
///
/// - **[onFocusLost]** is invoked with the current text value when the field
///   loses focus, making it easy to react to the user finishing editing.
/// - **[selectOnEnter]**, when `true`, selects all text when the field gains
///   focus so the user can quickly replace the entire value.
///
/// Additionally, pressing "done" on the keyboard (or calling
/// `onEditingComplete`) unfocuses the field, which in turn triggers
/// [onFocusLost].
///
/// If [controller] or [focusNode] are not supplied, internal instances are
/// created and automatically disposed.
///
/// Example:
/// ```dart
/// FocusInputField(
///   onFocusLost: (value) => print('User entered: $value'),
///   selectOnEnter: true,
/// )
/// ```
class FocusInputField extends StatefulWidget {
  const FocusInputField({
    super.key,
    this.controller,
    this.focusNode,
    this.initialValue,
    this.decoration = const InputDecoration(),
    this.textCapitalization = TextCapitalization.none,
    this.keyboardType,
    this.maxLength,
    this.maxLines = 1,
    this.minLines,
    this.autovalidateMode,
    this.validator,
    this.onEditingComplete,
    this.onChanged,
    this.onFocusLost,
    this.selectOnEnter = false,
  });

  /// An optional external [TextEditingController].
  ///
  /// When omitted, an internal controller is created and disposed automatically.
  final TextEditingController? controller;

  /// An optional external [FocusNode].
  ///
  /// When omitted, an internal focus node is created and disposed automatically.
  final FocusNode? focusNode;

  /// The initial text placed in the field when an internal controller is used.
  final String? initialValue;

  /// The decoration to show around the text field.
  final InputDecoration? decoration;

  /// Controls how text is capitalized.
  ///
  /// Defaults to [TextCapitalization.none].
  final TextCapitalization textCapitalization;

  /// The keyboard type for this field.
  final TextInputType? keyboardType;

  /// The maximum number of characters the field allows.
  final int? maxLength;

  /// The maximum number of visible lines.
  ///
  /// Defaults to `1`.
  final int? maxLines;

  /// The minimum number of visible lines.
  final int? minLines;

  /// When to run the [validator].
  final AutovalidateMode? autovalidateMode;

  /// An optional validator that returns an error string or `null`.
  final String? Function(String?)? validator;

  /// Called when the user completes editing (e.g. presses "done" on the
  /// keyboard).
  ///
  /// After this callback runs the field is unfocused, which will also trigger
  /// [onFocusLost].
  final void Function()? onEditingComplete;

  /// Called every time the text changes.
  final void Function(String value)? onChanged;

  /// Called with the current text when the field loses focus.
  ///
  /// This is the primary callback for reacting to the user finishing editing.
  final void Function(String value)? onFocusLost;

  /// When `true`, selects all text when the field gains focus.
  ///
  /// Defaults to `false`.
  final bool selectOnEnter;

  @override
  State<FocusInputField> createState() => _FocusInputFieldState();
}

class _FocusInputFieldState extends State<FocusInputField> {
  late final TextEditingController _controller =
      widget.controller ??
      TextEditingController(text: widget.initialValue ?? '');
  late final FocusNode _focusNode = widget.focusNode ?? FocusNode();

  @override
  void initState() {
    super.initState();

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        widget.onFocusLost?.call(_controller.text);
      } else if (widget.selectOnEnter) {
        _controller.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _controller.text.length,
        );
      }
    });
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }

    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      focusNode: _focusNode,
      controller: _controller,
      decoration: widget.decoration,
      textCapitalization: widget.textCapitalization,
      keyboardType: widget.keyboardType,
      maxLength: widget.maxLength,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      autovalidateMode: widget.autovalidateMode,
      validator: widget.validator,
      onEditingComplete: () {
        _focusNode.unfocus();
        widget.onEditingComplete?.call();
      },
      onChanged: widget.onChanged,
    );
  }
}
