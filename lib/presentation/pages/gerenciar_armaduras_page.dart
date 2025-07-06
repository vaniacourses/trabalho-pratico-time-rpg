import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trabalho_rpg/domain/entities/armadura.dart';
import 'package:trabalho_rpg/presentation/providers/armaduras_view_model.dart';
import 'package:trabalho_rpg/presentation/widgets/add_edit_armadura_dialog.dart';

class GerenciarArmadurasPage extends StatefulWidget {
  const GerenciarArmadurasPage({super.key});

  @override
  State<GerenciarArmadurasPage> createState() => _GerenciarArmadurasPageState();
}

class _GerenciarArmadurasPageState extends State<GerenciarArmadurasPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ArmadurasViewModel>(context, listen: false).fetchArmaduras();
    });
  }

  void _showAddEditDialog({Armadura? armadura}) {
    showDialog(
      context: context,
      builder: (dialogContext) => Theme( // Wrap with Theme to apply app's theme
        data: Theme.of(context),
        child: ChangeNotifierProvider.value(
          value: Provider.of<ArmadurasViewModel>(context, listen: false),
          child: AddEditArmaduraDialog(armadura: armadura),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Armors'), // Translated title
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.appBarTheme.foregroundColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Consumer<ArmadurasViewModel>(
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
          if (viewModel.armaduras.isEmpty) {
            return Center(
              child: Text(
                'No armors registered. Equip your adventurers!', // Translated and enhanced empty message
                style: TextStyle(color: theme.colorScheme.onBackground, fontSize: 18, fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: viewModel.armaduras.length,
            itemBuilder: (context, index) {
              final armadura = viewModel.armaduras[index];
              return Card( // Use Card for themed appearance
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: ListTile(
                  title: Text(
                    armadura.nome,
                    style: TextStyle(
                      color: theme.listTileTheme.textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Text(
                    'Reduction: ${armadura.danoReduzido} | Req. Prof.: ${armadura.proficienciaRequerida.name}', // Translated subtitle
                    style: TextStyle(
                      color: theme.listTileTheme.textColor?.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Edit Armor', // Translated
                        icon: Icon(Icons.brush, color: theme.listTileTheme.iconColor), // Thematic icon
                        onPressed: () => _showAddEditDialog(armadura: armadura),
                      ),
                      IconButton(
                        tooltip: 'Delete Armor', // Translated
                        icon: const Icon(Icons.delete_forever, color: Colors.redAccent), // Thematic icon and color
                        onPressed: () {
                          _confirmDelete(context, armadura.nome, () {
                            viewModel.deleteArmadura(armadura.id);
                          });
                        },
                      ),
                    ],
                  ),
                  onTap: () => _showAddEditDialog(armadura: armadura),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_armadura_fab', // Unique heroTag
        onPressed: () => _showAddEditDialog(),
        child: const Icon(Icons.add_circle_outline), // Thematic icon
      ),
    );
  }

  // Helper method to show delete confirmation dialog (reused)
  void _confirmDelete(BuildContext context, String itemName, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardTheme.color,
          shape: Theme.of(context).cardTheme.shape,
          title: Text('Confirm Deletion', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
          content: Text('Are you sure you want to delete "$itemName"? This action cannot be undone.',
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
