import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trabalho_rpg/domain/entities/classe_personagem.dart';
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

  ProficienciaArma? _proficienciaArmaSelecionada;
  ProficienciaArmadura? _proficienciaArmaduraSelecionada;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.classe?.nome ?? '');

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
        profArma: _proficienciaArmaSelecionada!,
        profArmadura: _proficienciaArmaduraSelecionada!,
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.classe != null;
    final theme = Theme.of(context); // Access the theme

    return AlertDialog(
      backgroundColor: theme.cardTheme.color, // Pure White for dialog background
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
        side: BorderSide(color: theme.colorScheme.primaryContainer, width: 2), // Lighter Lavender border
      ),
      title: Text(
        isEditing ? 'Edit Class' : 'Add Class', // Translated titles
        style: TextStyle(
          color: theme.colorScheme.onSurface, // Black for text
          fontWeight: FontWeight.bold,
          fontSize: 22,
          letterSpacing: 1.2,
        ),
        textAlign: TextAlign.center,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      content: ConstrainedBox( // Constrain height to avoid intrinsic dimension issues
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.5, // Adjust max height if needed
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Class Name', // Translated label
                    hintText: 'e.g., Warrior, Mage, Rogue', // Added hint
                    prefixIcon: Icon(Icons.class_outlined, color: theme.colorScheme.primary), // Thematic icon
                    filled: true,
                    fillColor: theme.inputDecorationTheme.fillColor,
                    border: theme.inputDecorationTheme.border,
                    enabledBorder: theme.inputDecorationTheme.enabledBorder,
                    focusedBorder: theme.inputDecorationTheme.focusedBorder,
                    labelStyle: theme.inputDecorationTheme.labelStyle,
                    hintStyle: theme.inputDecorationTheme.hintStyle,
                  ),
                  style: TextStyle(color: theme.colorScheme.onSurface), // Black text
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a class name.'; // Translated validation
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<ProficienciaArma>(
                  value: _proficienciaArmaSelecionada,
                  decoration: InputDecoration(
                    labelText: 'Weapon Proficiency', // Translated label
                    prefixIcon: Icon(Icons.score, color: theme.colorScheme.primary), // Thematic icon
                    filled: true,
                    fillColor: theme.inputDecorationTheme.fillColor,
                    border: theme.inputDecorationTheme.border,
                    enabledBorder: theme.inputDecorationTheme.enabledBorder,
                    focusedBorder: theme.inputDecorationTheme.focusedBorder,
                    labelStyle: theme.inputDecorationTheme.labelStyle,
                  ),
                  items: ProficienciaArma.values.map((proficiencia) {
                    return DropdownMenuItem(
                      value: proficiencia,
                      child: Text(
                        proficiencia.name,
                        style: TextStyle(color: theme.colorScheme.onSurface), // Black text
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _proficienciaArmaSelecionada = value;
                    });
                  },
                  validator: (value) => value == null ? 'Please select an option.' : null, // Translated validation
                  dropdownColor: theme.cardTheme.color, // Dropdown background color
                  style: TextStyle(color: theme.colorScheme.onSurface), // Text color when selected
                ),

                const SizedBox(height: 16),

                DropdownButtonFormField<ProficienciaArmadura>(
                  value: _proficienciaArmaduraSelecionada,
                  decoration: InputDecoration(
                    labelText: 'Armor Proficiency', // Translated label
                    prefixIcon: Icon(Icons.security, color: theme.colorScheme.primary), // Thematic icon
                    filled: true,
                    fillColor: theme.inputDecorationTheme.fillColor,
                    border: theme.inputDecorationTheme.border,
                    enabledBorder: theme.inputDecorationTheme.enabledBorder,
                    focusedBorder: theme.inputDecorationTheme.focusedBorder,
                    labelStyle: theme.inputDecorationTheme.labelStyle,
                  ),
                  items: ProficienciaArmadura.values.map((proficiencia) {
                    return DropdownMenuItem(
                      value: proficiencia,
                      child: Text(
                        proficiencia.name,
                        style: TextStyle(color: theme.colorScheme.onSurface), // Black text
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _proficienciaArmaduraSelecionada = value;
                    });
                  },
                  validator: (value) => value == null ? 'Please select an option.' : null, // Translated validation
                  dropdownColor: theme.cardTheme.color, // Dropdown background color
                  style: TextStyle(color: theme.colorScheme.onSurface), // Text color when selected
                ),
              ],
            ),
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            foregroundColor: theme.colorScheme.onSurface.withOpacity(0.7),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.secondary,
            foregroundColor: theme.colorScheme.onSecondary,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 5,
          ),
          child: Text(isEditing ? 'Save' : 'Add'),
        ),
      ],
    );
  }
}