import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomLoading extends StatelessWidget {
  String msg = '加载中';
  CustomLoading({required this.msg, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      padding: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
          color: Theme.of(context).dialogTheme.backgroundColor ??
              Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            strokeWidth: 3,
          ),
          const SizedBox(height: 15),
          Text(
            msg,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ],
      ),
    );
  }
}

class CustomToast extends StatelessWidget {
  final String msg;
  const CustomToast({Key? key, required this.msg}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
              color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.05),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 0)
          ),
        ],
      ),
      child: Text(msg,
          style: Theme.of(context)
              .textTheme
              .titleSmall!
              .copyWith(color: Theme.of(context).colorScheme.primary)),
    );
  }
}
