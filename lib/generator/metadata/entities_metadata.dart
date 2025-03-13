class ColumnMetadata {
  final String name;
  final bool isUnique;
  final bool isNullable;
  final bool isPrimaryKey;

  ColumnMetadata({
    required this.name,
    required this.isUnique,
    required this.isNullable,
    required this.isPrimaryKey,
  });
}

class EntityMetadata {
  final String tableName;
  final Map<String, ColumnMetadata> columns;

  EntityMetadata({required this.tableName, required this.columns});
}
