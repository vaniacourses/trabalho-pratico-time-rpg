import 'package:trabalho_rpg/data/models/arma_model.dart';
import 'package:trabalho_rpg/domain/entities/arma.dart';
import 'package:trabalho_rpg/domain/entities/atributos_base.dart';
import 'package:trabalho_rpg/domain/entities/habilidade.dart';
import 'package:trabalho_rpg/domain/entities/inimigo.dart';

class InimigoModel extends Inimigo {
  InimigoModel({
    required super.id,
    required super.nome,
    required super.nivel,
    required super.vidaMax,
    required super.classeArmadura,
    required super.atributosBase,
    required super.habilidadesPreparadas,
    required super.tipo,
    super.arma,
    super.armadura,
  });

  /// Construtor de fábrica para criar uma instância a partir de um Map do BD.
  factory InimigoModel.fromMap(
    Map<String, dynamic> map, {
    Arma? arma,
    Arma? armadura,
    List<Habilidade> habilidades = const [],
  }) {
    return InimigoModel(
      id: map['id'],
      nome: map['nome'],
      nivel: map['nivel'],
      vidaMax: map['vidaMax'],
      classeArmadura: map['classeArmadura'],
      tipo: map['tipo'],
      atributosBase: AtributosBase(
        forca: map['forca'],
        destreza: map['destreza'],
        constituicao: map['constituicao'],
        inteligencia: map['inteligencia'],
        sabedoria: map['sabedoria'],
        carisma: map['carisma'],
      ),
      habilidadesPreparadas: habilidades,
      arma: arma,
      armadura: armadura,
    );
  }

  /// Método para converter a instância para um Map para o BD.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'nivel': nivel,
      'vidaMax': vidaMax,
      'classeArmadura': classeArmadura,
      'tipo': tipo,
      'armaId': arma?.id,
      'armaduraId': armadura?.id,
      'forca': atributosBase.forca,
      'destreza': atributosBase.destreza,
      'constituicao': atributosBase.constituicao,
      'inteligencia': atributosBase.inteligencia,
      'sabedoria': atributosBase.sabedoria,
      'carisma': atributosBase.carisma,
    };
  }
}