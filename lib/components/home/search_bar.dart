import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_v2ex/components/common/avatar.dart';
import 'package:flutter_v2ex/pages/login_page.dart';
import 'package:get/get.dart';

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 70,
      padding: const EdgeInsets.only(top: 10, right: 8, left: 8, bottom: 10),
      // decoration: BoxDecoration(border: Border.all()),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: Container(
          width: double.infinity,
          color: Theme.of(context).colorScheme.onInverseSurface,
          padding: const EdgeInsets.only(right: 8, left: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                onPressed: (() => {Scaffold.of(context).openDrawer()}),
                icon: const Icon(
                  Icons.menu,
                ),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.search_outlined,
                    color: Colors.grey,
                    size: 19,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '在vvex搜索内容',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              GestureDetector(
                // onTap: () => Utils.routeProfile('guozhigq', '', 'guozhigq'),
                // onTap: () => Utils.onLogin(),
                // onTap: () => {
                //   Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //       builder: (context) => const LoginPage(),
                //       fullscreenDialog: true,
                //     ),
                //   ).then((value) => {
                //         if (value['loginStatus'] == 'cancel')
                //           {SmartDialog.showToast('取消登录')}
                //       })
                // },
                onTap: () async{
                  var memberId = 'guozhigq';
                 var res = await Get.toNamed('/member/$memberId/topics', parameters: {'memberId': memberId});
                 if (res['loginStatus'] == 'cancel') {
                   SmartDialog.showToast('取消登录');
                 }
                },
                // child: Container(
                //   decoration: BoxDecoration(
                //     color: Theme.of(context).colorScheme.surfaceVariant,
                //     borderRadius: BorderRadius.circular(50),
                //   ),
                //   clipBehavior: Clip.antiAlias,
                //   width: 37,
                //   height: 37,
                //   child: Center(
                //     child: Icon(
                //       Icons.person_rounded,
                //       size: 22,
                //       color: Theme.of(context).colorScheme.primary,
                //     ),
                //   ),
                // ),
                child: const Hero(
                  tag: 'guozhigq',
                  child: CAvatar(
                    url: '',
                    size: 37,
                  ),
                ),
              ),
              // Text(
              //   'VVex',
              //   style: Theme.of(context)
              //       .textTheme
              //       .bodyLarge!
              //       .copyWith(fontWeight: FontWeight.bold),
              // ),
              // IconButton(
              //   icon: const Icon(Icons.search),
              //   onPressed: () => {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //         builder: (context) =>
              //             // pre代码解析为邮箱 bug fixed
              //             // const ListDetail(topicId: '907966'),
              //             // 分页
              //             const ListDetail(topicId: '908380'),
              //         // const ListDetail(topicId: '907145'),
              //       ),
              //     )
              //   },
              // )
            ],
          ),
        ),
      ),
    );
  }
}
