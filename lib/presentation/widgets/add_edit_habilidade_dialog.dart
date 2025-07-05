import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:trabalho_rpg/data/models/habilidades/habilidade_de_cura_model.dart';
import 'package:trabalho_rpg/data/models/habilidades/habilidade_de_dano_model.dart';
import 'package:trabalho_rpg/domain/entities/habilidade.dart';
import 'package:trabalho_rpg/presentation/providers/habilidades_view_model.dart';

class AddEditHabilidadeDialog extends StatefulWidget {
  final Habilidade? habilidade;

  const AddEditHabilidadeDialog({super.key, this.habilidade});

  @override
  State<AddEditHabilidadeDialog> createState() => _AddEditHabilidadeDialogState();
}

class _AddEditHabilidadeDialogState extends State<AddEditHabilidadeDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  late final TextEditingController _custoController;
  late final TextEditingController _nivelController;
  late final TextEditingController _valorBaseController;

  // Estado para controlar a categoria selecionada
  String _categoriaSelecionada = 'dano';

  @override
  void initState() {
    super.initState();
    final hab = widget.habilidade;
    _nameController = TextEditingController(text: hab?.nome ?? '');
    _descController = TextEditingController(text: hab?.descricao ?? '');
    _custoController = TextEditingController(text: hab?.custo.toString() ?? '0');
    _nivelController = TextEditingController(text: hab?.nivelExigido.toString() ?? '0');
    
    if (hab is HabilidadeDeDanoModel) {
      _categoriaSelecionada = 'dano';
      _valorBaseController = TextEditingController(text: hab.danoBase.toString());
    } else if (hab is HabilidadeDeCuraModel) {
      _categoriaSelecionada = 'cura';
      _valorBaseController = TextEditingController(text: hab.curaBase.toString());
    } else {
      _valorBaseController = TextEditingController(text: '0');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _custoController.dispose();
    _nivelController.dispose();
    _valorBaseController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Provider.of<HabilidadesViewModel>(context, listen: false).saveHabilidade(
        id: widget.habilidade?.id,
        nome: _nameController.text,
        descricao: _descController.text,
        custo: int.tryParse(_custoController.text) ?? 0,
        nivelExigido: int.tryParse(_nivelController.text) ?? 0,
        categoria: _categoriaSelecionada,
        valorBase: int.tryParse(_valorBaseController.text) ?? 0,
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.habilidade != null;
    return AlertDialog(
      title: Text(isEditing ? 'Editar Habilidade' : 'Adicionar Habilidade'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (v) => v!.trim().isEmpty ? 'Campo obrigatório' : null,
              ),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Descrição'),
                validator: (v) => v!.trim().isEmpty ? 'Campo obrigatório' : null,
              ),
              TextFormField(
                controller: _custoController,
                decoration: const InputDecoration(labelText: 'Custo'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              TextFormField(
                controller: _nivelController,
                decoration: const InputDecoration(labelText: 'Nível Exigido'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 16),
              // Seletor de Categoria
              DropdownButtonFormField<String>(
                value: _categoriaSelecionada,
                decoration: const InputDecoration(labelText: 'Categoria'),
                items: const [
                  DropdownMenuItem(value: 'dano', child: Text('Dano')),
                  DropdownMenuItem(value: 'cura', child: Text('Cura')),
                ],
                onChanged: isEditing ? null : (value) { // Não permite mudar categoria na edição
                  setState(() {
                    _categoriaSelecionada = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              // Campo dinâmico para o valor base
              TextFormField(
                controller: _valorBaseController,
                decoration: InputDecoration(
                  labelText: _categoriaSelecionada == 'dano' ? 'Dano Base' : 'Cura Base',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
        ElevatedButton(onPressed: _submit, child: Text(isEditing ? 'Salvar' : 'Adicionar')),
      ],
    );
  }
}