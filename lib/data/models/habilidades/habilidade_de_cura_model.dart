import 'package:trabalho_rpg/domain/entities/alvo_de_acao.dart';
import 'package:trabalho_rpg/domain/entities/combatente.dart';
import 'package:trabalho_rpg/domain/entities/habilidade_de_cura.dart';

class HabilidadeDeCuraModel extends HabilidadeDeCura {
  HabilidadeDeCuraModel({
    required super.id,
    required super.nome,
    required super.descricao,
    required super.custo,
    required super.nivelExigido,
    required super.curaBase,
  });
  /// Construtor de fábrica para criar uma instância a partir de um Map do BD.
  factory HabilidadeDeCuraModel.fromMap(Map<String, dynamic> map) {
    return HabilidadeDeCuraModel(
      id: map['id'],
      nome: map['nome'],
      descricao: map['descricao'],
      custo: map['custo'],
      nivelExigido: map['nivelExigido'],
      curaBase: map['curaBase'] ?? 0,
    );
  }
  // CORRIGIDO: A lógica foi padronizada para usar o método getModificador.
  @override
  void execute({required Combatente autor, required AlvoDeAcao alvo}) {
    // Usando 'sabedoria' como exemplo para uma magia de cura.
    final curaTotal = curaBase + autor.atributosBase.getModificador('sabedoria');
    print('${autor.nome} usa ${nome}, curando $curaTotal pontos de vida!');
    alvo.receberCura(curaTotal);
  }
  /// Método para converter a instância para um Map para o BD.
  Map<String, dynamic> toPersistenceMap() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'custo': custo,
      'nivelExigido': nivelExigido,
      'categoria': 'cura', // O "discriminador".
      'danoBase': null,
      'curaBase': curaBase,
    };
  }
}