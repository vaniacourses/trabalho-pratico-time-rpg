import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:trabalho_rpg/domain/entities/raca.dart';
import 'package:trabalho_rpg/presentation/providers/racas_view_model.dart';

class AddEditRacaDialog extends StatefulWidget {
  final Raca? raca;

  const AddEditRacaDialog({super.key, this.raca});

  @override
  State<AddEditRacaDialog> createState() => _AddEditRacaDialogState();
}

class _AddEditRacaDialogState extends State<AddEditRacaDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _forController;
  late final TextEditingController _desController;
  late final TextEditingController _conController;
  late final TextEditingController _intController;
  late final TextEditingController _sabController;
  late final TextEditingController _carController;

  @override
  void initState() {
    super.initState();
    final mods = widget.raca?.modificadoresDeAtributo ?? {};
    _nameController = TextEditingController(text: widget.raca?.nome ?? '');
    _forController = TextEditingController(text: mods['forca']?.toString() ?? '0');
    _desController = TextEditingController(text: mods['destreza']?.toString() ?? '0');
    _conController = TextEditingController(text: mods['constituicao']?.toString() ?? '0');
    _intController = TextEditingController(text: mods['inteligencia']?.toString() ?? '0');
    _sabController = TextEditingController(text: mods['sabedoria']?.toString() ?? '0');
    _carController = TextEditingController(text: mods['carisma']?.toString() ?? '0');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _forController.dispose();
    _desController.dispose();
    _conController.dispose();
    _intController.dispose();
    _sabController.dispose();
    _carController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final Map<String, int> modificadores = {};

      void addMod(String key, TextEditingController controller) {
        final value = int.tryParse(controller.text) ?? 0;
        if (value != 0) {
          modificadores[key] = value;
        }
      }

      addMod('forca', _forController);
      addMod('destreza', _desController);
      addMod('constituicao', _conController);
      addMod('inteligencia', _intController);
      addMod('sabedoria', _sabController);
      addMod('carisma', _carController);

      Provider.of<RacasViewModel>(context, listen: false).saveRaca(
        id: widget.raca?.id,
        nome: _nameController.text,
        modificadores: modificadores,
      );
      Navigator.of(context).pop();
    }
  }

  // Helper method to get thematic icons for attributes
  IconData _getIconForAttribute(String attributeName) {
    switch (attributeName.toLowerCase()) {
      case 'for':
        return Icons.fitness_center; // Strength
      case 'des':
        return Icons.run_circle_outlined; // Dexterity
      case 'con':
        return Icons.health_and_safety_outlined; // Constitution
      case 'int':
        return Icons.menu_book; // Intelligence
      case 'sab':
        return Icons.psychology_outlined; // Wisdom
      case 'car':
        return Icons.theater_comedy_outlined; // Charisma
      default:
        return Icons.circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.raca != null;
    final theme = Theme.of(context); // Access the theme

    return AlertDialog(
      backgroundColor: theme.cardTheme.color, // Pure White for dialog background
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
        side: BorderSide(color: theme.colorScheme.primaryContainer, width: 2), // Lighter Lavender border
      ),
      title: Text(
        isEditing ? 'Edit Race' : 'Create New Race',
        style: TextStyle(
          color: theme.colorScheme.onSurface, // Black for text
          fontWeight: FontWeight.bold,
          fontSize: 22,
          letterSpacing: 1.2,
        ),
        textAlign: TextAlign.center,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
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
                    labelText: 'Race Name',
                    hintText: 'e.g., Elf, Dwarf, Orc',
                    prefixIcon: Icon(Icons.landscape, color: theme.colorScheme.primary), // Muted Lavender icon
                    filled: true, // Ensure filled is true as per input decoration theme
                    fillColor: theme.inputDecorationTheme.fillColor, // Use theme's fill color
                    border: theme.inputDecorationTheme.border, // Use theme's border
                    enabledBorder: theme.inputDecorationTheme.enabledBorder,
                    focusedBorder: theme.inputDecorationTheme.focusedBorder,
                    labelStyle: theme.inputDecorationTheme.labelStyle, // Use theme's label style
                    hintStyle: theme.inputDecorationTheme.hintStyle, // Use theme's hint style
                  ),
                  style: TextStyle(color: theme.colorScheme.onSurface), // Black text
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a race name.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Text(
                  'Attribute Modifiers',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface, // Black for text
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 16.0,
                  runSpacing: 16.0,
                  alignment: WrapAlignment.center, // Center the items in the wrap
                  children: [
                    SizedBox(
                      width: 100, // Fixed width for consistent layout
                      child: _buildAttributeField('FOR', _forController, theme),
                    ),
                    SizedBox(
                      width: 100,
                      child: _buildAttributeField('DES', _desController, theme),
                    ),
                    SizedBox(
                      width: 100,
                      child: _buildAttributeField('CON', _conController, theme),
                    ),
                    SizedBox(
                      width: 100,
                      child: _buildAttributeField('INT', _intController, theme),
                    ),
                    SizedBox(
                      width: 100,
                      child: _buildAttributeField('SAB', _sabController, theme),
                    ),
                    SizedBox(
                      width: 100,
                      child: _buildAttributeField('CAR', _carController, theme),
                    ),
                  ],
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
            foregroundColor: theme.colorScheme.onSurface.withOpacity(0.7), // Muted text color for cancel
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.secondary, // Soft Green for Add/Save button
            foregroundColor: theme.colorScheme.onSecondary, // Text color on green
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 5,
          ),
          child: Text(isEditing ? 'Save' : 'Add'),
        ),
      ],
    );
  }

  Widget _buildAttributeField(String label, TextEditingController controller, ThemeData theme) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: '0',
        prefixIcon: Icon(_getIconForAttribute(label), color: theme.colorScheme.primary), // Muted Lavender icon
        // These will be inherited from the InputDecorationTheme
        filled: true,
        fillColor: theme.inputDecorationTheme.fillColor,
        border: theme.inputDecorationTheme.border,
        enabledBorder: theme.inputDecorationTheme.enabledBorder,
        focusedBorder: theme.inputDecorationTheme.focusedBorder,
        labelStyle: theme.inputDecorationTheme.labelStyle,
        hintStyle: theme.inputDecorationTheme.hintStyle,
      ),
      keyboardType: const TextInputType.numberWithOptions(signed: true),
      textAlign: TextAlign.center,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^-?\d*')),
      ],
      style: TextStyle(color: theme.colorScheme.onSurface), // Black text
      validator: (value) {
        if (value == null || int.tryParse(value) == null) {
          return ''; // Empty string for minimal error feedback in a small field
        }
        return null;
      },
    );
  }
}