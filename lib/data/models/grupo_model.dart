import 'package:trabalho_rpg/domain/entities/combatente.dart';
import 'package:trabalho_rpg/domain/entities/grupo.dart';
import 'package:trabalho_rpg/domain/entities/inimigo.dart';
import 'package:trabalho_rpg/domain/entities/personagem.dart';

class GrupoModel<T extends Combatente> extends Grupo<T> {
  GrupoModel({
    required super.id,
    required super.nome,
    required super.membros,
  });

  factory GrupoModel.fromMap(Map<String, dynamic> map, List<T> membros) {
    return GrupoModel(
      id: map['id'],
      nome: map['nome'],
      membros: membros,
    );
  }

  Map<String, dynamic> toMap() {
    String tipo;
    if (T == Personagem) {
      tipo = 'personagem';
    } else if (T == Inimigo) {
      tipo = 'inimigo';
    } else {
      throw Exception('Tipo de grupo não suportado: $T');
    }

    return {
      'id': id,
      'nome': nome,
      'tipo': tipo,
    };
  }
}