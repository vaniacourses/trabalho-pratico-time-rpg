import 'package:flutter/material.dart';
import 'package:trabalho_rpg/domain/entities/combatente.dart';
import 'package:trabalho_rpg/domain/entities/grupo.dart';
import 'package:trabalho_rpg/domain/entities/inimigo.dart';
import 'package:trabalho_rpg/domain/entities/personagem.dart';
import 'package:trabalho_rpg/data/models/grupo_model.dart';

enum SelectionMode {
  none,
  selectingAttacker,
  selectingTarget,
}

class SimuladorBatalhaPage extends StatefulWidget {
  final GrupoModel<Personagem> grupoPersonagens;
  final GrupoModel<Inimigo> grupoInimigos;

  const SimuladorBatalhaPage({
    super.key,
    required this.grupoPersonagens,
    required this.grupoInimigos,
  });

  @override
  State<SimuladorBatalhaPage> createState() => _SimuladorBatalhaPageState();
}

class _SimuladorBatalhaPageState extends State<SimuladorBatalhaPage> {
  final List<String> _battleLog = [];

  Combatente? _selectedAttacker;
  Combatente? _selectedTarget;
  SelectionMode _currentSelectionMode = SelectionMode.none;

  @override
  void initState() {
    super.initState();
    _addToLog('Batalha iniciada entre ${widget.grupoPersonagens.nome} e ${widget.grupoInimigos.nome}!');
  }

  void _addToLog(String message) {
    setState(() {
      _battleLog.add(message);
    });
  }

  void _handleCombatantTap(Combatente tappedCombatant) {
    setState(() {
      if (_currentSelectionMode == SelectionMode.none) {
        _selectedAttacker = tappedCombatant;
        _currentSelectionMode = SelectionMode.selectingTarget; 
        _addToLog('${tappedCombatant.nome} selecionado como atacante. Agora selecione um alvo.');
        _selectedTarget = null; 
      }
      // para turar a seleção
      else if (_currentSelectionMode == SelectionMode.selectingTarget) {
        if (_selectedAttacker == tappedCombatant) {
          _selectedAttacker = null;
          _selectedTarget = null;
          _currentSelectionMode = SelectionMode.none;
          _addToLog('${tappedCombatant.nome} foi desselecionado como atacante. Seleção resetada.');
        } else {
          _selectedTarget = tappedCombatant;
          _addToLog('${tappedCombatant.nome} selecionado como alvo.');
        }
      }
    });
  }

  void _performAttack() {
    if (_selectedAttacker == null || _selectedTarget == null) {
      _addToLog('Por favor, selecione um atacante e um alvo.');
      return;
    }

    if (_selectedAttacker == _selectedTarget) {
      _addToLog('Um combatente não pode atacar a si mesmo!');
      return;
    }

    final bool attackerIsCharacter = widget.grupoPersonagens.membros.contains(_selectedAttacker);
    final bool targetIsCharacter = widget.grupoPersonagens.membros.contains(_selectedTarget);

    final attacker = _selectedAttacker!;
    final target = _selectedTarget!;


    final damage = 10; // tentar pegar o dano do banco de dados 
    target.receberDano(damage);

    _addToLog('${attacker.nome} atacou ${target.nome} e causou $damage de dano!');
    _addToLog('${target.nome} agora tem ${target.vidaAtual}/${target.vidaMax} HP.');

    if (target.vidaAtual <= 0) {
    _addToLog('${target.nome} foi derrotado!');

    // Remove o combatente derrotado do grupo correspondente
    setState(() {
      if (widget.grupoPersonagens.membros.contains(target)) {
        widget.grupoPersonagens.membros.remove(target);
      } else if (widget.grupoInimigos.membros.contains(target)) {
        widget.grupoInimigos.membros.remove(target);
      }
    });
  }
    _resetSelection();
  }

  void _resetSelection() {
    setState(() {
      _selectedAttacker = null;
      _selectedTarget = null;
      _currentSelectionMode = SelectionMode.none;
    });
  }


  Widget _buildCombatantTile(Combatente combatent) {
    bool isSelectedAttacker = _selectedAttacker == combatent;
    bool isSelectedTarget = _selectedTarget == combatent;

    Color? tileColor;
    if (isSelectedAttacker) {
      tileColor = Colors.yellow.withOpacity(0.3);
    } else if (isSelectedTarget) {
      tileColor = Colors.orange.withOpacity(0.3);
    }

    Color baseBorderColor = combatent is Personagem ? Colors.blueAccent : Colors.redAccent;
    Color borderColor = (isSelectedAttacker || isSelectedTarget)
        ? baseBorderColor.withOpacity(0.7)
        : Colors.transparent;

    double borderWidth = (isSelectedAttacker || isSelectedTarget) ? 3.0 : 1.0;


    return InkWell(
      onTap: () => _handleCombatantTap(combatent),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        decoration: BoxDecoration(
          color: tileColor,
          border: Border.all(
            color: borderColor,
            width: borderWidth,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: ListTile(
          title: Text(
            combatent.nome, 
            style: TextStyle(
              fontWeight: (isSelectedAttacker || isSelectedTarget) ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          subtitle: Text('HP: ${combatent.vidaAtual}/${combatent.vidaMax}'), 
          trailing: SizedBox(
            width: 80,
            child: LinearProgressIndicator(
              value: combatent.vidaAtual / combatent.vidaMax, 
              color: combatent.vidaAtual > (combatent.vidaMax / 2) ? Colors.green : (combatent.vidaAtual > 0 ? Colors.orange : Colors.red),
              backgroundColor: Colors.grey.shade700,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Simulador de Batalha'),
            Text(
              '${widget.grupoPersonagens.nome} vs ${widget.grupoInimigos.nome}',
              style: const TextStyle(fontSize: 14, color: Colors.white70),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    margin: const EdgeInsets.all(8.0),
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blueAccent),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Personagens',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const Divider(),
                        Expanded(
                          child: ListView.builder(
                            itemCount: widget.grupoPersonagens.membros.length,
                            itemBuilder: (context, index) {
                              final personagem = widget.grupoPersonagens.membros[index];
                              return _buildCombatantTile(personagem); // <-- CORREÇÃO AQUI
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Container(
                    margin: const EdgeInsets.all(8.0),
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Log da Batalha',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const Divider(),
                        Expanded(
                          child: ListView.builder(
                            reverse: true,
                            itemCount: _battleLog.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2.0),
                                child: Text(_battleLog[_battleLog.length - 1 - index]),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    margin: const EdgeInsets.all(8.0),
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.redAccent),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Inimigos',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const Divider(),
                        Expanded(
                          child: ListView.builder(
                            itemCount: widget.grupoInimigos.membros.length,
                            itemBuilder: (context, index) {
                              final inimigo = widget.grupoInimigos.membros[index];
                              return _buildCombatantTile(inimigo); // <-- CORREÇÃO AQUI
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _performAttack,
                  icon: const Icon(Icons.person),
                  label: const Text('Atacar', style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _performAttack,
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Habilidade', style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}