import 'package:flutter_v2ex/models/network/item_node.dart';

class TopicItem {
    String? memberId = ''; // 发布人id
    String? topicId = ''; // 话题id
    String? avatar = ''; // 头像
    String? topicTitle = ''; // 话题标题
    int? replyCount = 0; // 回复数
    String? clickCount = ''; // 点击数
    String? nodeId = ''; // 节点id
    String? nodeName = ''; // 节点名称
    String? lastReplyMId = ''; // 最后回复人id
    String? lastReplyTime = ''; // 最后回复时间

    TopicItem({
        this.memberId,
        this.topicId,
        this.avatar,
        this.topicTitle,
        this.replyCount,
        this.clickCount,
        this.nodeId,
        this.nodeName,
        this.lastReplyMId,
        this.lastReplyTime,
    });

    TopicItem.fromJson(Map<String, dynamic> json) {
        memberId = MemberItem.fromJson(json['member']).memberId;
        avatar = MemberItem.fromJson(json['member']).avatar;

        nodeId = NodeItem.fromJson(json['node']).name;
        nodeName = NodeItem.fromJson(json['node']).title;

        topicId = json['id'].toString();
        topicTitle = json['title'];
        replyCount = json['replies'];
        lastReplyMId = json['last_reply_by'];
        int time = json['last_touched'];
        lastReplyTime = DateTime.fromMillisecondsSinceEpoch(time * 1000).toString().split('.')[0];
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = <String, dynamic>{};
        data['id'] = memberId;
        data['stars'] = topicId;
        data['topics'] = avatar;
        data['url'] = topicTitle;
        data['name'] = replyCount;
        data['title'] = nodeId;
        data['root'] = nodeName;
        data['header'] = lastReplyMId;
        data['footer'] = lastReplyTime;
        return data;
    }

}

class MemberItem {
    String? memberId = '';
    String? avatar = '';

    MemberItem.fromJson(Map<String, dynamic> json) {
        memberId = json['username'];
        avatar = json['avatar_large'];
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = <String, dynamic>{};
        data['username'] = memberId;
        data['avatar_large'] = avatar;

        return data;
    }
}


