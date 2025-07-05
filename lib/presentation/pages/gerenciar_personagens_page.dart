import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trabalho_rpg/presentation/providers/personagens_view_model.dart';

class GerenciarPersonagensPage extends StatefulWidget {
  const GerenciarPersonagensPage({super.key});

  @override
  State<GerenciarPersonagensPage> createState() => _GerenciarPersonagensPageState();
}

class _GerenciarPersonagensPageState extends State<GerenciarPersonagensPage> {
  @override
  void initState() {
    super.initState();
    // CORREÇÃO: Atrasamos a chamada para depois do primeiro build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PersonagensViewModel>(context, listen: false).fetchPersonagens();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PersonagensViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (viewModel.error != null) {
          return Center(child: Text('Ocorreu um erro: ${viewModel.error}'));
        }
        if (viewModel.personagens.isEmpty) {
          return const Center(child: Text('Nenhuma ficha de personagem criada.'));
        }
        return ListView.builder(
          itemCount: viewModel.personagens.length,
          itemBuilder: (context, index) {
            final personagem = viewModel.personagens[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: CircleAvatar(child: Text(personagem.nivel.toString())),
                title: Text(personagem.nome),
                subtitle: Text('${personagem.raca.nome} ${personagem.classe.nome}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    Provider.of<PersonagensViewModel>(context, listen: false)
                        .deletePersonagem(personagem.id);
                  },
                ),
                onTap: () {
                  // Futuramente, navegaria para uma tela de detalhes/edição.
                },
              ),
            );
          },
        );
      },
    );
  }
}