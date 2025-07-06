import 'package:trabalho_rpg/domain/entities/arma.dart';
import 'package:trabalho_rpg/domain/entities/armadura.dart';
import 'package:trabalho_rpg/domain/entities/atributos_base.dart';
import 'package:trabalho_rpg/domain/entities/personagem.dart';
import 'package:trabalho_rpg/domain/entities/habilidade.dart';
import 'classe_personagem_model.dart';
import 'raca_model.dart';

class PersonagemModel extends Personagem {
  PersonagemModel({
    required super.id,
    required super.nome,
    required super.nivel,
    required super.vidaMax,
    required super.classeArmadura,
    required super.atributosBase,
    required super.raca,
    required super.classe,
    // Adicionamos os campos que agora serão persistidos
    super.arma,
    super.armadura,
    required super.habilidadesConhecidas,
    required super.habilidadesPreparadas,
    required super.equipamentos,
  });

  factory PersonagemModel.fromMap(
    Map<String, dynamic> map, {
    required RacaModel raca,
    required ClassePersonagemModel classe,
    // Os campos opcionais agora são passados aqui
    Arma? arma,
    Armadura? armadura,
    // As listas serão preenchidas pelo repositório após a busca principal
    List<Habilidade> habilidadesConhecidas = const [],
    List<Habilidade> habilidadesPreparadas = const [],
    Map<String, Arma> equipamentos = const {},
  }) {
    return PersonagemModel(
      id: map['id'],
      nome: map['nome'],
      nivel: map['nivel'],
      vidaMax: map['vidaMax'],
      classeArmadura: map['classeArmadura'],
      atributosBase: AtributosBase(
        forca: map['forca'],
        destreza: map['destreza'],
        constituicao: map['constituicao'],
        inteligencia: map['inteligencia'],
        sabedoria: map['sabedoria'],
        carisma: map['carisma'],
      ),
      raca: raca,
      classe: classe,
      arma: arma,
      armadura: armadura,
      habilidadesConhecidas: habilidadesConhecidas,
      habilidadesPreparadas: habilidadesPreparadas,
      equipamentos: equipamentos,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'nivel': nivel,
      'vidaMax': vidaMax,
      'classeArmadura': classeArmadura,
      'racaId': raca.id,
      'classeId': classe.id,
      // Campos de chave estrangeira atualizados (podem ser nulos)
      'armaId': arma?.id,
      'armaduraId': armadura?.id,
      // Atributos
      'forca': atributosBase.forca,
      'destreza': atributosBase.destreza,
      'constituicao': atributosBase.constituicao,
      'inteligencia': atributosBase.inteligencia,
      'sabedoria': atributosBase.sabedoria,
      'carisma': atributosBase.carisma,
    };
  }
}
