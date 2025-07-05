import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trabalho_rpg/domain/entities/personagem.dart';
import 'package:trabalho_rpg/presentation/pages/criar_editar_grupo_page.dart';
import 'package:trabalho_rpg/presentation/providers/grupos_view_model.dart';
import 'package:trabalho_rpg/presentation/providers/inimigos_view_model.dart';
import 'package:trabalho_rpg/presentation/providers/personagens_view_model.dart';

class GerenciarGruposPage extends StatefulWidget {
  const GerenciarGruposPage({super.key});

  @override
  State<GerenciarGruposPage> createState() => _GerenciarGruposPageState();
}

class _GerenciarGruposPageState extends State<GerenciarGruposPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Carrega todos os dados necessários
      Provider.of<GruposViewModel>(context, listen: false).fetchTodosOsGrupos();
      Provider.of<PersonagensViewModel>(context, listen: false).fetchPersonagens();
      Provider.of<InimigosViewModel>(context, listen: false).fetchInimigos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<GruposViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (viewModel.error != null) {
            return Center(child: Text('Erro: ${viewModel.error}'));
          }

          final todosGrupos = [
            ...viewModel.gruposDePersonagens,
            ...viewModel.gruposDeInimigos,
          ];

          if (todosGrupos.isEmpty) {
            return const Center(child: Text('Nenhum grupo criado.'));
          }

          return ListView.builder(
            itemCount: todosGrupos.length,
            itemBuilder: (context, index) {
              final grupo = todosGrupos[index];
              final isPersonagemGrupo = grupo.membros is List<Personagem>;
              return Card(
                child: ListTile(
                  leading: Icon(isPersonagemGrupo ? Icons.person_4 : Icons.groups),
                  title: Text(grupo.nome),
                  subtitle: Text('${grupo.membros.length} membros'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => viewModel.deleteGrupo(grupo.id),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Exibe um menu para escolher qual tipo de grupo criar
          showModalBottomSheet(
            context: context,
            builder: (ctx) => Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.person_add),
                  title: const Text('Novo Grupo de Personagens'),
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const CriarEditarGrupoPage(tipoGrupo: 'personagem')));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.group_add),
                  title: const Text('Novo Grupo de Inimigos'),
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const CriarEditarGrupoPage(tipoGrupo: 'inimigo')));
                  },
                ),
              ],
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}