import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:trabalho_rpg/domain/entities/arma.dart';
import 'package:trabalho_rpg/presentation/providers/armas_view_model.dart';

class AddEditArmaDialog extends StatefulWidget {
  final Arma? arma;

  const AddEditArmaDialog({super.key, this.arma});

  @override
  State<AddEditArmaDialog> createState() => _AddEditArmaDialogState();
}

class _AddEditArmaDialogState extends State<AddEditArmaDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _danoBaseController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.arma?.nome ?? '');
    _danoBaseController = TextEditingController(text: widget.arma?.danoBase.toString() ?? '0');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _danoBaseController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Provider.of<ArmasViewModel>(context, listen: false).saveArma(
        id: widget.arma?.id,
        nome: _nameController.text,
        danoBase: int.tryParse(_danoBaseController.text) ?? 0,
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.arma != null;
    return AlertDialog(
      title: Text(isEditing ? 'Editar Arma' : 'Adicionar Arma'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome da Arma'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, insira um nome.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _danoBaseController,
                decoration: const InputDecoration(labelText: 'Dano Base'),
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