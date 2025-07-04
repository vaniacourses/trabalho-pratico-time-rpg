import 'package:trabalho_rpg/domain/entities/classe_personagem.dart';

class ClassePersonagemModel extends ClassePersonagem {
  ClassePersonagemModel({
    required super.id,
    required super.nome,
    required super.proficienciaArmadura,
    required super.proficienciaArma,
    // Note que a lista de habilidades não está sendo persistida ainda.
    // Isso será adicionado em uma fase futura com tabelas de junção.
  }) : super(
         habilidadesDisponiveis: [],
       ); // Inicializa com lista vazia por enquanto

  /// Construtor de fábrica para criar uma instância a partir de um Map do BD.
  factory ClassePersonagemModel.fromMap(Map<String, dynamic> map) {
    return ClassePersonagemModel(
      id: map['id'],
      nome: map['nome'],
      proficienciaArmadura: map['proficienciaArmadura'],
      proficienciaArma: map['proficienciaArma'],
    );
  }

  /// Método para converter a instância para um Map para o BD.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'proficienciaArmadura': proficienciaArmadura,
      'proficienciaArma': proficienciaArma,
    };
  }
}
