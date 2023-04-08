import 'package:flutter/material.dart';

class NetworkErrorPage extends StatelessWidget {
  final String? message;
  final VoidCallback? onRetry;
  const NetworkErrorPage({super.key, this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.mood_bad,
            size: 80.0,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 10.0),
          const Text(
            '网络请求失败',
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2.0),
          Text(
            message ?? '请检查您的网络连接，然后重试',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14.0),
          ),
          const SizedBox(height: 20.0),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }
}
