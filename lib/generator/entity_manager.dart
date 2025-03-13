import 'package:yetiorm/yetiorm_reflected.dart';
import 'package:reflectable/reflectable.dart';

class EntityManager {
  static final Map<Type, EntityMetadata> _entities = {};

  static void registerEntity(Type entityType) {
    var classMirror = yetiORM.reflectType(entityType) as ClassMirror;

    // dart format off
    var entityAnnotation =
        classMirror.metadata.firstWhere(
              (m) => m is Entity,
              orElse: () => throw 
                            Exception(
                              "Class ${classMirror.simpleName} is missing "
                              "@Entity annotation"),
          )
        as Entity;
    // dart format on
    var tableName = entityAnnotation.tableName ?? classMirror.simpleName;
    var columns = <String, ColumnMetadata>{};

    for (var field in classMirror.declarations.values) {
      if (field is VariableMirror) {
        final metadataList = <Object?>[];
        metadataList.addAll(field.metadata);

        var primaryKeyAnnotation =
            metadataList.firstWhere((m) => m is PrimaryKey, orElse: () => null)
                as PrimaryKey?;
        var columnAnnotation =
            metadataList.firstWhere((m) => m is Column, orElse: () => null)
                as Column?;

        if (columnAnnotation != null || primaryKeyAnnotation != null) {
          // dart format off
          var columnName = columnAnnotation?.name ?? field.simpleName;
          var isPrimaryKey = primaryKeyAnnotation
                            != null 
                            || (columnAnnotation?.isPrimaryKey ?? false);
          // dart format on
          var isUnique = columnAnnotation?.isUnique ?? false;
          var isNullable = columnAnnotation?.isNullable ?? true;

          columns[columnName] = ColumnMetadata(
            name: columnName,
            isPrimaryKey: isPrimaryKey,
            isUnique: isUnique,
            isNullable: isNullable,
          );
        }
      }
    }
    _entities[entityType] = EntityMetadata(
      tableName: tableName,
      columns: columns,
    );
  }

  static String generateCreateTable(Type entityType) {
    var metadata = _entities[entityType];
    if (metadata == null) throw Exception("Entity not registered: $entityType");
    // dart format off
    List<String> columns = metadata.columns.values.map((column) {
      return "${column.name} ${column.isPrimaryKey ? 'INTEGER PRIMARY KEY' : 'TEXT'}"
              "${column.isUnique ? ' UNIQUE' : ''}"
              "${!column.isNullable ? ' NOT NULL' : ''}";
    }).toList();
    // dart format on
    return "CREATE TABLE ${metadata.tableName} (${columns.join(', ')});";
  }
}
