# smart_input_fields

Flutter input fields that auto-evaluate math expressions. Type `2+3` and get `5` — no extra button press needed.

## Features

- **FocusInputField** — a `TextFormField` with an `onFocusLost` callback and a `selectOnEnter` option that selects all text on focus.
- **ExpressionInputField** — extends `FocusInputField` with automatic math expression resolution. Expressions like `2+3`, `8/2`, or `3*4` are replaced by their computed result when the field loses focus or the user presses "done".
- Mixed text is supported: `"2+3 items"` becomes `"5 items"`.
- Whole-number doubles render as integers by default (`4.0` → `4`), with a customizable `evalToString` callback.

## Getting started

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  smart_input_fields: ^0.0.1
```

Then import:

```dart
import 'package:smart_input_fields/smart_input_fields.dart';
```

The package re-exports `math_expressions`, so no separate import is needed.

## Usage

### FocusInputField

A drop-in `TextFormField` replacement that calls `onFocusLost` when the user leaves the field and can auto-select text on entry:

```dart
FocusInputField(
  decoration: const InputDecoration(labelText: 'Name'),
  onFocusLost: (value) {
    // react to the user finishing editing
  },
  selectOnEnter: true,
)
```

Pressing "done" on the keyboard unfocuses the field, which also triggers `onFocusLost`.

### ExpressionInputField

Automatically resolves math expressions when editing completes:

```dart
ExpressionInputField(
  evaluator: RealEvaluator(),
  decoration: const InputDecoration(labelText: 'Amount'),
  onFocusLost: (resolved) {
    // resolved contains evaluated expressions, e.g. "5" instead of "2+3"
  },
)
```

Custom result formatting with `evalToString`:

```dart
ExpressionInputField<num>(
  evaluator: RealEvaluator(),
  evalToString: (value) => '= ${value.toStringAsFixed(2)}',
)
```

## Additional information

- Repository: <https://github.com/Cunibon/smart_input_fields>
- File issues and feature requests on the GitHub issue tracker.
- The expression parser is powered by the [`math_expressions`](https://pub.dev/packages/math_expressions) package.