import 'package:flutter/material.dart';

class CompFinderScreen extends StatelessWidget {
  const CompFinderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comp-Finder'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.emoji_events_outlined,
                size: 80,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Comp-Finder',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Find competitions based on your major and skills.\n(Coming Soon)',
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
