import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trabalho_rpg/domain/entities/classe_personagem.dart';
// ADICIONADO: Import dos enums para popular os menus de seleção.
import 'package:trabalho_rpg/domain/entities/enums/proficiencias.dart';
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
  
  // MUDANÇA: Substituímos os controllers de texto por variáveis de estado para os enums.
  ProficienciaArma? _proficienciaArmaSelecionada;
  ProficienciaArmadura? _proficienciaArmaduraSelecionada;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.classe?.nome ?? '');
    
    // MUDANÇA: Se estiver editando, pré-selecionamos os valores do enum.
    if (widget.classe != null) {
      _proficienciaArmaSelecionada = widget.classe!.proficienciaArma;
      _proficienciaArmaduraSelecionada = widget.classe!.proficienciaArmadura;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Provider.of<ClassesViewModel>(context, listen: false).saveClasse(
        id: widget.classe?.id,
        nome: _nameController.text,
        // MUDANÇA: Passamos os valores dos enums selecionados diretamente.
        // O "!" é seguro aqui pois o validator do formulário garante que não são nulos.
        profArma: _proficienciaArmaSelecionada!,
        profArmadura: _proficienciaArmaduraSelecionada!,
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

              // MUDANÇA: TextFormField substituído por DropdownButtonFormField.
              DropdownButtonFormField<ProficienciaArma>(
                value: _proficienciaArmaSelecionada,
                decoration: const InputDecoration(labelText: 'Proficiência com Arma'),
                // Gera os itens do menu a partir dos valores do enum.
                items: ProficienciaArma.values.map((proficiencia) {
                  return DropdownMenuItem(
                    value: proficiencia,
                    child: Text(proficiencia.name), // .name converte o enum para String (ex: "Marcial")
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _proficienciaArmaSelecionada = value;
                  });
                },
                validator: (value) => value == null ? 'Selecione uma opção' : null,
              ),

              const SizedBox(height: 16),

              // MUDANÇA: O mesmo para a proficiência com armadura.
              DropdownButtonFormField<ProficienciaArmadura>(
                value: _proficienciaArmaduraSelecionada,
                decoration: const InputDecoration(labelText: 'Proficiência com Armadura'),
                items: ProficienciaArmadura.values.map((proficiencia) {
                  return DropdownMenuItem(
                    value: proficiencia,
                    child: Text(proficiencia.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _proficienciaArmaduraSelecionada = value;
                  });
                },
                validator: (value) => value == null ? 'Selecione uma opção' : null,
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