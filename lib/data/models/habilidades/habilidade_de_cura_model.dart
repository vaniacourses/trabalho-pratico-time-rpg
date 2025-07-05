import 'package:trabalho_rpg/data/models/habilidade_model.dart';
import 'package:trabalho_rpg/domain/entities/alvo_de_acao.dart';
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
  void execute({required Combatente autor, required AlvoDeAcao alvo}) {
    final curaTotal = curaBase + (autor.atributosBase.sabedoria / 2).floor();
    print('${autor.nome} usa ${nome}, curando $curaTotal pontos de vida!');
    alvo.receberCura(curaTotal);
  }

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