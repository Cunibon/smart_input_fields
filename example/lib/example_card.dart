import 'package:flutter/material.dart';

class ExampleCard extends StatelessWidget {
  const ExampleCard({super.key, required this.title, required this.child});

  final String title;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsetsGeometry.all(8),
        child: Column(
          children: [
            Text(title, style: TextTheme.of(context).titleLarge),
            child,
          ],
        ),
      ),
    );
  }
}
