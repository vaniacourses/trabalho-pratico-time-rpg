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
      builder: (_) => ChangeNotifierProvider.value(
        value: Provider.of<HabilidadesViewModel>(context, listen: false),
        child: AddEditHabilidadeDialog(habilidade: habilidade),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Habilidades'),
      ),
      body: Consumer<HabilidadesViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (viewModel.error != null) {
            return Center(child: Text('Ocorreu um erro: ${viewModel.error}'));
          }
          if (viewModel.habilidades.isEmpty) {
            return const Center(child: Text('Nenhuma habilidade cadastrada.'));
          }
          return ListView.builder(
            itemCount: viewModel.habilidades.length,
            itemBuilder: (context, index) {
              final habilidade = viewModel.habilidades[index];
              String subtitulo = 'Custo: ${habilidade.custo}, Nível: ${habilidade.nivelExigido}';
              if (habilidade is HabilidadeDeDanoModel) {
                subtitulo += ' | Dano: ${habilidade.danoBase}';
              } else if (habilidade is HabilidadeDeCuraModel) {
                subtitulo += ' | Cura: ${habilidade.curaBase}';
              }

              return ListTile(
                title: Text(habilidade.nome),
                subtitle: Text(subtitulo),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showAddEditDialog(habilidade: habilidade),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        Provider.of<HabilidadesViewModel>(context, listen: false)
                            .deleteHabilidade(habilidade.id);
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