import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_v2ex/http/init.dart';
import 'package:webfeed_plus/webfeed_plus.dart';

class HistoryHotPage extends StatefulWidget {
  const HistoryHotPage({Key? key}) : super(key: key);

  @override
  State<HistoryHotPage> createState() => _HistoryHotPageState();
}

class _HistoryHotPageState extends State<HistoryHotPage> {
  List _tabs = [];
  AtomFeed? _atomFeed;

  Future<AtomFeed> getHistoryHot() async {
    // Atom feed
    var res = await Request().get('https://v2exday.com/allinone.xml');
    var atomFeed = AtomFeed.parse(res.data); // 返回4天的
    List tabs = [];
    for (var i in atomFeed.items!) {
      tabs.add({
        'name': i.title!
            .split(']')[0]
            .replaceFirst('-', '.')
            .split('.')[1]
            .replaceFirst('-', '/')
      });
    }
    setState(() {
      _tabs = tabs;
      _atomFeed = atomFeed;
    });
    return atomFeed;
  }

  void openHrefByWebview(String? aUrl) async {
    List arr = aUrl!.split('.com');
    var tHref = arr[1].split('#')[0];
    Get.toNamed(tHref);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getHistoryHot();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: TabBar(
            isScrollable: true,
            enableFeedback: true,
            splashBorderRadius: BorderRadius.circular(6),
            dividerColor: Colors.transparent,
            tabs: _tabs.map((item) {
              return Tab(text: item['name']);
            }).toList(),
          ),
        ),
        body: _atomFeed != null
            ? TabBarView(
                children: _atomFeed!.items!.map((e) {
                  return SingleChildScrollView(
                      padding: const EdgeInsets.only(
                          top: 0, left: 20, right: 20, bottom: 30),
                      child: Html(
                        data: e.content,
                        onLinkTap: (url, buildContext, attributes) =>
                            {openHrefByWebview(url!)},
                        style: {
                          "html": Style(
                            fontSize: FontSize.medium,
                            lineHeight: LineHeight.percent(140),
                          ),
                          "body": Style(
                              margin: Margins.zero, padding: HtmlPaddings.zero),
                          "a": Style(
                            before: '「 ',
                            after: ' 」',
                            fontSize: FontSize(15),
                            color: Theme.of(context).colorScheme.primary,
                            textDecoration: TextDecoration.none,
                          ),
                        },
                      ));
                }).toList(),
              )
            : null,
      ),
    );
  }
}
