import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trabalho_rpg/domain/entities/raca.dart';
import 'package:trabalho_rpg/presentation/providers/racas_view_model.dart';
import 'package:trabalho_rpg/presentation/widgets/add_edit_raca_dialog.dart'; // Assuming this file exists and will be updated

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

  String _formatarModificadores(Map<String, int> modificadores) {
    if (modificadores.isEmpty) {
      return 'No modifiers'; // Translated for consistency
    }
    return modificadores.entries
        .map((e) =>
            '${e.key.substring(0, 3).toUpperCase()}: ${e.value > 0 ? '+' : ''}${e.value}')
        .join(', ');
  }

  void _showAddEditDialog({Raca? raca}) {
    showDialog(
      context: context,
      // Wrap with Theme to ensure the dialog itself uses the app's theme
      builder: (dialogContext) => Theme(
        data: Theme.of(context), // Inherit the main app theme
        child: ChangeNotifierProvider.value(
          value: Provider.of<RacasViewModel>(context, listen: false),
          child: AddEditRacaDialog(raca: raca),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Access the theme for consistent styling
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Races'), // Translated title
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.appBarTheme.foregroundColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Consumer<RacasViewModel>(
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

          if (viewModel.racas.isEmpty) {
            return Center(
              child: Text(
                'No races registered. Create one to begin your adventure!', // Translated and enhanced empty message
                style: TextStyle(color: theme.colorScheme.onBackground, fontSize: 18, fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: viewModel.racas.length,
            itemBuilder: (context, index) {
              final raca = viewModel.racas[index];
              return Card( // Use Card widget for the themed appearance
                margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
                child: ListTile(
                  title: Text(
                    raca.nome,
                    style: TextStyle(
                      color: theme.listTileTheme.textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Text(
                    _formatarModificadores(raca.modificadoresDeAtributo),
                    style: TextStyle(
                      color: theme.listTileTheme.textColor?.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Edit Button
                      IconButton(
                        icon: Icon(Icons.brush, color: theme.listTileTheme.iconColor), // Thematic icon
                        tooltip: 'Edit Race', // Added tooltip
                        onPressed: () => _showAddEditDialog(raca: raca),
                      ),
                      // Delete Button
                      IconButton(
                        icon: const Icon(Icons.delete_forever, color: Colors.redAccent), // Thematic icon and color
                        tooltip: 'Delete Race', // Added tooltip
                        onPressed: () {
                          // Show confirmation dialog before deleting
                          _confirmDelete(context, raca.nome, () {
                            Provider.of<RacasViewModel>(context, listen: false)
                                .deleteRaca(raca.id);
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
        heroTag: 'add_race_fab', // Unique heroTag
        onPressed: () => _showAddEditDialog(),
        child: const Icon(Icons.add_circle_outline), // Thematic icon
      ),
    );
  }

  // Helper method to show delete confirmation dialog
  void _confirmDelete(BuildContext context, String raceName, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardTheme.color, // Use card color for dialog
          shape: Theme.of(context).cardTheme.shape,
          title: Text('Confirm Deletion', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
          content: Text('Are you sure you want to delete "$raceName"? This action cannot be undone.',
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
                backgroundColor: Colors.red, // Red for delete action
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