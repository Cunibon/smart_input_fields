import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_input_fields/smart_input_fields.dart';

Widget _boilerplate(Widget child) {
  return MaterialApp(home: Scaffold(body: child));
}

Future<void> _unfocus(WidgetTester tester) async {
  final currentContext = tester.element(find.byType(TextFormField).first);
  FocusScope.of(currentContext).unfocus();
  await tester.pump();
}

void main() {
  group('FocusInputField', () {
    testWidgets('renders a TextFormField', (tester) async {
      await tester.pumpWidget(_boilerplate(const FocusInputField()));
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('calls onFocusLost when focus is lost', (tester) async {
      String? lostValue;
      await tester.pumpWidget(
        _boilerplate(FocusInputField(onFocusLost: (v) => lostValue = v)),
      );

      await tester.enterText(find.byType(TextFormField), 'hello');
      await tester.pump();

      await _unfocus(tester);

      expect(lostValue, 'hello');
    });

    testWidgets('calls onEditingComplete and unfocuses', (tester) async {
      bool editingComplete = false;
      String? lostValue;

      await tester.pumpWidget(
        _boilerplate(
          FocusInputField(
            onEditingComplete: () => editingComplete = true,
            onFocusLost: (v) => lostValue = v,
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'test');
      await tester.pump();

      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(editingComplete, isTrue);
      expect(lostValue, 'test');
    });

    testWidgets('selects all text on focus when selectOnEnter is true', (
      tester,
    ) async {
      final controller = TextEditingController(text: 'abc');

      await tester.pumpWidget(
        _boilerplate(
          FocusInputField(controller: controller, selectOnEnter: true),
        ),
      );

      await tester.tap(find.byType(TextFormField));
      await tester.pump();

      expect(controller.selection.baseOffset, 0);
      expect(controller.selection.extentOffset, 3);
    });

    testWidgets('does not select all text when selectOnEnter is false', (
      tester,
    ) async {
      final controller = TextEditingController(text: 'abc');

      await tester.pumpWidget(
        _boilerplate(
          FocusInputField(controller: controller, selectOnEnter: false),
        ),
      );

      await tester.tap(find.byType(TextFormField));
      await tester.pump();

      expect(
        controller.selection.baseOffset,
        controller.selection.extentOffset,
      );
    });

    testWidgets('initialValue is used when no controller is provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        _boilerplate(const FocusInputField(initialValue: 'initial')),
      );

      final field = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(field.controller?.text, 'initial');
    });

    testWidgets(
      'disposes internally created controller and focusNode without errors',
      (tester) async {
        await tester.pumpWidget(_boilerplate(const FocusInputField()));

        await tester.pumpWidget(const SizedBox.shrink());

        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'does not dispose externally provided controller and focusNode',
      (tester) async {
        final controller = TextEditingController();
        final focusNode = FocusNode();

        await tester.pumpWidget(
          _boilerplate(
            FocusInputField(controller: controller, focusNode: focusNode),
          ),
        );

        await tester.pumpWidget(const SizedBox.shrink());

        focusNode.dispose();
        controller.dispose();
      },
    );

    testWidgets('calls onChanged on every keystroke', (tester) async {
      String? changedValue;

      await tester.pumpWidget(
        _boilerplate(FocusInputField(onChanged: (v) => changedValue = v)),
      );

      await tester.enterText(find.byType(TextFormField), 'x');
      await tester.pump();

      expect(changedValue, 'x');
    });

    testWidgets('validator is passed through', (tester) async {
      await tester.pumpWidget(
        _boilerplate(
          FocusInputField(
            autovalidateMode: AutovalidateMode.always,
            validator: (v) => v == null || v.isEmpty ? 'required' : null,
          ),
        ),
      );

      await tester.pump();
      expect(find.text('required'), findsOneWidget);
    });
  });

  group('ExpressionInputField', () {
    testWidgets('renders a FocusInputField', (tester) async {
      await tester.pumpWidget(
        _boilerplate(ExpressionInputField(evaluator: RealEvaluator())),
      );
      expect(find.byType(FocusInputField), findsOneWidget);
    });

    testWidgets('resolves simple addition on editing complete', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        _boilerplate(
          ExpressionInputField(
            evaluator: RealEvaluator(),
            controller: controller,
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), '2+3');
      await tester.pump();

      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(controller.text, '5');
    });

    testWidgets('resolves multiplication on editing complete', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        _boilerplate(
          ExpressionInputField(
            evaluator: RealEvaluator(),
            controller: controller,
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), '3*4');
      await tester.pump();

      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(controller.text, '12');
    });

    testWidgets('renders whole doubles as integers', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        _boilerplate(
          ExpressionInputField(
            evaluator: RealEvaluator(),
            controller: controller,
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), '8/2');
      await tester.pump();

      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(controller.text, '4');
    });

    testWidgets('resolves expression on focus lost', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        _boilerplate(
          ExpressionInputField(
            evaluator: RealEvaluator(),
            controller: controller,
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), '2+3');
      await tester.pump();

      await _unfocus(tester);

      expect(controller.text, '5');
    });

    testWidgets('uses evalToString for custom formatting', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        _boilerplate(
          ExpressionInputField<num>(
            evaluator: RealEvaluator(),
            evalToString: (v) => '= $v',
            controller: controller,
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), '2+3');
      await tester.pump();

      await _unfocus(tester);

      expect(controller.text, '= 5.0');
    });

    testWidgets('does not resolve empty input', (tester) async {
      final controller = TextEditingController(text: '');

      await tester.pumpWidget(
        _boilerplate(
          ExpressionInputField(
            evaluator: RealEvaluator(),
            controller: controller,
          ),
        ),
      );

      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(controller.text, '');
    });

    testWidgets('leaves non-math text unchanged', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        _boilerplate(
          ExpressionInputField(
            evaluator: RealEvaluator(),
            controller: controller,
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'hello');
      await tester.pump();

      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(controller.text, 'hello');
    });

    testWidgets('calls onEditingComplete with resolved text', (tester) async {
      String? completedValue;

      await tester.pumpWidget(
        _boilerplate(
          ExpressionInputField(
            evaluator: RealEvaluator(),
            onEditingComplete: (v) => completedValue = v,
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), '2+3');
      await tester.pump();

      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(completedValue, '5');
    });

    testWidgets('calls onFocusLost with resolved text', (tester) async {
      String? lostValue;

      await tester.pumpWidget(
        _boilerplate(
          ExpressionInputField(
            evaluator: RealEvaluator(),
            onFocusLost: (v) => lostValue = v,
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), '2+3');
      await tester.pump();

      await _unfocus(tester);

      expect(lostValue, '5');
    });

    testWidgets('resolves mixed text with embedded expressions', (
      tester,
    ) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        _boilerplate(
          ExpressionInputField(
            evaluator: RealEvaluator(),
            controller: controller,
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), '2+3 items');
      await tester.pump();

      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(controller.text, '5 items');
    });

    testWidgets('selectOnEnter is forwarded to FocusInputField', (
      tester,
    ) async {
      await tester.pumpWidget(
        _boilerplate(
          ExpressionInputField(evaluator: RealEvaluator(), selectOnEnter: true),
        ),
      );

      final focusInputField = tester.widget<FocusInputField>(
        find.byType(FocusInputField),
      );
      expect(focusInputField.selectOnEnter, isTrue);
    });
  });
}
