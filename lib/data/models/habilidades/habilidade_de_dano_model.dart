import 'package:trabalho_rpg/domain/entities/alvo_de_acao.dart';
import 'package:trabalho_rpg/domain/entities/combatente.dart';
import 'package:trabalho_rpg/domain/entities/habilidade_de_dano.dart';

class HabilidadeDeDanoModel extends HabilidadeDeDano {
  HabilidadeDeDanoModel({
    required super.id,
    required super.nome,
    required super.descricao,
    required super.custo,
    required super.nivelExigido,
    required super.danoBase,
  });
  /// Construtor de fábrica para criar uma instância a partir de um Map do BD.
  factory HabilidadeDeDanoModel.fromMap(Map<String, dynamic> map) {
    return HabilidadeDeDanoModel(
      id: map['id'],
      nome: map['nome'],
      descricao: map['descricao'],
      custo: map['custo'],
      nivelExigido: map['nivelExigido'],
      danoBase: map['danoBase'] ?? 0,
    );
  }
  // CORRIGIDO: A lógica foi padronizada para usar o método getModificador.
  @override
  void execute({required Combatente autor, required AlvoDeAcao alvo}) {
    // Usando 'inteligencia' como exemplo para uma magia de dano.
    final danoTotal = danoBase + autor.atributosBase.getModificador('inteligencia');
    print('${autor.nome} usa ${nome}, causando $danoTotal de dano!');
    alvo.receberDano(danoTotal);
  }
  /// Método para converter a instância para um Map para o BD.
  Map<String, dynamic> toPersistenceMap() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'custo': custo,
      'nivelExigido': nivelExigido,
      'categoria': 'dano', // O "discriminador" para o repositório saber ler.
      'danoBase': danoBase,
      'curaBase': null, // Garante que a coluna de cura seja nula.
    };
  }
}