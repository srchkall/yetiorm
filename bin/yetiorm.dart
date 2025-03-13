import 'package:yetiorm/yetiorm.dart';

@Entity(tableName: "users")
class User {
  @PrimaryKey()
  int id;

  @Column(name: "full_name", isUnique: true, isNullable: false)
  String name;

  @Column()
  int? age;

  User({required this.id, required this.name, this.age});
}

void main() {
  // Registrar a entidade
  EntityManager.registerEntity(User);

  // Obter metadados da entidade
  var metadata = EntityManager.getEntityMetadata(User);

  if (metadata != null) {
    print("Tabela: ${metadata.tableName}");
    for (var column in metadata.columns.entries) {
      print(
        "Coluna: ${column.key}, Primária: ${column.value.isPrimaryKey}, Única: ${column.value.isUnique}",
      );
    }
  } else {
    print("Erro: Entidade não registrada!");
  }

  // SQL para criar a tabela
  String sql = EntityManager.generateCreateTable(User);
  print(sql);
}
