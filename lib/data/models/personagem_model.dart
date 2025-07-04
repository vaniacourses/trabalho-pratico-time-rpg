import 'package:trabalho_rpg/domain/entities/atributos_base.dart';
import 'package:trabalho_rpg/domain/entities/personagem.dart';
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
  }) : super(
         // Listas complexas que dependem de tabelas de junção
         // são inicializadas como vazias por enquanto.
         habilidadesPreparadas: [],
         habilidadesConhecidas: [],
         equipamentos: {},
       );

  /// Construtor de fábrica para criar uma instância a partir de um Map do BD.
  /// Este método assume que os dados de Raça e Classe já foram buscados
  /// e estão sendo passados como objetos.
  factory PersonagemModel.fromMap(
    Map<String, dynamic> map, {
    required RacaModel raca,
    required ClassePersonagemModel classe,
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
      // Chaves estrangeiras
      'racaId': raca.id,
      'classeId': classe.id,
      // Atributos desnormalizados
      'forca': atributosBase.forca,
      'destreza': atributosBase.destreza,
      'constituicao': atributosBase.constituicao,
      'inteligencia': atributosBase.inteligencia,
      'sabedoria': atributosBase.sabedoria,
      'carisma': atributosBase.carisma,
    };
  }
}
