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
      Provider.of<InimigosViewModel>(context, listen: false).fetchInimigos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<InimigosViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (viewModel.error != null) {
            return Center(child: Text('Ocorreu um erro: ${viewModel.error}'));
          }
          if (viewModel.inimigos.isEmpty) {
            return const Center(child: Text('Nenhuma ficha de inimigo criada.'));
          }
          return ListView.builder(
            itemCount: viewModel.inimigos.length,
            itemBuilder: (context, index) {
              final inimigo = viewModel.inimigos[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.adb)), // Ícone de monstro
                  title: Text(inimigo.nome),
                  subtitle: Text('Nível: ${inimigo.nivel} | Tipo: ${inimigo.tipo}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Clonar',
                        icon: const Icon(Icons.copy, color: Colors.grey),
                        onPressed: () => viewModel.clonarInimigo(inimigo),
                      ),
                      IconButton(
                        tooltip: 'Editar',
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _navigateToCreateEditPage(inimigo: inimigo),
                      ),
                      IconButton(
                        tooltip: 'Deletar',
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => viewModel.deleteInimigo(inimigo.id),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCreateEditPage(),
        child: const Icon(Icons.add),
      ),
    );
  }
}