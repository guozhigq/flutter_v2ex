// 帖子详情页下附言
import 'package:hive/hive.dart';
part 'item_topic_subtle.g.dart';

@HiveType(typeId: 3)
class TopicSubtleItem {
  @HiveField(0)
  String fade = '';
  @HiveField(1)
  String content = '';
}
