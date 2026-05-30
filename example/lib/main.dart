import 'package:example/example_card.dart';
import 'package:flutter/material.dart';
import 'package:smart_input_fields/smart_input_fields.dart';

void main() async {
  runApp(const SmartInputFieldsExample());
}

class SmartInputFieldsExample extends StatelessWidget {
  const SmartInputFieldsExample({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            ExampleCard(title: "FocusField", child: FocusInputField()),
            ExampleCard(
              title: "ExpressionField",
              child: ExpressionInputField(evaluator: RealEvaluator()),
            ),
          ],
        ),
      ),
    );
  }
}
