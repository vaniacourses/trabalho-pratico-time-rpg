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
    final theme = Theme.of(context); // Access the theme

    return AlertDialog(
      backgroundColor: theme.cardTheme.color, // Pure White for dialog background
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
        side: BorderSide(color: theme.colorScheme.primaryContainer, width: 2), // Lighter Lavender border
      ),
      title: Text(
        isEditing ? 'Edit Weapon' : 'Add Weapon', // Translated titles
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
          maxHeight: MediaQuery.of(context).size.height * 0.4, // Adjusted max height for simpler dialog
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
                    labelText: 'Weapon Name', // Translated label
                    hintText: 'e.g., Sword, Bow, Staff', // Added hint
                    prefixIcon: Icon(Icons.gavel, color: theme.colorScheme.primary), // Thematic icon (reusing from general management page)
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
                      return 'Please enter a weapon name.'; // Translated validation
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _danoBaseController,
                  decoration: InputDecoration(
                    labelText: 'Base Damage', // Translated label
                    hintText: 'e.g., 6, 8, 10', // Added hint
                    prefixIcon: Icon(Icons.numbers, color: theme.colorScheme.primary), // Thematic icon
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
                  style: TextStyle(color: theme.colorScheme.onSurface), // Black text
                  validator: (value) {
                    if (value == null || value.trim().isEmpty || int.tryParse(value) == null) {
                      return 'Enter a number!'; // Short, thematic validation
                    }
                    return null;
                  },
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