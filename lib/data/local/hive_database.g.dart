// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_database.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecipeHiveAdapter extends TypeAdapter<RecipeHive> {
  @override
  final int typeId = 0;

  @override
  RecipeHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecipeHive(
      id: fields[0] as String,
      name: fields[1] as String,
      thumbnail: fields[2] as String?,
      matchCount: fields[3] as int,
      ingredients: (fields[4] as List).cast<String>(),
      instructions: fields[5] as String?,
      category: fields[6] as String?,
      youtubeLink: fields[7] as String?,
      measures: (fields[8] as List?)?.cast<String>(),
      lastAccessed: fields[9] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, RecipeHive obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.thumbnail)
      ..writeByte(3)
      ..write(obj.matchCount)
      ..writeByte(4)
      ..write(obj.ingredients)
      ..writeByte(5)
      ..write(obj.instructions)
      ..writeByte(6)
      ..write(obj.category)
      ..writeByte(7)
      ..write(obj.youtubeLink)
      ..writeByte(8)
      ..write(obj.measures)
      ..writeByte(9)
      ..write(obj.lastAccessed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecipeHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
