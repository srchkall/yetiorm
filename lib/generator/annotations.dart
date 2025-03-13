import 'package:reflectable/reflectable.dart';

class YetiORM extends Reflectable {
  const YetiORM()
    : super(
        invokingCapability,
        declarationsCapability,
        typeCapability,
        reflectedTypeCapability,
        metadataCapability,
      );
}

const yetiORM = YetiORM();

class Entity {
  final String? tableName;
  const Entity({this.tableName});
}

class Column {
  final String? name;
  final bool isPrimaryKey;
  final bool isUnique;
  final bool isNullable;

  const Column({
    this.name,
    this.isPrimaryKey = false,
    this.isUnique = false,
    this.isNullable = true,
  });
}

class PrimaryKey {
  const PrimaryKey();
}
