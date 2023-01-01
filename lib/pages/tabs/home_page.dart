import 'package:flutter/material.dart';

import 'package:flutter_v2ex/components/home/search_bar.dart';
import 'package:flutter_v2ex/components/home/sticky_bar.dart';
import 'package:flutter_v2ex/components/home/list_item.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List entries = <Map<dynamic, dynamic>>[
    {
      'name': '老强老强老强老强老强老强老强老强老强',
      'avatar':
          'https://desk-fd.zol-img.com.cn/t_s960x600c5/g6/M00/03/0E/ChMkKWDZLXSICljFAC1U9uUHfekAARQfgG_oL0ALVUO515.jpg',
      'time': '3分钟前',
      'title': '一个数字内容分享、交易、传递的平台。',
      'content':
          '你可以发布一个其他人需要付费才能看到的隐藏内容，可以是一条有价值的信息，也可以是一个存放内容的网络链接等等。价格由两部分构成，单价和总价，其他人支付单价后就可以看到你设置的隐藏内容，总价则是这个隐藏内容的总价值，也就是你将得到的总收益。',
      'favStatus': false,
      'node': '闲聊'
    },
    {
      'name': '悟空',
      'avatar':
          'https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fc-ssl.duitang.com%2Fuploads%2Fblog%2F202106%2F13%2F20210613235426_7a793.thumb.1000_0.jpeg&refer=http%3A%2F%2Fc-ssl.duitang.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=auto?sec=1675005260&t=75f085d73ba294620cfeef2330ac47d4https://cdn.v2ex.com/avatar/f5d8/fdcc/364260_large.png?m=1552188644',
      'time': '3分钟前',
      'title': '"硬酷 R1" 诞生记，分享一下那些有趣的人和事，附赠福利',
      'content':
          '在产品还没正式定型前，我们内部称之为“魔方”，“硬酷”的名字来源于首批预售小伙伴的共同讨论。“R1”是产品的代号。感谢为“硬酷 R1”开发贡献价值的工厂研发、硬件 PM 、Lean 大神和首批预售客户。',
      'favStatus': false,
      'node': '每个月都会出现的那种主题'
    },
    {
      'name': '老强老强老强老强老强老强老强老强老强',
      'avatar':
          'https://desk-fd.zol-img.com.cn/t_s960x600c5/g6/M00/03/0E/ChMkKWDZLXSICljFAC1U9uUHfekAARQfgG_oL0ALVUO515.jpg',
      'time': '3分钟前',
      'title': '尝试收集大家的 2022',
      'content':
          '如题，大概咨询了周围的人 https://github.com/xly135846/-/blob/main/2022.md 如果不介意也分享一下，又或者从中获取到了部分力量，可以直接回答 引导的问答如下：',
      'favStatus': false,
      'node': '闲聊'
    },
    {
      'name': '悟空',
      'avatar':
          'https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fc-ssl.duitang.com%2Fuploads%2Fblog%2F202106%2F13%2F20210613235426_7a793.thumb.1000_0.jpeg&refer=http%3A%2F%2Fc-ssl.duitang.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=auto?sec=1675005260&t=75f085d73ba294620cfeef2330ac47d4',
      'time': '3分钟前',
      'title': '想买一台笔记本装 Linux ，必须有 6800H/125(7)00H， 32G 内存，指纹能用， LCD',
      'content': '最近忙吗？昨晚我去了你最爱的那家饭馆，点了他们的特色豆花鱼，吃着吃着就想起你来了，还记得当初第一次就是在这里遇见',
      'favStatus': false,
      'node': '每个月都会出现的那种主题'
    },
    {
      'name': '老强老强老强老强老强老强老强老强老强',
      'avatar':
          'https://desk-fd.zol-img.com.cn/t_s960x600c5/g6/M00/03/0E/ChMkKWDZLXSICljFAC1U9uUHfekAARQfgG_oL0ALVUO515.jpg',
      'time': '3分钟前',
      'title': 'mac 上有适合 4 岁小朋友学习电脑的软件吗？',
      'content': '办公用需要两台机器互通硬盘比较方便一点。',
      'favStatus': false,
      'node': '闲聊'
    },
    {
      'name': '悟空',
      'avatar':
          'https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fc-ssl.duitang.com%2Fuploads%2Fblog%2F202106%2F13%2F20210613235426_7a793.thumb.1000_0.jpeg&refer=http%3A%2F%2Fc-ssl.duitang.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=auto?sec=1675005260&t=75f085d73ba294620cfeef2330ac47d4',
      'time': '3分钟前',
      'title': 'HCIE IGP 高级特性 OSPF 快速收敛/路由控制',
      'content': '最近忙吗？昨晚我去了你最爱的那家饭馆，点了他们的特色豆花鱼，吃着吃着就想起你来了，还记得当初第一次就是在这里遇见',
      'favStatus': false,
      'node': '每个月都会出现的那种主题'
    },
    {
      'name': '老强老强老强老强老强老强老强老强老强',
      'avatar':
          'https://desk-fd.zol-img.com.cn/t_s960x600c5/g6/M00/03/0E/ChMkKWDZLXSICljFAC1U9uUHfekAARQfgG_oL0ALVUO515.jpg',
      'time': '3分钟前',
      'title': '一个 14 岁初中生开发的前端工具库，轻量级高可用，各位可以体验一下',
      'content': '办公用需要两台机器互通硬盘比较方便一点。',
      'favStatus': false,
      'node': '闲聊'
    },
    {
      'name': '悟空',
      'avatar':
          'https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fc-ssl.duitang.com%2Fuploads%2Fblog%2F202106%2F13%2F20210613235426_7a793.thumb.1000_0.jpeg&refer=http%3A%2F%2Fc-ssl.duitang.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=auto?sec=1675005260&t=75f085d73ba294620cfeef2330ac47d4',
      'time': '3分钟前',
      'title': '豆花鱼',
      'content': '最近忙吗？昨晚我去了你最爱的那家饭馆，点了他们的特色豆花鱼，吃着吃着就想起你来了，还记得当初第一次就是在这里遇见',
      'favStatus': false,
      'node': '每个月都会出现的那种主题'
    },
    {
      'name': '老强老强老强老强老强老强老强老强老强',
      'avatar':
          'https://desk-fd.zol-img.com.cn/t_s960x600c5/g6/M00/03/0E/ChMkKWDZLXSICljFAC1U9uUHfekAARQfgG_oL0ALVUO515.jpg',
      'time': '3分钟前',
      'title': '豆花鱼',
      'content': '办公用需要两台机器互通硬盘比较方便一点。',
      'favStatus': false,
      'node': '闲聊'
    }
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
      body: Container(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(
              child: HomeSearchBar(),
            ),
            const HomeStickyBar(),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return ListItem(index: index, item: entries[index]);
                },
                childCount: entries.length,
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 10),
            )
          ],
        ),
      ),
    );
  }
}
