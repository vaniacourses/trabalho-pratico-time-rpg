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

  String _categoriaSelecionada = 'dano'; // Default category

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
    final theme = Theme.of(context); // Access the theme

    return AlertDialog(
      backgroundColor: theme.cardTheme.color, // Pure White for dialog background
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
        side: BorderSide(color: theme.colorScheme.primaryContainer, width: 2), // Lighter Lavender border
      ),
      title: Text(
        isEditing ? 'Edit Ability' : 'Add Ability', // Translated titles
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
          maxHeight: MediaQuery.of(context).size.height * 0.7, // Adjusted max height for more fields
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
                    labelText: 'Name', // Translated label
                    hintText: 'e.g., Fireball, Healing Word',
                    prefixIcon: Icon(Icons.spellcheck, color: theme.colorScheme.primary), // Thematic icon
                    filled: true,
                    fillColor: theme.inputDecorationTheme.fillColor,
                    border: theme.inputDecorationTheme.border,
                    enabledBorder: theme.inputDecorationTheme.enabledBorder,
                    focusedBorder: theme.inputDecorationTheme.focusedBorder,
                    labelStyle: theme.inputDecorationTheme.labelStyle,
                    hintStyle: theme.inputDecorationTheme.hintStyle,
                  ),
                  style: TextStyle(color: theme.colorScheme.onSurface),
                  validator: (v) => v!.trim().isEmpty ? 'Required field.' : null, // Translated
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descController,
                  decoration: InputDecoration(
                    labelText: 'Description', // Translated label
                    hintText: 'What does this ability do?',
                    prefixIcon: Icon(Icons.description, color: theme.colorScheme.primary), // Thematic icon
                    filled: true,
                    fillColor: theme.inputDecorationTheme.fillColor,
                    border: theme.inputDecorationTheme.border,
                    enabledBorder: theme.inputDecorationTheme.enabledBorder,
                    focusedBorder: theme.inputDecorationTheme.focusedBorder,
                    labelStyle: theme.inputDecorationTheme.labelStyle,
                    hintStyle: theme.inputDecorationTheme.hintStyle,
                  ),
                  style: TextStyle(color: theme.colorScheme.onSurface),
                  maxLines: 3, // Allow multiple lines for description
                  validator: (v) => v!.trim().isEmpty ? 'Required field.' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _custoController,
                  decoration: InputDecoration(
                    labelText: 'Cost', // Translated label
                    hintText: 'e.g., 5 MP, 10 Stamina',
                    prefixIcon: Icon(Icons.toll, color: theme.colorScheme.primary), // Thematic icon
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
                  validator: (v) => v!.trim().isEmpty || int.tryParse(v) == null ? 'Enter a number.' : null, // Translated
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nivelController,
                  decoration: InputDecoration(
                    labelText: 'Required Level', // Translated label
                    hintText: 'e.g., 1, 5, 10',
                    prefixIcon: Icon(Icons.trending_up, color: theme.colorScheme.primary), // Thematic icon
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
                  validator: (v) => v!.trim().isEmpty || int.tryParse(v) == null ? 'Enter a number.' : null,
                ),
                const SizedBox(height: 16),
                // Category Selector
                DropdownButtonFormField<String>(
                  value: _categoriaSelecionada,
                  decoration: InputDecoration(
                    labelText: 'Category', // Translated label
                    prefixIcon: Icon(Icons.category, color: theme.colorScheme.primary), // Thematic icon
                    filled: true,
                    fillColor: theme.inputDecorationTheme.fillColor,
                    border: theme.inputDecorationTheme.border,
                    enabledBorder: theme.inputDecorationTheme.enabledBorder,
                    focusedBorder: theme.inputDecorationTheme.focusedBorder,
                    labelStyle: theme.inputDecorationTheme.labelStyle,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'dano', child: Text('Damage')), // Translated
                    DropdownMenuItem(value: 'cura', child: Text('Heal')), // Translated
                  ],
                  onChanged: isEditing ? null : (value) { // Cannot change category when editing
                    setState(() {
                      _categoriaSelecionada = value!;
                    });
                  },
                  dropdownColor: theme.cardTheme.color, // Dropdown background color
                  style: TextStyle(color: theme.colorScheme.onSurface), // Text color when selected
                ),
                const SizedBox(height: 16),
                // Dynamic base value field
                TextFormField(
                  controller: _valorBaseController,
                  decoration: InputDecoration(
                    labelText: _categoriaSelecionada == 'dano' ? 'Base Damage' : 'Base Heal', // Translated label
                    hintText: _categoriaSelecionada == 'dano' ? 'e.g., 1d6, 20' : 'e.g., 5, 1d4',
                    prefixIcon: Icon(
                      _categoriaSelecionada == 'dano' ? Icons.flare : Icons.healing, // Dynamic thematic icon
                      color: theme.colorScheme.primary,
                    ),
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
                  validator: (v) => v!.trim().isEmpty || int.tryParse(v) == null ? 'Enter a number.' : null,
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