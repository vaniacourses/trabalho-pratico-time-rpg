import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:trabalho_rpg/domain/entities/armadura.dart';
import 'package:trabalho_rpg/domain/entities/enums/proficiencias.dart';
import 'package:trabalho_rpg/presentation/providers/armaduras_view_model.dart';

class AddEditArmaduraDialog extends StatefulWidget {
  final Armadura? armadura;

  const AddEditArmaduraDialog({super.key, this.armadura});

  @override
  State<AddEditArmaduraDialog> createState() => _AddEditArmaduraDialogState();
}

class _AddEditArmaduraDialogState extends State<AddEditArmaduraDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _danoReduzidoController;
  ProficienciaArmadura? _proficienciaSelecionada;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.armadura?.nome ?? '');
    _danoReduzidoController =
        TextEditingController(text: widget.armadura?.danoReduzido.toString() ?? '0');
    _proficienciaSelecionada = widget.armadura?.proficienciaRequerida;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _danoReduzidoController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_proficienciaSelecionada == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an armor proficiency.')),
        );
        return;
      }

      Provider.of<ArmadurasViewModel>(context, listen: false).saveArmadura(
        id: widget.armadura?.id,
        nome: _nameController.text,
        danoReduzido: int.tryParse(_danoReduzidoController.text) ?? 0,
        proficienciaRequerida: _proficienciaSelecionada!,
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.armadura != null;
    final theme = Theme.of(context);

    return AlertDialog(
      backgroundColor: theme.cardTheme.color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
        side: BorderSide(color: theme.colorScheme.primaryContainer, width: 2),
      ),
      title: Text(
        isEditing ? 'Edit Armor' : 'Add Armor', // Translated titles
        style: TextStyle(
          color: theme.colorScheme.onSurface,
          fontWeight: FontWeight.bold,
          fontSize: 22,
          letterSpacing: 1.2,
        ),
        textAlign: TextAlign.center,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.5, // Adjusted max height
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
                    labelText: 'Armor Name', // Translated label
                    hintText: 'e.g., Plate Armor, Leather Vest',
                    prefixIcon: Icon(Icons.military_tech_outlined, color: theme.colorScheme.primary), // Thematic icon
                    filled: true,
                    fillColor: theme.inputDecorationTheme.fillColor,
                    border: theme.inputDecorationTheme.border,
                    enabledBorder: theme.inputDecorationTheme.enabledBorder,
                    focusedBorder: theme.inputDecorationTheme.focusedBorder,
                    labelStyle: theme.inputDecorationTheme.labelStyle,
                    hintStyle: theme.inputDecorationTheme.hintStyle,
                  ),
                  style: TextStyle(color: theme.colorScheme.onSurface),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a name.'; // Translated
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _danoReduzidoController,
                  decoration: InputDecoration(
                    labelText: 'Damage Reduction', // Translated label
                    hintText: 'e.g., 2, 5, 10',
                    prefixIcon: Icon(Icons.health_and_safety_outlined, color: theme.colorScheme.primary), // Thematic icon
                    filled: true,
                    fillColor: theme.inputDecorationTheme.fillColor,
                    border: theme.inputDecorationTheme.border,
                    enabledBorder: theme.inputDecorationTheme.enabledBorder,
                    focusedBorder: theme.inputDecorationTheme.focusedBorder,
                    labelStyle: theme.inputDecorationTheme.labelStyle,
                    hintStyle: theme.inputDecorationTheme.hintStyle,
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: TextStyle(color: theme.colorScheme.onSurface),
                  validator: (value) {
                    if (value == null || int.tryParse(value) == null) {
                      return 'Enter a number.'; // Translated
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<ProficienciaArmadura>(
                  value: _proficienciaSelecionada,
                  decoration: InputDecoration(
                    labelText: 'Required Proficiency', // Translated label
                    prefixIcon: Icon(Icons.verified_user_outlined, color: theme.colorScheme.primary), // Thematic icon
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
                        style: TextStyle(color: theme.colorScheme.onSurface),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _proficienciaSelecionada = value;
                    });
                  },
                  validator: (value) => value == null ? 'Please select a proficiency.' : null, // Translated
                  dropdownColor: theme.cardTheme.color,
                  style: TextStyle(color: theme.colorScheme.onSurface),
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