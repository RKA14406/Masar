import 'package:flutter/material.dart';

class Ada2kScreen extends StatelessWidget {
  const Ada2kScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ada2k'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.insights_outlined,
                size: 80,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Ada2k',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Progress comparison feature coming soon.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
