import 'package:flutter/material.dart';
import 'package:smart_input_fields/smart_input_fields.dart';

/// A text field that automatically resolves math expressions.
///
/// [ExpressionInputField] extends [FocusInputField] with expression
/// evaluation powered by the `math_expressions` package. When the user
/// finishes editing (by pressing "done" or by the field losing focus), any
/// math expressions found in the text are replaced by their computed result.
///
/// The [evaluator] is required and defines how parsed [Expression] objects
/// are evaluated. The default `ExpressionEvaluator` from
/// `math_expressions` is a good starting point:
///
/// ```dart
/// ExpressionInputField(
///   evaluator: ExpressionEvaluator(),
/// )
/// ```
///
/// If the evaluated result is a whole number double (e.g. `4.0`) it is
/// displayed without the decimal part (`4`). Supply [evalToString] for
/// complete control over how results are rendered to text.
///
/// See also:
///
/// - [FocusInputField], the underlying widget that provides focus-aware
///   callbacks such as [onFocusLost] and [selectOnEnter].
/// - [ExpressionEvaluator] from `math_expressions` for expression evaluation.
class ExpressionInputField<T> extends StatefulWidget {
  const ExpressionInputField({
    super.key,
    required this.evaluator,
    this.evalToString,
    this.grammarParser,
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

  /// The expression evaluator used to compute results.
  ///
  /// Must be an [ExpressionEvaluator] (or subtype) that knows how to
  /// evaluate a parsed [Expression] into a value of type [T].
  final ExpressionEvaluator<T> evaluator;

  /// An optional function that converts an evaluated result to its display
  /// string.
  ///
  /// When omitted, whole-number doubles are rendered without a decimal part
  /// (e.g. `4` instead of `4.0`), and all other values use `.toString()`.
  final String Function(T eval)? evalToString;

  /// Optional grammarParser to override the default.
  final GrammarParser? grammarParser;

  /// An optional external [TextEditingController].
  ///
  /// When omitted, an internal controller is created and disposed automatically.
  final TextEditingController? controller;

  /// An optional external [FocusNode].
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

  /// Called with the resolved text after expressions have been evaluated
  /// when the user completes editing (e.g. presses "done").
  final void Function(String?)? onEditingComplete;

  /// Called every time the text changes (before expression evaluation).
  final void Function(String value)? onChanged;

  /// Called with the resolved text after expressions have been evaluated
  /// when the field loses focus.
  final void Function(String value)? onFocusLost;

  /// When `true`, selects all text when the field gains focus.
  ///
  /// Defaults to `false`.
  final bool selectOnEnter;

  @override
  State<ExpressionInputField<T>> createState() =>
      _ExpressionInputFieldState<T>();
}

class _ExpressionInputFieldState<T> extends State<ExpressionInputField<T>> {
  late final parser = widget.grammarParser ?? GrammarParser();

  late final TextEditingController _controller =
      widget.controller ??
      TextEditingController(text: widget.initialValue ?? '');

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void parseInput() {
    final inputText = _controller.text;
    if (inputText.isEmpty) return;

    final mathRegex = RegExp(r'([0-9\.\+\-\*\/\(\)\s\^]+)');

    final resolvedText = inputText.replaceAllMapped(mathRegex, (match) {
      final rawMatch = match.group(0)!;
      final trimmedMatch = rawMatch.trim();

      if (trimmedMatch.isEmpty || trimmedMatch == '.') {
        return rawMatch;
      }

      try {
        final expression = parser.parse(trimmedMatch);
        final eval = widget.evaluator.evaluate(expression);

        String evalString;
        if (widget.evalToString == null) {
          evalString = eval is double && eval == eval.toInt()
              ? eval.toInt().toString()
              : eval.toString();
        } else {
          evalString = widget.evalToString!(eval);
        }

        final leadingSpaces = rawMatch.substring(
          0,
          rawMatch.indexOf(trimmedMatch),
        );
        final trailingSpaces = rawMatch.substring(
          rawMatch.indexOf(trimmedMatch) + trimmedMatch.length,
        );

        return '$leadingSpaces$evalString$trailingSpaces';
      } catch (_) {
        return rawMatch;
      }
    });

    _controller.text = resolvedText;
  }

  @override
  Widget build(BuildContext context) {
    return FocusInputField(
      controller: _controller,
      focusNode: widget.focusNode,
      initialValue: widget.initialValue,
      decoration: widget.decoration,
      textCapitalization: widget.textCapitalization,
      keyboardType: widget.keyboardType,
      maxLength: widget.maxLength,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      autovalidateMode: widget.autovalidateMode,
      validator: widget.validator,
      onEditingComplete: () {
        parseInput();
        widget.onEditingComplete?.call(_controller.text);
      },
      onChanged: widget.onChanged,
      onFocusLost: (value) {
        parseInput();
        widget.onFocusLost?.call(_controller.text);
      },
      selectOnEnter: widget.selectOnEnter,
    );
  }
}
