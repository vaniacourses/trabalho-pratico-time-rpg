abstract class Habilidade {
  final String nome;
  final String descricao;
  final int custo; // Custo de mana, energia, etc.
  final int nivelExigido;

  Habilidade({
    required this.nome,
    required this.descricao,
    required this.custo,
    required this.nivelExigido,
  });

  // Método abstrato para o Strategy
  // void execute({required Combatente usuario, required Combatente alvo});
  // Nota: Deixaremos o método comentado por enquanto, pois a classe Combatente ainda será criada.
}