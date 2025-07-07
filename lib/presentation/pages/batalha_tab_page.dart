import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trabalho_rpg/presentation/providers/grupos_view_model.dart';

class BatalhaTabPage extends StatefulWidget {
  const BatalhaTabPage({super.key});

  @override
  State<BatalhaTabPage> createState() => _BatalhaTabPageState();
}

class _BatalhaTabPageState extends State<BatalhaTabPage> {
  // Variáveis para armazenar os valores selecionados nos dropdowns
  String? _selectedCharacterGroup;
  String? _selectedEnemyGroup;

  @override
  void initState() {
    super.initState();
    // Inicia a busca pelos grupos assim que a tela é construída
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GruposViewModel>(context, listen: false).fetchTodosOsGrupos();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Usa um Consumer para ouvir as mudanças no GruposViewModel
    return Consumer<GruposViewModel>(
      builder: (context, viewModel, child) {
        // Exibe um indicador de progresso enquanto os dados estão sendo carregados
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Exibe uma mensagem de erro se a busca falhar
        if (viewModel.error != null) {
          return Center(child: Text('Erro ao carregar os grupos: ${viewModel.error}'));
        }

        // Transforma a lista de objetos Grupo em uma lista de Strings (nomes)
        final characterGroups = viewModel.gruposDePersonagens.map((g) => g.nome).toList();
        final enemyGroups = viewModel.gruposDeInimigos.map((g) => g.nome).toList();

        // Garante que o valor selecionado ainda exista na lista após o carregamento
        // Isso evita erros se um grupo selecionado for deletado
        if (_selectedCharacterGroup != null && !characterGroups.contains(_selectedCharacterGroup)) {
          _selectedCharacterGroup = null;
        }
        if (_selectedEnemyGroup != null && !enemyGroups.contains(_selectedEnemyGroup)) {
          _selectedEnemyGroup = null;
        }

        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Dropdown para selecionar o grupo de personagens
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Grupo de Personagens',
                    prefixIcon: Icon(Icons.group),
                    border: InputBorder.none,
                  ),
                  value: _selectedCharacterGroup,
                  hint: const Text('Selecione um grupo'),
                  // Popula o dropdown com a lista de nomes dos grupos de personagens
                  items: characterGroups.map((String group) {
                    return DropdownMenuItem<String>(
                      value: group,
                      child: Text(group),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCharacterGroup = newValue;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Dropdown para selecionar o grupo de inimigos
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Grupo de Inimigos',
                    prefixIcon: Icon(Icons.group_work),
                    border: InputBorder.none,
                  ),
                  value: _selectedEnemyGroup,
                  hint: const Text('Selecione os inimigos'),
                  // Popula o dropdown com a lista de nomes dos grupos de inimigos
                  items: enemyGroups.map((String group) {
                    return DropdownMenuItem<String>(
                      value: group,
                      child: Text(group),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedEnemyGroup = newValue;
                    });
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}