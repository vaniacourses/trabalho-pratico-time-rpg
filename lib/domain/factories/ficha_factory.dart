import 'package:trabalho_rpg/domain/entities/inimigo.dart';
import 'package:trabalho_rpg/domain/entities/personagem.dart';
import 'package:trabalho_rpg/domain/factories/inimigo_params.dart';
import 'package:trabalho_rpg/domain/factories/personagem_params.dart';

abstract class IFichaFactory {
  Future<Personagem> criarPersonagem(PersonagemParams params);
  Future<Inimigo> criarInimigo(InimigoParams params);
}