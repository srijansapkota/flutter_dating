import 'package:flutter/material.dart';

class ComingSoonPage extends StatelessWidget {
  const ComingSoonPage({
    super.key,
    required this.title,
    required this.icon,
    this.actions,
  });

  final String title;
  final IconData icon;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(title), actions: actions),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: colors.primary),
            const SizedBox(height: 16),
            Text(
              'Coming soon',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
      ),
    );
  }
}