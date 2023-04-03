// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_topic_reply.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReplyItemAdapter extends TypeAdapter<ReplyItem> {
  @override
  final int typeId = 2;

  @override
  ReplyItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReplyItem()
      ..isOwner = fields[0] as bool
      ..avatar = fields[1] as String
      ..userName = fields[2] as String
      ..lastReplyTime = fields[3] as String
      ..content = fields[4] as String
      ..contentRendered = fields[5] as String
      ..replyId = fields[6] as String
      ..favorites = fields[7] as int
      ..favoritesStatus = fields[8] as bool
      ..number = fields[9] as String
      ..floorNumber = fields[10] as int
      ..platform = fields[11] as String
      ..isChoose = fields[12] as bool
      ..replyMemberList = (fields[13] as List).cast<dynamic>()
      ..imgList = (fields[14] as List).cast<dynamic>()
      ..isMod = fields[15] as bool;
  }

  @override
  void write(BinaryWriter writer, ReplyItem obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.isOwner)
      ..writeByte(1)
      ..write(obj.avatar)
      ..writeByte(2)
      ..write(obj.userName)
      ..writeByte(3)
      ..write(obj.lastReplyTime)
      ..writeByte(4)
      ..write(obj.content)
      ..writeByte(5)
      ..write(obj.contentRendered)
      ..writeByte(6)
      ..write(obj.replyId)
      ..writeByte(7)
      ..write(obj.favorites)
      ..writeByte(8)
      ..write(obj.favoritesStatus)
      ..writeByte(9)
      ..write(obj.number)
      ..writeByte(10)
      ..write(obj.floorNumber)
      ..writeByte(11)
      ..write(obj.platform)
      ..writeByte(12)
      ..write(obj.isChoose)
      ..writeByte(13)
      ..write(obj.replyMemberList)
      ..writeByte(14)
      ..write(obj.imgList)
      ..writeByte(15)
      ..write(obj.isMod);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReplyItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
