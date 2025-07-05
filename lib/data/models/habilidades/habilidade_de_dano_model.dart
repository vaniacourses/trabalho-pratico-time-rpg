import 'package:trabalho_rpg/data/models/habilidade_model.dart';
import 'package:trabalho_rpg/domain/entities/alvo_de_acao.dart';
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

  // ATUALIZAÇÃO: O alvo agora é um AlvoDeAcao e a lógica foi simplificada.
  @override
  void execute({required Combatente autor, required AlvoDeAcao alvo}) {
    final danoTotal = danoBase + (autor.atributosBase.forca / 2).floor();
    print('${autor.nome} usa ${nome}, causando $danoTotal de dano!');
    alvo.receberDano(danoTotal);
  }

  @override
  Map<String, dynamic> toPersistenceMap() {
    final map = super.toPersistenceMap();
    map.addAll({'categoria': 'dano', 'danoBase': danoBase});
    return map;
  }
}