import 'package:trabalho_rpg/domain/entities/alvo_de_acao.dart';
import 'package:trabalho_rpg/domain/entities/combatente.dart';

// ATUALIZAÇÃO: Agora implementa a interface AlvoDeAcao
class Grupo<T extends Combatente> implements AlvoDeAcao {
  final String id;
  String nome;
  List<T> membros;

  Grupo({
    required this.id,
    required this.nome,
    required this.membros,
  });

  // ATUALIZAÇÃO: Implementação dos métodos da interface.
  // A lógica é delegar a ação para cada membro do grupo.
  @override
  void receberDano(int quantidade) {
    print('O grupo "${nome}" é atingido por dano em área!');
    for (final membro in membros) {
      membro.receberDano(quantidade);
    }
  }

  @override
  void receberCura(int quantidade) {
    print('O grupo "${nome}" é atingido por cura em área!');
    for (final membro in membros) {
      membro.receberCura(quantidade);
    }
  }
}