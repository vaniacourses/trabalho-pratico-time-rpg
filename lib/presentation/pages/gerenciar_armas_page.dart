import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trabalho_rpg/domain/entities/arma.dart';
import 'package:trabalho_rpg/presentation/providers/armas_view_model.dart';
import 'package:trabalho_rpg/presentation/widgets/add_edit_arma_dialog.dart';

class GerenciarArmasPage extends StatefulWidget {
  const GerenciarArmasPage({super.key});

  @override
  State<GerenciarArmasPage> createState() => _GerenciarArmasPageState();
}

class _GerenciarArmasPageState extends State<GerenciarArmasPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ArmasViewModel>(context, listen: false).fetchArmas();
    });
  }

  void _showAddEditDialog({Arma? arma}) {
    showDialog(
      context: context,
      builder: (_) => ChangeNotifierProvider.value(
        value: Provider.of<ArmasViewModel>(context, listen: false),
        child: AddEditArmaDialog(arma: arma),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Armas'),
      ),
      body: Consumer<ArmasViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (viewModel.error != null) {
            return Center(child: Text('Ocorreu um erro: ${viewModel.error}'));
          }
          if (viewModel.armas.isEmpty) {
            return const Center(child: Text('Nenhuma arma cadastrada.'));
          }
          return ListView.builder(
            itemCount: viewModel.armas.length,
            itemBuilder: (context, index) {
              final arma = viewModel.armas[index];
              return ListTile(
                title: Text(arma.nome),
                subtitle: Text('Dano Base: ${arma.danoBase}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showAddEditDialog(arma: arma),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        Provider.of<ArmasViewModel>(context, listen: false)
                            .deleteArma(arma.id);
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