import 'package:trabalho_rpg/data/models/habilidades/habilidade_model.dart';
import 'package:trabalho_rpg/domain/entities/combatente.dart';

class HabilidadeDeDanoModel extends HabilidadeModel {
  final int danoBase;

  HabilidadeDeDanoModel({
    required super.id,
    required super.nome,
    required super.descricao,
    required super.custo,
    required super.nivelExigido,
    required this.danoBase,
  });

  @override
  void execute({required Combatente autor, required Combatente alvo}) {
    final danoTotal = danoBase + (autor.atributosBase.forca / 2).floor();
    print('${autor.nome} usa ${nome} em ${alvo.nome}, causando $danoTotal de dano!');
    alvo.vidaAtual -= danoTotal;
    if (alvo.vidaAtual < 0) alvo.vidaAtual = 0;
  }

  // ATUALIZAÇÃO: Sobrescreve o método para adicionar seus próprios campos.
  @override
  Map<String, dynamic> toPersistenceMap() {
    final map = super.toPersistenceMap();
    map.addAll({
      'categoria': 'dano',
      'danoBase': danoBase,
    });
    return map;
  }
}