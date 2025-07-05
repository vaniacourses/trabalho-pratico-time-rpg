import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trabalho_rpg/domain/entities/raca.dart';
import 'package:trabalho_rpg/presentation/providers/racas_view_model.dart';
import 'package:trabalho_rpg/presentation/widgets/add_edit_raca_dialog.dart';

class GerenciarRacasPage extends StatefulWidget {
  const GerenciarRacasPage({super.key});

  @override
  State<GerenciarRacasPage> createState() => _GerenciarRacasPageState();
}

class _GerenciarRacasPageState extends State<GerenciarRacasPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RacasViewModel>(context, listen: false).fetchRacas();
    });
  }

  // ATUALIZAÇÃO: Método para formatar o mapa de modificadores em uma string legível
  String _formatarModificadores(Map<String, int> modificadores) {
    if (modificadores.isEmpty) {
      return 'Sem modificadores';
    }
    // Transforma {'forca': 2, 'destreza': -1} em "FOR: +2, DES: -1"
    return modificadores.entries
        .map((e) =>
            '${e.key.substring(0, 3).toUpperCase()}: ${e.value > 0 ? '+' : ''}${e.value}')
        .join(', ');
  }

  void _showAddEditDialog({Raca? raca}) {
    showDialog(
      context: context,
      builder: (_) => ChangeNotifierProvider.value(
        value: Provider.of<RacasViewModel>(context, listen: false),
        child: AddEditRacaDialog(raca: raca),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Raças'),
      ),
      body: Consumer<RacasViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.error != null) {
            return Center(child: Text('Ocorreu um erro: ${viewModel.error}'));
          }

          if (viewModel.racas.isEmpty) {
            return const Center(child: Text('Nenhuma raça cadastrada.'));
          }

          return ListView.builder(
            itemCount: viewModel.racas.length,
            itemBuilder: (context, index) {
              final raca = viewModel.racas[index];
              return ListTile(
                title: Text(raca.nome),
                // ATUALIZAÇÃO: O subtítulo agora mostra os modificadores
                subtitle: Text(_formatarModificadores(raca.modificadoresDeAtributo)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showAddEditDialog(raca: raca),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        Provider.of<RacasViewModel>(context, listen: false)
                            .deleteRaca(raca.id);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}