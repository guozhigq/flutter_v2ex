// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model_topic_detail.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TopicDetailModelAdapter extends TypeAdapter<TopicDetailModel> {
  @override
  final int typeId = 1;

  @override
  TopicDetailModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TopicDetailModel()
      ..topicId = fields[0] as String
      ..nodeId = fields[1] as String
      ..nodeName = fields[2] as String
      ..topicTitle = fields[3] as String
      ..createdId = fields[4] as String
      ..avatar = fields[5] as String
      ..replyCount = fields[6] as String
      ..createdTime = fields[7] as String
      ..visitorCount = fields[8] as String
      ..content = fields[9] as String
      ..contentRendered = fields[10] as String
      ..subtleList = (fields[11] as List).cast<TopicSubtleItem>()
      ..imgCount = fields[12] as int
      ..imgList = (fields[13] as List).cast<dynamic>()
      ..isAuth = fields[14] as bool
      ..token = fields[15] as String
      ..isFavorite = fields[16] as bool
      ..favoriteCount = fields[17] as int
      ..isThank = fields[18] as bool
      ..isAPPEND = fields[19] as bool
      ..isEDIT = fields[20] as bool
      ..isMOVE = fields[21] as bool
      ..totalPage = fields[22] as int
      ..replyList = (fields[23] as List).cast<ReplyItem>();
  }

  @override
  void write(BinaryWriter writer, TopicDetailModel obj) {
    writer
      ..writeByte(24)
      ..writeByte(0)
      ..write(obj.topicId)
      ..writeByte(1)
      ..write(obj.nodeId)
      ..writeByte(2)
      ..write(obj.nodeName)
      ..writeByte(3)
      ..write(obj.topicTitle)
      ..writeByte(4)
      ..write(obj.createdId)
      ..writeByte(5)
      ..write(obj.avatar)
      ..writeByte(6)
      ..write(obj.replyCount)
      ..writeByte(7)
      ..write(obj.createdTime)
      ..writeByte(8)
      ..write(obj.visitorCount)
      ..writeByte(9)
      ..write(obj.content)
      ..writeByte(10)
      ..write(obj.contentRendered)
      ..writeByte(11)
      ..write(obj.subtleList)
      ..writeByte(12)
      ..write(obj.imgCount)
      ..writeByte(13)
      ..write(obj.imgList)
      ..writeByte(14)
      ..write(obj.isAuth)
      ..writeByte(15)
      ..write(obj.token)
      ..writeByte(16)
      ..write(obj.isFavorite)
      ..writeByte(17)
      ..write(obj.favoriteCount)
      ..writeByte(18)
      ..write(obj.isThank)
      ..writeByte(19)
      ..write(obj.isAPPEND)
      ..writeByte(20)
      ..write(obj.isEDIT)
      ..writeByte(21)
      ..write(obj.isMOVE)
      ..writeByte(22)
      ..write(obj.totalPage)
      ..writeByte(23)
      ..write(obj.replyList);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TopicDetailModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
