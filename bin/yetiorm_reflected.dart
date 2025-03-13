import 'package:yetiorm/yetiorm_reflected.dart';

import 'yetiorm_reflected.reflectable.dart';

// model example for reflected user entity
@yetiORM
@Entity(tableName: "users")
class User {
  /// [@PrimaryKey()] is not necessary because isPrimaryKey is true on
  /// [@Column(name: "id", isPrimaryKey: true)].
  ///
  /// [@Column(name: "id", isPrimaryKey: true)] is not necessary because
  /// name is the same as the field name. So, just using [@PrimaryKey()]
  /// is enough. It is the same as [@Column(isPrimaryKey: true)].
  @PrimaryKey()
  int id;
  @Column(name: "name", isUnique: true)
  String name;
  @Column(name: "age", isNullable: false)
  int? age;

  User({required this.id, required this.name, this.age});
}

void main() {
  initializeReflectable();
  EntityManager.registerEntity(User);

  String sql = EntityManager.generateCreateTable(User);
  // dart format off
  print(sql); // CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT UNIQUE, age TEXT NOT NULL);
}
