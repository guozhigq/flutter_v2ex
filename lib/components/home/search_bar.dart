import 'package:flutter/material.dart';

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 65,
      padding: const EdgeInsets.only(top: 10, right: 13, left: 13, bottom: 10),
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: Container(
          width: double.infinity,
          height: 45,
          color: Theme.of(context).colorScheme.onInverseSurface,
          padding: const EdgeInsets.only(right: 11, left: 18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                const Icon(Icons.search_outlined),
                const SizedBox(width: 12),
                Text(
                  '搜索...',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ]),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(50),
                ),
                clipBehavior: Clip.antiAlias,
                // child: Image.asset(
                //   'assets/images/avatar.png',
                //   fit: BoxFit.cover,
                //   width: 35,
                //   height: 35,
                // ),
                width: 33,
                height: 33,
                child: const Center(
                  child: Text('V'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
