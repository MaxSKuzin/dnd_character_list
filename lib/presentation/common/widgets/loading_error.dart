import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Ошибка загрузки данных с кнопкой повтора.
class LoadingError extends StatelessWidget {
  final String message;
  final Object error;
  final VoidCallback onRetry;

  const LoadingError({
    super.key,
    required this.message,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$message\n$error', textAlign: TextAlign.center),
          const Gap(8),
          OutlinedButton(
            onPressed: onRetry,
            child: const Text('Повторить'),
          ),
        ],
      ),
    );
  }
}
