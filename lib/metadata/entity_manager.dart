import 'dart:mirrors';
import '../annotations/entity.dart';
import '../annotations/column.dart';
import '../annotations/primary_key.dart';

class EntityMetadata {
  EntityMetadata({required this.tableName, required this.columns});
  final String tableName;
  final Map<String, ColumnMetadata> columns;
}

class ColumnMetadata {
  final String name;
  final bool isUnique;
  final bool isNullable;
  final bool isPrimaryKey;

  ColumnMetadata({required this.name, required this.isUnique, required this.isNullable, required this.isPrimaryKey});
}

class EntityManager {
  static final Map<Type, EntityMetadata> _entities = {};

  static void registerEntity(Type entityType) {
    ClassMirror classMirror = reflectClass(entityType);

    var entityAnnotation =
        classMirror.metadata
                .firstWhere(
                  (m) => m.reflectee is Entity,
                  orElse: () => throw Exception("Class ${classMirror.simpleName} is missing @Entity annotation"),
                )
                .reflectee
            as Entity;

    String tableName = entityAnnotation.tableName ?? MirrorSystem.getName(classMirror.simpleName);

    Map<String, ColumnMetadata> columns = {};

    for (var field in classMirror.declarations.values) {
      if (field is VariableMirror) {
        var listOfInstanceMirror = <InstanceMirror?>[];
        for (var im in field.metadata) {
          listOfInstanceMirror.add(im);
        }
        var primaryKeyAnnotation =
            listOfInstanceMirror.firstWhere((m) => m?.reflectee is PrimaryKey, orElse: () => null)?.reflectee
                as PrimaryKey?;
        var columnAnnotation =
            listOfInstanceMirror.firstWhere((m) => m?.reflectee is Column, orElse: () => null)?.reflectee as Column?;

        if (columnAnnotation != null || primaryKeyAnnotation != null) {
          String columnName = columnAnnotation?.name ?? MirrorSystem.getName(field.simpleName);
          bool isPrimaryKey = primaryKeyAnnotation != null || (columnAnnotation?.isPrimaryKey ?? false);
          bool isUnique = columnAnnotation?.isUnique ?? false;
          bool isNullable = columnAnnotation?.isNullable ?? true;

          columns[columnName] = ColumnMetadata(
            name: columnName,
            isPrimaryKey: isPrimaryKey,
            isUnique: isUnique,
            isNullable: isNullable,
          );
        }
      }
    }

    _entities[entityType] = EntityMetadata(tableName: tableName, columns: columns);
  }

  static String generateCreateTable(Type entityType) {
    ClassMirror classMirror = reflectClass(entityType);

    var entityAnnotation =
        classMirror.metadata
                .firstWhere(
                  (m) => m.reflectee is Entity,
                  orElse: () => throw Exception("Class ${classMirror.simpleName} is missing @Entity annotation"),
                )
                .reflectee
            as Entity;

    String tableName = entityAnnotation.tableName ?? MirrorSystem.getName(classMirror.simpleName);
    List<String> columns = [];

    for (var field in classMirror.declarations.values) {
      if (field is VariableMirror) {
        var listOfInstanceMirror = <InstanceMirror?>[];
        for (var im in field.metadata) {
          listOfInstanceMirror.add(im);
        }
        var columnAnnotation =
            listOfInstanceMirror.firstWhere((m) => m?.reflectee is Column, orElse: () => null)?.reflectee as Column?;
        var primaryKeyAnnotation =
            listOfInstanceMirror.firstWhere((m) => m?.reflectee is PrimaryKey, orElse: () => null)?.reflectee
                as PrimaryKey?;

        if (columnAnnotation != null || primaryKeyAnnotation != null) {
          String columnName = columnAnnotation?.name ?? MirrorSystem.getName(field.simpleName);
          String columnType = field.type.reflectedType == int ? "INTEGER" : "TEXT";
          bool isPrimaryKey = primaryKeyAnnotation != null || (columnAnnotation?.isPrimaryKey ?? false);
          bool isUnique = columnAnnotation?.isUnique ?? false;
          bool isNullable = columnAnnotation?.isNullable ?? true;

          String columnSQL =
              "$columnName $columnType"
              "${isPrimaryKey ? ' PRIMARY KEY' : ''}"
              "${isUnique ? ' UNIQUE' : ''}"
              "${!isNullable ? ' NOT NULL' : ''}";

          columns.add(columnSQL);
        }
      }
    }

    return "CREATE TABLE $tableName (${columns.join(', ')});";
  }

  static EntityMetadata? getEntityMetadata(Type entityType) {
    return _entities[entityType];
  }
}
