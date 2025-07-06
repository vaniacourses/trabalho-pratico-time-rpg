import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:trabalho_rpg/domain/entities/arma.dart';
import 'package:trabalho_rpg/domain/entities/atributos_base.dart';
import 'package:trabalho_rpg/domain/entities/habilidade.dart';
import 'package:trabalho_rpg/domain/entities/inimigo.dart';
import 'package:trabalho_rpg/domain/factories/inimigo_params.dart';
import 'package:trabalho_rpg/presentation/providers/inimigos_view_model.dart';

class CriarEditarInimigoPage extends StatefulWidget {
  final Inimigo? inimigo;
  const CriarEditarInimigoPage({super.key, this.inimigo});

  @override
  State<CriarEditarInimigoPage> createState() => _CriarEditarInimigoPageState();
}

class _CriarEditarInimigoPageState extends State<CriarEditarInimigoPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _nivelController = TextEditingController(text: '1');
  final _tipoController = TextEditingController();
  final _forController = TextEditingController(text: '10');
  final _desController = TextEditingController(text: '10');
  final _conController = TextEditingController(text: '10');
  final _intController = TextEditingController(text: '10');
  final _sabController = TextEditingController(text: '10');
  final _carController = TextEditingController(text: '10');

  Arma? _armaSelecionada;
  Arma? _armaduraSelecionada;
  final Set<String> _habilidadesSelecionadasIds = {};

  bool get isEditing => widget.inimigo != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<InimigosViewModel>(context, listen: false);
      viewModel.carregarOpcoes().then((_) {
        if (isEditing && mounted) {
          _preencherFormularioParaEdicao(viewModel);
        }
      });
    });
  }

  void _preencherFormularioParaEdicao(InimigosViewModel viewModel) {
    final i = widget.inimigo!;
    _nomeController.text = i.nome;
    _nivelController.text = i.nivel.toString();
    _tipoController.text = i.tipo;

    _forController.text = i.atributosBase.forca.toString();
    _desController.text = i.atributosBase.destreza.toString();
    _conController.text = i.atributosBase.constituicao.toString();
    _intController.text = i.atributosBase.inteligencia.toString();
    _sabController.text = i.atributosBase.sabedoria.toString();
    _carController.text = i.atributosBase.carisma.toString();

    try {
      if (i.arma != null) {
        _armaSelecionada = viewModel.armasDisponiveis.firstWhere(
          (a) => a.id == i.arma!.id,
        );
      }
      if (i.armadura != null) {
        _armaduraSelecionada = viewModel.armasDisponiveis.firstWhere(
          (a) => a.id == i.armadura!.id,
        );
      }
      _habilidadesSelecionadasIds.addAll(
        i.habilidadesPreparadas.map((h) => h.id),
      );
    } catch (e) {
      print("Erro ao pré-selecionar dados do inimigo: $e");
    }
    setState(() {});
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _nivelController.dispose();
    _tipoController.dispose();
    _forController.dispose();
    _desController.dispose();
    _conController.dispose();
    _intController.dispose();
    _sabController.dispose();
    _carController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final params = InimigoParams(
        nome: _nomeController.text,
        nivel: int.tryParse(_nivelController.text) ?? 1,
        tipo: _tipoController.text,
        atributos: AtributosBase(
          forca: int.tryParse(_forController.text) ?? 10,
          destreza: int.tryParse(_desController.text) ?? 10,
          constituicao: int.tryParse(_conController.text) ?? 10,
          inteligencia: int.tryParse(_intController.text) ?? 10,
          sabedoria: int.tryParse(_sabController.text) ?? 10,
          carisma: int.tryParse(_carController.text) ?? 10,
        ),
        armaId: _armaSelecionada?.id,
        armaduraId: _armaduraSelecionada?.id,
        habilidadesIds: _habilidadesSelecionadasIds.toList(),
      );

      final viewModel = Provider.of<InimigosViewModel>(context, listen: false);
      final success = await viewModel.criarOuAtualizarInimigo(params, id: widget.inimigo?.id);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Enemy ${isEditing ? 'updated' : 'created'} successfully!')),
        );
        Navigator.of(context).pop();
      }
    }
  }

  // Helper method to get thematic icons for attributes (reused from character page)
  IconData _getIconForAttribute(String attributeLabel) {
    switch (attributeLabel.toUpperCase()) {
      case 'FOR':
        return Icons.fitness_center;
      case 'DES':
        return Icons.run_circle_outlined;
      case 'CON':
        return Icons.health_and_safety_outlined;
      case 'INT':
        return Icons.menu_book;
      case 'SAB':
        return Icons.psychology_outlined;
      case 'CAR':
        return Icons.theater_comedy_outlined;
      default:
        return Icons.circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Enemy' : 'Create New Enemy'), // Translated title
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.appBarTheme.foregroundColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Consumer<InimigosViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) { // Assuming 'isLoading' is the correct getter in InimigosViewModel
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.secondary),
              ),
            );
          }
          if (viewModel.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error: ${viewModel.error}', // Translated error message
                  style: TextStyle(color: theme.colorScheme.error, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Enemy Name
                TextFormField(
                  controller: _nomeController,
                  decoration: InputDecoration(
                    labelText: 'Enemy Name', // Translated label
                    hintText: 'e.g., Goblin, Dragon',
                    prefixIcon: Icon(Icons.dangerous_outlined, color: theme.colorScheme.primary), // Thematic icon
                    filled: true,
                    fillColor: theme.inputDecorationTheme.fillColor,
                    border: theme.inputDecorationTheme.border,
                    enabledBorder: theme.inputDecorationTheme.enabledBorder,
                    focusedBorder: theme.inputDecorationTheme.focusedBorder,
                    labelStyle: theme.inputDecorationTheme.labelStyle,
                    hintStyle: theme.inputDecorationTheme.hintStyle,
                  ),
                  style: TextStyle(color: theme.colorScheme.onBackground),
                  validator: (v) => v!.isEmpty ? 'Required field' : null,
                ),
                const SizedBox(height: 16),

                // Enemy Type
                TextFormField(
                  controller: _tipoController,
                  decoration: InputDecoration(
                    labelText: 'Type (e.g., Beast, Humanoid)', // Translated label
                    hintText: 'e.g., Undead, Elemental',
                    prefixIcon: Icon(Icons.category_outlined, color: theme.colorScheme.primary), // Thematic icon
                    filled: true,
                    fillColor: theme.inputDecorationTheme.fillColor,
                    border: theme.inputDecorationTheme.border,
                    enabledBorder: theme.inputDecorationTheme.enabledBorder,
                    focusedBorder: theme.inputDecorationTheme.focusedBorder,
                    labelStyle: theme.inputDecorationTheme.labelStyle,
                    hintStyle: theme.inputDecorationTheme.hintStyle,
                  ),
                  style: TextStyle(color: theme.colorScheme.onBackground),
                  validator: (v) => v!.isEmpty ? 'Required field' : null,
                ),
                const SizedBox(height: 16),

                // Level Field
                TextFormField(
                  controller: _nivelController,
                  decoration: InputDecoration(
                    labelText: 'Level', // Translated label
                    hintText: 'e.g., 1, 5, 10',
                    prefixIcon: Icon(Icons.bar_chart, color: theme.colorScheme.primary), // Thematic icon
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
                  style: TextStyle(color: theme.colorScheme.onBackground),
                  validator: (v) => v!.trim().isEmpty || int.tryParse(v) == null ? 'Enter a number' : null,
                ),
                const SizedBox(height: 24),

                // Attributes Section
                Text(
                  'Attributes', // Translated
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onBackground,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(child: _buildAttributeField('FOR', _forController, theme)),
                    Expanded(child: _buildAttributeField('DES', _desController, theme)),
                    Expanded(child: _buildAttributeField('CON', _conController, theme)),
                    Expanded(child: _buildAttributeField('INT', _intController, theme)),
                    Expanded(child: _buildAttributeField('SAB', _sabController, theme)),
                    Expanded(child: _buildAttributeField('CAR', _carController, theme)),
                  ],
                ),
                const SizedBox(height: 24),

                // Equipment Section
                Text(
                  'Equipment', // Translated
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onBackground,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<Arma>(
                  value: _armaSelecionada,
                  decoration: InputDecoration(
                    labelText: 'Weapon', // Translated label
                    prefixIcon: Icon(Icons.gavel, color: theme.colorScheme.primary),
                    filled: true,
                    fillColor: theme.inputDecorationTheme.fillColor,
                    border: theme.inputDecorationTheme.border,
                    enabledBorder: theme.inputDecorationTheme.enabledBorder,
                    focusedBorder: theme.inputDecorationTheme.focusedBorder,
                    labelStyle: theme.inputDecorationTheme.labelStyle,
                  ),
                  items: viewModel.armasDisponiveis.map((arma) {
                    return DropdownMenuItem(
                      value: arma,
                      child: Text(
                        arma.nome,
                        style: TextStyle(color: theme.colorScheme.onSurface),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _armaSelecionada = value),
                  dropdownColor: theme.cardTheme.color,
                  style: TextStyle(color: theme.colorScheme.onSurface),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<Arma>(
                  value: _armaduraSelecionada,
                  decoration: InputDecoration(
                    labelText: 'Armor', // Translated label
                    prefixIcon: Icon(Icons.shield, color: theme.colorScheme.primary),
                    filled: true,
                    fillColor: theme.inputDecorationTheme.fillColor,
                    border: theme.inputDecorationTheme.border,
                    enabledBorder: theme.inputDecorationTheme.enabledBorder,
                    focusedBorder: theme.inputDecorationTheme.focusedBorder,
                    labelStyle: theme.inputDecorationTheme.labelStyle,
                  ),
                  items: viewModel.armasDisponiveis.map((arma) {
                    return DropdownMenuItem(
                      value: arma,
                      child: Text(
                        arma.nome,
                        style: TextStyle(color: theme.colorScheme.onSurface),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _armaduraSelecionada = value),
                  dropdownColor: theme.cardTheme.color,
                  style: TextStyle(color: theme.colorScheme.onSurface),
                ),
                const SizedBox(height: 24),

                // Abilities Section
                ExpansionTile(
                  title: Text(
                    'Abilities (${_habilidadesSelecionadasIds.length})',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onBackground,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  collapsedIconColor: theme.colorScheme.primary,
                  iconColor: theme.colorScheme.primary,
                  backgroundColor: theme.colorScheme.surface,
                  collapsedBackgroundColor: theme.colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: theme.colorScheme.primaryContainer, width: 1.5),
                  ),
                  children: viewModel.habilidadesDisponiveis.map((habilidade) {
                    return CheckboxListTile(
                      title: Text(
                        habilidade.nome,
                        style: TextStyle(color: theme.colorScheme.onSurface),
                      ),
                      subtitle: Text(
                        habilidade.descricao,
                        style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
                      ),
                      value: _habilidadesSelecionadasIds.contains(
                        habilidade.id,
                      ),
                      onChanged: (isSelected) {
                        setState(() {
                          if (isSelected!) {
                            _habilidadesSelecionadasIds.add(habilidade.id);
                          } else {
                            _habilidadesSelecionadasIds.remove(habilidade.id);
                          }
                        });
                      },
                      activeColor: theme.colorScheme.secondary,
                      checkColor: Colors.white,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Submit Button
                ElevatedButton(
                  onPressed: viewModel.isLoading ? null : _submitForm, // Assuming a 'isSaving' state in ViewModel
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: theme.colorScheme.secondary,
                    foregroundColor: theme.colorScheme.onSecondary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 5,
                  ),
                  child: viewModel.isLoading // Show loading indicator if saving
                      ? CircularProgressIndicator(color: theme.colorScheme.onSecondary)
                      : Text(
                          isEditing ? 'Save Changes' : 'Create Enemy', // Translated
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  // Reused _buildAttributeField from CriarPersonagemPage
  Widget _buildAttributeField(
      String label, TextEditingController controller, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0), // Very minimal horizontal padding
      child: Container(
        height: 80, // Explicitly set height for consistency with other input fields
        decoration: BoxDecoration(
          color: theme.inputDecorationTheme.fillColor, // Light grey background
          borderRadius: BorderRadius.circular(8), // Match input field border radius
          border: Border.all(color: theme.inputDecorationTheme.enabledBorder!.borderSide.color, width: 1), // Thicker border
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Make the column take minimal vertical space
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_getIconForAttribute(label), color: theme.colorScheme.primary, size: 24), // Increased icon size slightly
            const SizedBox(height: 2),
            Text(
              label,
              style: theme.inputDecorationTheme.labelStyle?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 11, // Adjusted font size for label
              ),
            ),
            SizedBox(
              width: 40, // Adjusted width for the text field
              height: 20, // Adjusted height for the text field
              child: TextFormField(
                controller: controller,
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0), // Minimal padding
                  border: InputBorder.none, // No border
                  hintText: '10',
                  hintStyle: TextStyle(fontSize: 12), // Adjusted hint font size
                ),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: TextStyle(
                  color: theme.colorScheme.onSurface, // Text color
                  fontSize: 14, // Adjusted font size for value
                  fontWeight: FontWeight.w500,
                ),
                validator: (value) {
                  if (value == null || int.tryParse(value) == null) {
                    return ''; // Minimal validation feedback
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}