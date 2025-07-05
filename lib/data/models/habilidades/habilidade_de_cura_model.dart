import 'package:trabalho_rpg/data/models/habilidades/habilidade_model.dart';
import 'package:trabalho_rpg/domain/entities/combatente.dart';

class HabilidadeDeCuraModel extends HabilidadeModel {
  final int curaBase;

  HabilidadeDeCuraModel({
    required super.id,
    required super.nome,
    required super.descricao,
    required super.custo,
    required super.nivelExigido,
    required this.curaBase,
  });

  @override
  void execute({required Combatente autor, required Combatente alvo}) {
    final curaTotal = curaBase + (autor.atributosBase.sabedoria / 2).floor();
    print('${autor.nome} usa ${nome} em ${alvo.nome}, curando $curaTotal pontos de vida!');
    alvo.vidaAtual += curaTotal;
    if (alvo.vidaAtual > alvo.vidaMax) alvo.vidaAtual = alvo.vidaMax;
  }

  // ATUALIZAÇÃO: Sobrescreve o método para adicionar seus próprios campos.
  @override
  Map<String, dynamic> toPersistenceMap() {
    final map = super.toPersistenceMap();
    map.addAll({
      'categoria': 'cura',
      'curaBase': curaBase,
    });
    return map;
  }
}