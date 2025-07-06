import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trabalho_rpg/domain/entities/inimigo.dart';
import 'package:trabalho_rpg/presentation/pages/criar_editar_inimigo_page.dart';
import 'package:trabalho_rpg/presentation/providers/inimigos_view_model.dart';

class GerenciarInimigosPage extends StatefulWidget {
  const GerenciarInimigosPage({super.key});

  @override
  State<GerenciarInimigosPage> createState() => _GerenciarInimigosPageState();
}

class _GerenciarInimigosPageState extends State<GerenciarInimigosPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<InimigosViewModel>(context, listen: false).fetchInimigos();
    });
  }

  void _navigateToCreateEditPage({Inimigo? inimigo}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CriarEditarInimigoPage(inimigo: inimigo),
      ),
    ).then((_) {
      // Refresh the list after returning from create/edit page
      Provider.of<InimigosViewModel>(context, listen: false).fetchInimigos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      // AppBar is typically managed by the parent 'MainPage' for this tab content
      // If you want an AppBar specifically for this page, uncomment below
      /*
      appBar: AppBar(
        title: const Text('Manage Enemies'), // Translated title
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.appBarTheme.foregroundColor),
          onPressed: () => Navigator.of(context).pop(), // Will pop the tab
        ),
      ),
      */
      body: Consumer<InimigosViewModel>(
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
          if (viewModel.inimigos.isEmpty) {
            return Center(
              child: Text(
                'No enemies created. Unleash your imagination!', // Translated and enhanced empty message
                style: TextStyle(color: theme.colorScheme.onBackground, fontSize: 18, fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: viewModel.inimigos.length,
            itemBuilder: (context, index) {
              final inimigo = viewModel.inimigos[index];
              return Card( // Use Card for themed appearance
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer, // Pastel background for avatar
                    child: Icon(Icons.psychology_alt, color: theme.colorScheme.onPrimary), // Thematic monster icon (e.g., brain/mind for foes)
                  ),
                  title: Text(
                    inimigo.nome,
                    style: TextStyle(
                      color: theme.listTileTheme.textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Text(
                    'Level: ${inimigo.nivel} | Type: ${inimigo.tipo}', // Translated subtitle
                    style: TextStyle(
                      color: theme.listTileTheme.textColor?.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Clone', // Translated
                        icon: Icon(Icons.copy_all, color: theme.listTileTheme.iconColor), // Thematic copy icon
                        onPressed: () => viewModel.clonarInimigo(inimigo),
                      ),
                      IconButton(
                        tooltip: 'Edit', // Translated
                        icon: Icon(Icons.edit_note, color: theme.listTileTheme.iconColor), // Thematic edit icon
                        onPressed: () => _navigateToCreateEditPage(inimigo: inimigo),
                      ),
                      IconButton(
                        tooltip: 'Delete', // Translated
                        icon: const Icon(Icons.delete_forever, color: Colors.redAccent), // Thematic delete icon and color
                        onPressed: () {
                          _confirmDelete(context, inimigo.nome, () {
                            viewModel.deleteInimigo(inimigo.id);
                          });
                        },
                      ),
                    ],
                  ),
                  onTap: () => _navigateToCreateEditPage(inimigo: inimigo),
                ),
              );
            },
          );
        },
      ),
      // The FAB is managed by FichasTabPage, not directly here.
      // So, if you have a FAB in FichasTabPage, this one should be removed or handled differently.
      // Assuming the FAB on FichasTabPage correctly navigates to this page for creation.
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