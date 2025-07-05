import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:trabalho_rpg/domain/entities/classe_personagem.dart';
import 'package:trabalho_rpg/presentation/providers/classes_view_model.dart';

class AddEditClasseDialog extends StatefulWidget {
  final ClassePersonagem? classe;

  const AddEditClasseDialog({super.key, this.classe});

  @override
  State<AddEditClasseDialog> createState() => _AddEditClasseDialogState();
}

class _AddEditClasseDialogState extends State<AddEditClasseDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _profArmaController;
  late final TextEditingController _profArmaduraController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.classe?.nome ?? '');
    _profArmaController = TextEditingController(text: widget.classe?.proficienciaArma.toString() ?? '0');
    _profArmaduraController = TextEditingController(text: widget.classe?.proficienciaArmadura.toString() ?? '0');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _profArmaController.dispose();
    _profArmaduraController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Provider.of<ClassesViewModel>(context, listen: false).saveClasse(
        id: widget.classe?.id,
        nome: _nameController.text,
        profArma: int.tryParse(_profArmaController.text) ?? 0,
        profArmadura: int.tryParse(_profArmaduraController.text) ?? 0,
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.classe != null;
    return AlertDialog(
      title: Text(isEditing ? 'Editar Classe' : 'Adicionar Classe'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome da Classe'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, insira um nome.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _profArmaController,
                decoration: const InputDecoration(labelText: 'Proficiência com Arma'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _profArmaduraController,
                decoration: const InputDecoration(labelText: 'Proficiência com Armadura'),
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