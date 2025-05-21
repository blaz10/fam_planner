abstract class BaseModel<T> {
  String get id;
  
  /// Converts the model to a JSON map
  Map<String, dynamic> toJson();
  
  /// Creates an instance of the model from a JSON map
  T fromJson(Map<String, dynamic> json);
  
  /// Hive type ID for adapters (must be overridden in concrete classes)
  static int get typeId => throw UnimplementedError('typeId getter not implemented');
  
  /// Converts the model to a Hive-compatible map
  Map<String, dynamic> toHive() => toJson();
  
  /// Creates an instance of the model from a Hive map
  T fromHive(Map<String, dynamic> json) => fromJson(json);
  
  /// Register the Hive adapter for this model
  static void registerHiveAdapter() {
    // Should be overridden by concrete classes
    throw UnimplementedError('registerHiveAdapter() must be implemented');
  }
}
