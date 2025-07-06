import 'package:trabalho_rpg/domain/entities/arma.dart';
import 'package:trabalho_rpg/domain/entities/armadura.dart'; // Ensure Armadura is imported
import 'package:trabalho_rpg/domain/entities/classe_personagem.dart';
import 'package:trabalho_rpg/domain/entities/combatente.dart'; // Ensure Combatente is imported
import 'package:trabalho_rpg/domain/entities/habilidade.dart';
import 'package:trabalho_rpg/domain/entities/raca.dart';
//import 'atributos_base.dart'; // No longer needed directly if inherited via Combatente

class Personagem extends Combatente {
  final Raca raca;
  final ClassePersonagem classe;

  final Map<String, Arma> equipamentos; // Assuming this maps slot names to Arma objects
  final List<Habilidade> habilidadesConhecidas;

  Personagem({
    // Parâmetros da classe Pai (Combatente)
    required super.id,
    required super.nome,
    required super.nivel,
    required super.vidaMax,
    required super.classeArmadura,
    required super.atributosBase,
    required super.habilidadesPreparadas,
    super.arma, // Pass through to super
    super.armadura, // Pass through to super (now correctly typed in Combatente)

    // Parâmetros específicos de Personagem
    required this.raca,
    required this.classe,
    required this.equipamentos,
    required this.habilidadesConhecidas,
  });

  // Example copyWith method (if you have one and want it consistent)
  Personagem copyWith({
    String? id,
    String? nome,
    int? nivel,
    int? vidaMax,
    int? classeArmadura,
    Raca? raca,
    ClassePersonagem? classe,
    Arma? arma,
    Armadura? armadura,
    List<Habilidade>? habilidadesConhecidas,
    List<Habilidade>? habilidadesPreparadas,
    Map<String, Arma>? equipamentos, // Assuming this is the correct type
  }) {
    return Personagem(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      nivel: nivel ?? this.nivel,
      vidaMax: vidaMax ?? this.vidaMax,
      classeArmadura: classeArmadura ?? this.classeArmadura,
      raca: raca ?? this.raca,
      classe: classe ?? this.classe,
      atributosBase: atributosBase, // AtributosBase is immutable, often passed directly
      arma: arma ?? this.arma,
      armadura: armadura ?? this.armadura,
      habilidadesConhecidas: habilidadesConhecidas ?? this.habilidadesConhecidas,
      habilidadesPreparadas: habilidadesPreparadas ?? this.habilidadesPreparadas,
      equipamentos: equipamentos ?? this.equipamentos,
    );
  }
}