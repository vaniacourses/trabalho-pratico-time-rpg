import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trabalho_rpg/data/models/habilidades/habilidade_de_cura_model.dart';
import 'package:trabalho_rpg/data/models/habilidades/habilidade_de_dano_model.dart';
import 'package:trabalho_rpg/domain/entities/habilidade.dart';
import 'package:trabalho_rpg/presentation/providers/habilidades_view_model.dart';
import 'package:trabalho_rpg/presentation/widgets/add_edit_habilidade_dialog.dart';

class GerenciarHabilidadesPage extends StatefulWidget {
  const GerenciarHabilidadesPage({super.key});

  @override
  State<GerenciarHabilidadesPage> createState() => _GerenciarHabilidadesPageState();
}

class _GerenciarHabilidadesPageState extends State<GerenciarHabilidadesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HabilidadesViewModel>(context, listen: false).fetchHabilidades();
    });
  }

  void _showAddEditDialog({Habilidade? habilidade}) {
    showDialog(
      context: context,
      builder: (dialogContext) => Theme( // Wrap with Theme to apply app's theme
        data: Theme.of(context),
        child: ChangeNotifierProvider.value(
          value: Provider.of<HabilidadesViewModel>(context, listen: false),
          child: AddEditHabilidadeDialog(habilidade: habilidade),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Abilities'), // Translated title
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.appBarTheme.foregroundColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Consumer<HabilidadesViewModel>(
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
          if (viewModel.habilidades.isEmpty) {
            return Center(
              child: Text(
                'No abilities registered. Time to craft some spells!', // Translated and enhanced empty message
                style: TextStyle(color: theme.colorScheme.onBackground, fontSize: 18, fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: viewModel.habilidades.length,
            itemBuilder: (context, index) {
              final habilidade = viewModel.habilidades[index];
              String subtitleText = 'Cost: ${habilidade.custo}, Level: ${habilidade.nivelExigido}'; // Translated
              if (habilidade is HabilidadeDeDanoModel) {
                subtitleText += ' | Damage: ${habilidade.danoBase}'; // Translated
              } else if (habilidade is HabilidadeDeCuraModel) {
                subtitleText += ' | Heal: ${habilidade.curaBase}'; // Translated
              }

              return Card( // Use Card for themed appearance
                margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
                child: ListTile(
                  title: Text(
                    habilidade.nome,
                    style: TextStyle(
                      color: theme.listTileTheme.textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Text(
                    subtitleText,
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
                        tooltip: 'Edit Ability',
                        onPressed: () => _showAddEditDialog(habilidade: habilidade),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_forever, color: Colors.redAccent), // Thematic icon and color
                        tooltip: 'Delete Ability',
                        onPressed: () {
                          _confirmDelete(context, habilidade.nome, () {
                            Provider.of<HabilidadesViewModel>(context, listen: false)
                                .deleteHabilidade(habilidade.id);
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
        heroTag: 'add_habilidade_fab', // Unique heroTag
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