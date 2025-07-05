import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trabalho_rpg/domain/entities/classe_personagem.dart';
import 'package:trabalho_rpg/presentation/providers/classes_view_model.dart';
import 'package:trabalho_rpg/presentation/widgets/add_edit_classe_dialog.dart';

class GerenciarClassesPage extends StatefulWidget {
  const GerenciarClassesPage({super.key});

  @override
  State<GerenciarClassesPage> createState() => _GerenciarClassesPageState();
}

class _GerenciarClassesPageState extends State<GerenciarClassesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ClassesViewModel>(context, listen: false).fetchClasses();
    });
  }

  void _showAddEditDialog({ClassePersonagem? classe}) {
    showDialog(
      context: context,
      builder: (_) => ChangeNotifierProvider.value(
        value: Provider.of<ClassesViewModel>(context, listen: false),
        child: AddEditClasseDialog(classe: classe),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Classes'),
      ),
      body: Consumer<ClassesViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.error != null) {
            return Center(child: Text('Ocorreu um erro: ${viewModel.error}'));
          }

          if (viewModel.classes.isEmpty) {
            return const Center(child: Text('Nenhuma classe cadastrada.'));
          }

          return ListView.builder(
            itemCount: viewModel.classes.length,
            itemBuilder: (context, index) {
              final classe = viewModel.classes[index];
              return ListTile(
                title: Text(classe.nome),
                subtitle: Text('Prof. Arma: ${classe.proficienciaArma}, Prof. Armadura: ${classe.proficienciaArmadura}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showAddEditDialog(classe: classe),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        Provider.of<ClassesViewModel>(context, listen: false)
                            .deleteClasse(classe.id);
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