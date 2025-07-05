import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trabalho_rpg/domain/entities/combatente.dart';
import 'package:trabalho_rpg/domain/entities/grupo.dart';
import 'package:trabalho_rpg/domain/entities/inimigo.dart';
import 'package:trabalho_rpg/domain/entities/personagem.dart';
import 'package:trabalho_rpg/presentation/providers/grupos_view_model.dart';
import 'package:trabalho_rpg/presentation/providers/personagens_view_model.dart';
import 'package:trabalho_rpg/presentation/providers/inimigos_view_model.dart';

class CriarEditarGrupoPage extends StatefulWidget {
  final Grupo? grupo;
  final String tipoGrupo; // 'personagem' ou 'inimigo'

  const CriarEditarGrupoPage({
    super.key,
    required this.tipoGrupo,
    this.grupo,
  });

  @override
  State<CriarEditarGrupoPage> createState() => _CriarEditarGrupoPageState();
}

class _CriarEditarGrupoPageState extends State<CriarEditarGrupoPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final Set<String> _membrosSelecionadosIds = {};

  bool get isEditing => widget.grupo != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _nomeController.text = widget.grupo!.nome;
      _membrosSelecionadosIds.addAll(widget.grupo!.membros.map((m) => m.id));
    }
  }
  
  void _submit() {
    if (_formKey.currentState!.validate()) {
      final viewModel = Provider.of<GruposViewModel>(context, listen: false);

      if (widget.tipoGrupo == 'personagem') {
        final todosPersonagens = Provider.of<PersonagensViewModel>(context, listen: false).personagens;
        final membros = todosPersonagens.where((p) => _membrosSelecionadosIds.contains(p.id)).toList();
        viewModel.saveGrupoDePersonagens(
          id: widget.grupo?.id,
          nome: _nomeController.text,
          membros: membros,
        );
      } else {
        final todosInimigos = Provider.of<InimigosViewModel>(context, listen: false).inimigos;
        final membros = todosInimigos.where((i) => _membrosSelecionadosIds.contains(i.id)).toList();
        viewModel.saveGrupoDeInimigos(
          id: widget.grupo?.id,
          nome: _nomeController.text,
          membros: membros,
        );
      }

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Combatente> opcoesDeMembros = widget.tipoGrupo == 'personagem'
        ? context.watch<PersonagensViewModel>().personagens
        : context.watch<InimigosViewModel>().inimigos;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Grupo' : 'Criar Novo Grupo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome do Grupo'),
                validator: (v) => v!.trim().isEmpty ? 'Campo Obrigatório' : null,
              ),
              const SizedBox(height: 20),
              Text('Selecione os Membros', style: Theme.of(context).textTheme.titleLarge),
              Expanded(
                child: ListView.builder(
                  itemCount: opcoesDeMembros.length,
                  itemBuilder: (context, index) {
                    final membro = opcoesDeMembros[index];
                    return CheckboxListTile(
                      title: Text(membro.nome),
                      value: _membrosSelecionadosIds.contains(membro.id),
                      onChanged: (isSelected) {
                        setState(() {
                          if (isSelected!) {
                            _membrosSelecionadosIds.add(membro.id);
                          } else {
                            _membrosSelecionadosIds.remove(membro.id);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: _submit,
                child: Text(isEditing ? 'Salvar Alterações' : 'Criar Grupo'),
              )
            ],
          ),
        ),
      ),
    );
  }
}