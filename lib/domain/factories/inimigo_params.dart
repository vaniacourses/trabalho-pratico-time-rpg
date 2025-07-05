import 'package:trabalho_rpg/domain/entities/atributos_base.dart';

/// Agrupa todos os parâmetros necessários para criar um novo inimigo.
class InimigoParams {
  final String nome;
  final int nivel;
  final String tipo; // Ex: "Besta", "Morto-Vivo"
  final AtributosBase atributos;
  final String? armaId; // ID da arma principal (opcional)
  final String? armaduraId; // ID da armadura (opcional)
  final List<String> habilidadesIds; // IDs das habilidades que ele terá

  InimigoParams({
    required this.nome,
    required this.nivel,
    required this.tipo,
    required this.atributos,
    this.armaId,
    this.armaduraId,
    this.habilidadesIds = const [],
  });
}