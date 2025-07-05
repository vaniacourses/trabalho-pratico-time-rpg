import 'package:trabalho_rpg/domain/entities/habilidade.dart';

// Esta classe agora também precisa implementar o método da sua superclasse.
abstract class HabilidadeModel extends Habilidade {
  HabilidadeModel({
    required super.id,
    required super.nome,
    required super.descricao,
    required super.custo,
    required super.nivelExigido,
  });

  // Implementação base que lida com os campos comuns.
  @override
  Map<String, dynamic> toPersistenceMap() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'custo': custo,
      'nivelExigido': nivelExigido,
    };
  }
}