import 'package:get/get.dart';
import 'package:flutter_v2ex/service/i18n_keyword.dart';

class Translation extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'zh_CN': {
          I18nKeyword.drawer: '抽屉',
          I18nKeyword.search: '搜索',
          I18nKeyword.avatar: '头像',
          I18nKeyword.notice: '消息',
          I18nKeyword.node: '节点',
          I18nKeyword.todayHot: '今日热议',
          I18nKeyword.history: '最近浏览',
          I18nKeyword.myFollow: '我的关注',
          I18nKeyword.myFavorite: '我的收藏',
          I18nKeyword.createTopic: '发布主题',
          I18nKeyword.chooseTheme: '选择主题',
          I18nKeyword.setting: '设置',
          I18nKeyword.help: '帮助',
          I18nKeyword.searchPower: '搜索功能由soV2ex提供',
          I18nKeyword.createdTime: '发帖时间',
          I18nKeyword.startDate: '起始时间',
          I18nKeyword.endDate: '结束时间',
          I18nKeyword.recentPriority: '最近优先',
          I18nKeyword.historicalPriority: '历史优先',
          I18nKeyword.selectOrder: '选择升降序',
          I18nKeyword.noData: '没有数据',
          I18nKeyword.clearHistory: '清除浏览记录',

          // topic
          I18nKeyword.replies: '回复',
          I18nKeyword.replyAction: '回复',
          I18nKeyword.topicClick: '点击',
          I18nKeyword.topicFav: '收藏',
          I18nKeyword.topicIgnore: '忽略主题',
          I18nKeyword.topicShare: '分享',
          I18nKeyword.topicReport: '举报',
          I18nKeyword.topicThank: '感谢',
          I18nKeyword.openInBrowser: '在浏览器中打开',
          I18nKeyword.replyThank: '感谢',
          I18nKeyword.viewResponse: '查看回复',
          I18nKeyword.noMoreResponses: '没有更多回复了',
        },
        'en_US': {
          I18nKeyword.drawer: 'Drawer',
          I18nKeyword.search: 'Search',
          I18nKeyword.avatar: 'Avatar',
          I18nKeyword.notice: 'Notice',
          I18nKeyword.node: 'node',
          I18nKeyword.todayHot: 'Today Hot',
          I18nKeyword.history: 'History',
          I18nKeyword.myFollow: 'My Follow',
          I18nKeyword.myFavorite: 'My Favorite',
          I18nKeyword.createTopic: 'Create Topic',
          I18nKeyword.chooseTheme: 'Choose Theme',
          I18nKeyword.setting: 'Setting',
          I18nKeyword.help: 'Help',
          I18nKeyword.searchPower: 'The search function is provided by sov2ex',
          I18nKeyword.createdTime: 'createdTime',
          I18nKeyword.startDate: 'startDate',
          I18nKeyword.endDate: 'endDate',
          I18nKeyword.recentPriority: 'Recent Priority',
          I18nKeyword.historicalPriority: 'Historical Priority',
          I18nKeyword.selectOrder: 'Select Ascending or Descending Order',
          I18nKeyword.noData: 'no data',
          I18nKeyword.clearHistory: 'Clear browsing history',

          // topic
          I18nKeyword.replies: 'replies',
          I18nKeyword.replyAction: 'Reply',
          I18nKeyword.topicClick: 'Click',
          I18nKeyword.topicFav: 'Fav',
          I18nKeyword.topicIgnore: 'Ignore Topic',
          I18nKeyword.topicShare: 'Share',
          I18nKeyword.topicReport: 'Report Topic',
          I18nKeyword.topicThank: 'Thank Topic',
          I18nKeyword.openInBrowser: 'To open in a browser',
          I18nKeyword.replyThank: 'Thank',
          I18nKeyword.viewResponse: 'View Response',
          I18nKeyword.noMoreResponses: 'No more responses',

        },
        'de_DE': {
          'hello': 'Hallo Welt',
        }
      };
}
