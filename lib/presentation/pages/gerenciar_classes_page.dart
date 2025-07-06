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
      builder: (dialogContext) => Theme( // Wrap with Theme to apply app's theme
        data: Theme.of(context),
        child: ChangeNotifierProvider.value(
          value: Provider.of<ClassesViewModel>(context, listen: false),
          child: AddEditClasseDialog(classe: classe),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Classes'), // Translated title
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.appBarTheme.foregroundColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Consumer<ClassesViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.secondary),
              ),
            );
          }

          if (viewModel.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'An error occurred: ${viewModel.error}', // Translated error message
                  style: TextStyle(color: theme.colorScheme.error, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (viewModel.classes.isEmpty) {
            return Center(
              child: Text(
                'No classes registered. Define new paths for your heroes!', // Translated and enhanced empty message
                style: TextStyle(color: theme.colorScheme.onBackground, fontSize: 18, fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: viewModel.classes.length,
            itemBuilder: (context, index) {
              final classe = viewModel.classes[index];
              return Card( // Use Card for themed appearance
                margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
                child: ListTile(
                  title: Text(
                    classe.nome,
                    style: TextStyle(
                      color: theme.listTileTheme.textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Text(
                    'Weapon Prof: ${classe.proficienciaArma.name}, Armor Prof: ${classe.proficienciaArmadura.name}', // Translated and improved
                    style: TextStyle(
                      color: theme.listTileTheme.textColor?.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.brush, color: theme.listTileTheme.iconColor), // Thematic icon
                        tooltip: 'Edit Class',
                        onPressed: () => _showAddEditDialog(classe: classe),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_forever, color: Colors.redAccent), // Thematic icon and color
                        tooltip: 'Delete Class',
                        onPressed: () {
                          _confirmDelete(context, classe.nome, () {
                            Provider.of<ClassesViewModel>(context, listen: false)
                                .deleteClasse(classe.id);
                          });
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_class_fab', // Unique heroTag
        onPressed: () => _showAddEditDialog(),
        child: const Icon(Icons.add_circle_outline), // Thematic icon
      ),
    );
  }

  // Helper method to show delete confirmation dialog (reused from RacasPage)
  void _confirmDelete(BuildContext context, String className, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardTheme.color,
          shape: Theme.of(context).cardTheme.shape,
          title: Text('Confirm Deletion', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
          content: Text('Are you sure you want to delete "$className"? This action cannot be undone.',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8))),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                onConfirm();
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}