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

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.raca != null;
    return AlertDialog(
      title: Text(isEditing ? 'Editar Raça' : 'Adicionar Raça'),
      // CORREÇÃO: Envolvemos o conteúdo em um Container com tamanho definido
      // para resolver o conflito de layout.
      content: Container(
        width: double.maxFinite, // Ocupa a largura máxima permitida pelo Dialog
        // Você pode ajustar a altura conforme necessário.
        height: 300, 
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nome da Raça'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor, insira um nome.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                const Text('Modificadores de Atributo', style: TextStyle(fontWeight: FontWeight.bold)),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  children: [
                    _buildAttributeField('FOR', _forController),
                    _buildAttributeField('DES', _desController),
                    _buildAttributeField('CON', _conController),
                    _buildAttributeField('INT', _intController),
                    _buildAttributeField('SAB', _sabController),
                    _buildAttributeField('CAR', _carController),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
        ElevatedButton(onPressed: _submit, child: Text(isEditing ? 'Salvar' : 'Adicionar')),
      ],
    );
  }

  Widget _buildAttributeField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: const TextInputType.numberWithOptions(signed: true),
      textAlign: TextAlign.center,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^-?\d*')),
      ],
    );
  }
}