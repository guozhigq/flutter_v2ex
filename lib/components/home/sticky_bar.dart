import 'package:flutter/material.dart';

class HomeStickyBar extends StatelessWidget {
  const HomeStickyBar({super.key, required this.tabs});
  final List<Map<dynamic, dynamic>> tabs;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 40,
      child: Row(
        children: [
          Expanded(
            child: TabBar(
              dividerColor: Colors.transparent,
              onTap: (index) {},
              isScrollable: true,
              enableFeedback: true,
              splashBorderRadius: BorderRadius.circular(6),
              tabs: tabs.map((item) {
                return Tab(text: item['name']);
              }).toList(),
            ),
          ),
          // const SizedBox(width: 5),
          SizedBox(
            height: 50,
            child: Center(
              child: IconButton(
                onPressed: () => {Navigator.pushNamed(context, '/nodes')},
                icon: const Icon(Icons.segment),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
