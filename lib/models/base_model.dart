import 'package:hive/hive.dart';

abstract class BaseModel<T> {
  String get id;
  Map<String, dynamic> toJson();
  T fromJson(Map<String, dynamic> json);
  
  // Hive type id for adapters
  int get typeId;
  
  // Convert to Hive-compatible map
  Map<String, dynamic> toHive() => toJson();
  
  // Create from Hive map
  T fromHive(Map<String, dynamic> json) => fromJson(json);
}

// Helper class for Hive type adapters
abstract class HiveTypeAdapter<T extends BaseModel<T>> extends TypeAdapter<T> {
  @override
  T read(BinaryReader reader) {
    final json = Map<String, dynamic>.from(reader.readMap());
    return fromHive(json);
  }

  @override
  void write(BinaryWriter writer, T obj) {
    writer.writeMap(obj.toHive());
  }
  
  T fromHive(Map<String, dynamic> json);
}
