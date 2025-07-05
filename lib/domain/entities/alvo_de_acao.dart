/// Define uma interface comum para qualquer coisa que possa ser um alvo de uma ação,
/// seja um combatente individual ou um grupo. (Componente do padrão Composite)
abstract class AlvoDeAcao {
  /// Aplica uma quantidade de dano ao alvo.
  void receberDano(int quantidade);

  /// Aplica uma quantidade de cura ao alvo.
  void receberCura(int quantidade);
}