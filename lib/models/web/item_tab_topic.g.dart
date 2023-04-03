// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_tab_topic.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TabTopicItemAdapter extends TypeAdapter<TabTopicItem> {
  @override
  final int typeId = 0;

  @override
  TabTopicItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TabTopicItem()
      ..readStatus = fields[0] as String
      ..memberId = fields[1] as String
      ..topicId = fields[2] as String
      ..avatar = fields[3] as String
      ..topicTitle = fields[4] as String
      ..replyCount = fields[5] as int
      ..clickCount = fields[6] as String
      ..nodeId = fields[7] as String
      ..nodeName = fields[8] as String
      ..lastReplyMId = fields[9] as String
      ..lastReplyTime = fields[10] as String;
  }

  @override
  void write(BinaryWriter writer, TabTopicItem obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.readStatus)
      ..writeByte(1)
      ..write(obj.memberId)
      ..writeByte(2)
      ..write(obj.topicId)
      ..writeByte(3)
      ..write(obj.avatar)
      ..writeByte(4)
      ..write(obj.topicTitle)
      ..writeByte(5)
      ..write(obj.replyCount)
      ..writeByte(6)
      ..write(obj.clickCount)
      ..writeByte(7)
      ..write(obj.nodeId)
      ..writeByte(8)
      ..write(obj.nodeName)
      ..writeByte(9)
      ..write(obj.lastReplyMId)
      ..writeByte(10)
      ..write(obj.lastReplyTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TabTopicItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
