import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trabalho_rpg/presentation/providers/grupos_view_model.dart';
import 'package:trabalho_rpg/presentation/pages/simulador_batalha_page.dart';
import 'package:trabalho_rpg/data/models/grupo_model.dart';
import 'package:trabalho_rpg/domain/entities/personagem.dart';
import 'package:trabalho_rpg/domain/entities/inimigo.dart';


class BatalhaTabPage extends StatefulWidget {
  const BatalhaTabPage({super.key});

  @override
  State<BatalhaTabPage> createState() => _BatalhaTabPageState();
}

class _BatalhaTabPageState extends State<BatalhaTabPage> {
  GrupoModel<Personagem>? _selectedCharacterGroup;
  GrupoModel<Inimigo>? _selectedEnemyGroup;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GruposViewModel>(context, listen: false).fetchTodosOsGrupos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GruposViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (viewModel.error != null) {
          return Center(child: Text('Erro ao carregar os grupos: ${viewModel.error}'));
        }

        final List<GrupoModel<Personagem>> characterGroups = viewModel.gruposDePersonagens;
        final List<GrupoModel<Inimigo>> enemyGroups = viewModel.gruposDeInimigos;

        if (_selectedCharacterGroup != null && !characterGroups.any((g) => g.id == _selectedCharacterGroup!.id)) {
          _selectedCharacterGroup = null;
        }
        if (_selectedEnemyGroup != null && !enemyGroups.any((g) => g.id == _selectedEnemyGroup!.id)) {
          _selectedEnemyGroup = null;
        }

        return Scaffold(
          body: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: DropdownButtonFormField<String>( 
                    decoration: const InputDecoration(
                      labelText: 'Grupo de Personagens',
                      prefixIcon: Icon(Icons.group),
                      border: InputBorder.none,
                    ),

                    value: _selectedCharacterGroup?.id, 
                    hint: const Text('Selecione um grupo'),
                    items: characterGroups.map((GrupoModel<Personagem> group) {
                      return DropdownMenuItem<String>(
                        value: group.id, 
                        child: Text(group.nome), 
                      );
                    }).toList(),
                    onChanged: (String? selectedGroupId) {
                      setState(() {
                        _selectedCharacterGroup = characterGroups.firstWhere(
                          (g) => g.id == selectedGroupId,
                        );
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: DropdownButtonFormField<String>( 
                    decoration: const InputDecoration(
                      labelText: 'Grupo de Inimigos',
                      prefixIcon: Icon(Icons.group_work),
                      border: InputBorder.none,
                    ),
                    value: _selectedEnemyGroup?.id,
                    hint: const Text('Selecione os inimigos'),
                    items: enemyGroups.map((GrupoModel<Inimigo> group) {
                      return DropdownMenuItem<String>(
                        value: group.id,
                        child: Text(group.nome), 
                      );
                    }).toList(),
                    onChanged: (String? selectedGroupId) {
                      setState(() {
                        _selectedEnemyGroup = enemyGroups.firstWhere(
                          (g) => g.id == selectedGroupId,
                        );
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            heroTag: 'batalha_fab',
            child: const Icon(Icons.add_box),
            onPressed: () {
              // Adiciona uma validação antes de navegar
              if (_selectedCharacterGroup == null || _selectedEnemyGroup == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Por favor, selecione ambos os grupos para iniciar a batalha.'),
                  ),
                );
                return; // Impede a navegação
              }

              // Navega para a SimuladorBatalhaPage passando os grupos selecionados
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SimuladorBatalhaPage(
                    // Agora passamos os objetos GrupoModel diretamente
                    grupoPersonagens: _selectedCharacterGroup!,
                    grupoInimigos: _selectedEnemyGroup!,
                  ),
                ),
              );
              print('Botão flutuante da BatalhaTabPage pressionado! Grupos: ${_selectedCharacterGroup?.nome}, ${_selectedEnemyGroup?.nome}');
            },
          ),
        );
      },
    );
  }
}