import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:trabalho_rpg/domain/entities/arma.dart';
import 'package:trabalho_rpg/domain/entities/atributos_base.dart';
import 'package:trabalho_rpg/domain/entities/classe_personagem.dart';
import 'package:trabalho_rpg/domain/entities/habilidade.dart';
import 'package:trabalho_rpg/domain/entities/personagem.dart';
import 'package:trabalho_rpg/domain/entities/raca.dart';
import 'package:trabalho_rpg/domain/factories/personagem_params.dart';
import 'package:trabalho_rpg/presentation/providers/criar_personagem_view_model.dart';

class CriarPersonagemPage extends StatefulWidget {
  final Personagem? personagem;
  const CriarPersonagemPage({super.key, this.personagem});

  @override
  State<CriarPersonagemPage> createState() => _CriarPersonagemPageState();
}

class _CriarPersonagemPageState extends State<CriarPersonagemPage> {
  final _formKey = GlobalKey<FormState>();

  final _nomeController = TextEditingController();
  final _nivelController = TextEditingController(text: '1');
  final _forController = TextEditingController(text: '10');
  final _desController = TextEditingController(text: '10');
  final _conController = TextEditingController(text: '10');
  final _intController = TextEditingController(text: '10');
  final _sabController = TextEditingController(text: '10');
  final _carController = TextEditingController(text: '10');

  Raca? _racaSelecionada;
  ClassePersonagem? _classeSelecionada;
  Arma? _armaSelecionada;
  Arma? _armaduraSelecionada;
  final Set<String> _habilidadesSelecionadasIds = {};

  bool get isEditing => widget.personagem != null;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<CriarPersonagemViewModel>(
        context,
        listen: false,
      );
      viewModel.carregarDadosIniciais().then((_) {
        if (isEditing && mounted) {
          _preencherFormularioParaEdicao(viewModel);
        }
      });
    });
  }

  void _preencherFormularioParaEdicao(CriarPersonagemViewModel viewModel) {
    final p = widget.personagem!;
    _nomeController.text = p.nome;
    _nivelController.text = p.nivel.toString();

    _forController.text = p.atributosBase.forca.toString();
    _desController.text = p.atributosBase.destreza.toString();
    _conController.text = p.atributosBase.constituicao.toString();
    _intController.text = p.atributosBase.inteligencia.toString();
    _sabController.text = p.atributosBase.sabedoria.toString();
    _carController.text = p.atributosBase.carisma.toString();

    try {
      _racaSelecionada = viewModel.racasDisponiveis.firstWhere(
        (r) => r.id == p.raca.id,
      );
      _classeSelecionada = viewModel.classesDisponiveis.firstWhere(
        (c) => c.id == p.classe.id,
      );

      if (p.arma != null) {
        _armaSelecionada = viewModel.armasDisponiveis.firstWhere(
          (a) => a.id == p.arma!.id,
        );
      }
      if (p.armadura != null) {
        _armaduraSelecionada = viewModel.armasDisponiveis.firstWhere(
          (a) => a.id == p.armadura!.id,
        );
      }

      _habilidadesSelecionadasIds.addAll(
        p.habilidadesConhecidas.map((h) => h.id),
      );
    } catch (e) {
      print(
        "Error pre-selecting data (saved item might have been deleted): $e",
      );
    }

    setState(() {});
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _nivelController.dispose();
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
      if (_racaSelecionada == null || _classeSelecionada == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please select a race and a class.')), // Translated
        );
        return;
      }

      final params = PersonagemParams(
        nome: _nomeController.text,
        nivel: int.tryParse(_nivelController.text) ?? 1,
        racaId: _racaSelecionada!.id,
        classeId: _classeSelecionada!.id,
        armaId: _armaSelecionada?.id,
        armaduraId: _armaduraSelecionada?.id,
        habilidadesConhecidasIds: _habilidadesSelecionadasIds.toList(),
        habilidadesPreparadasIds: _habilidadesSelecionadasIds.toList(),
        atributos: AtributosBase(
          forca: int.tryParse(_forController.text) ?? 10,
          destreza: int.tryParse(_desController.text) ?? 10,
          constituicao: int.tryParse(_conController.text) ?? 10,
          inteligencia: int.tryParse(_intController.text) ?? 10,
          sabedoria: int.tryParse(_sabController.text) ?? 10,
          carisma: int.tryParse(_carController.text) ?? 10,
        ),
      );

      final viewModel = Provider.of<CriarPersonagemViewModel>(
        context,
        listen: false,
      );
      final success = await viewModel.criarOuAtualizarPersonagem(
        params,
        id: widget.personagem?.id,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Character ${isEditing ? 'updated' : 'created'} successfully!', // Translated
            ),
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  // Helper method to get thematic icons for attributes
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
        title: Text(isEditing ? 'Edit Character' : 'Create New Character'), // Translated title
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.appBarTheme.foregroundColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Consumer<CriarPersonagemViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading && viewModel.racasDisponiveis.isEmpty) {
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
              padding: const EdgeInsets.all(16.0),
              children: [
                // Character Name
                TextFormField(
                  controller: _nomeController,
                  decoration: InputDecoration(
                    labelText: 'Character Name', // Translated label
                    hintText: 'e.g., Aragorn, Gandalf',
                    prefixIcon: Icon(Icons.person_pin_outlined, color: theme.colorScheme.primary), // Thematic icon
                    filled: true,
                    fillColor: theme.inputDecorationTheme.fillColor,
                    border: theme.inputDecorationTheme.border,
                    enabledBorder: theme.inputDecorationTheme.enabledBorder,
                    focusedBorder: theme.inputDecorationTheme.focusedBorder,
                    labelStyle: theme.inputDecorationTheme.labelStyle,
                    hintStyle: theme.inputDecorationTheme.hintStyle,
                  ),
                  style: TextStyle(color: theme.colorScheme.onBackground), // Text color
                  validator: (v) =>
                      v!.trim().isEmpty ? 'Required field' : null, // Translated
                ),
                const SizedBox(height: 16),

                // Race Dropdown
                DropdownButtonFormField<Raca>(
                  value: _racaSelecionada,
                  decoration: InputDecoration(
                    labelText: 'Race', // Translated label
                    prefixIcon: Icon(Icons.groups_3_outlined, color: theme.colorScheme.primary), // Thematic icon
                    filled: true,
                    fillColor: theme.inputDecorationTheme.fillColor,
                    border: theme.inputDecorationTheme.border,
                    enabledBorder: theme.inputDecorationTheme.enabledBorder,
                    focusedBorder: theme.inputDecorationTheme.focusedBorder,
                    labelStyle: theme.inputDecorationTheme.labelStyle,
                    hintStyle: theme.inputDecorationTheme.hintStyle,
                  ),
                  items: viewModel.racasDisponiveis.map((raca) {
                    return DropdownMenuItem(
                      value: raca,
                      child: Text(
                        raca.nome,
                        style: TextStyle(color: theme.colorScheme.onSurface), // Text color for dropdown items
                      ),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _racaSelecionada = value),
                  validator: (v) => v == null ? 'Please select a race' : null, // Translated
                  dropdownColor: theme.cardTheme.color, // Dropdown background color
                  style: TextStyle(color: theme.colorScheme.onSurface), // Text color when selected
                ),
                const SizedBox(height: 16),

                // Class Dropdown
                DropdownButtonFormField<ClassePersonagem>(
                  value: _classeSelecionada,
                  decoration: InputDecoration(
                    labelText: 'Class', // Translated label
                    prefixIcon: Icon(Icons.auto_stories_outlined, color: theme.colorScheme.primary), // Thematic icon
                    filled: true,
                    fillColor: theme.inputDecorationTheme.fillColor,
                    border: theme.inputDecorationTheme.border,
                    enabledBorder: theme.inputDecorationTheme.enabledBorder,
                    focusedBorder: theme.inputDecorationTheme.focusedBorder,
                    labelStyle: theme.inputDecorationTheme.labelStyle,
                    hintStyle: theme.inputDecorationTheme.hintStyle,
                  ),
                  items: viewModel.classesDisponiveis.map((classe) {
                    return DropdownMenuItem(
                      value: classe,
                      child: Text(
                        classe.nome,
                        style: TextStyle(color: theme.colorScheme.onSurface), // Text color for dropdown items
                      ),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _classeSelecionada = value),
                  validator: (v) => v == null ? 'Please select a class' : null, // Translated
                  dropdownColor: theme.cardTheme.color, // Dropdown background color
                  style: TextStyle(color: theme.colorScheme.onSurface), // Text color when selected
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
                  style: TextStyle(color: theme.colorScheme.onBackground), // Text color
                  validator: (v) =>
                      v!.trim().isEmpty || int.tryParse(v) == null ? 'Enter a number' : null, // Translated
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
                    prefixIcon: Icon(Icons.gavel, color: theme.colorScheme.primary), // Thematic icon
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
                        style: TextStyle(color: theme.colorScheme.onSurface), // Text color for dropdown items
                      ),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _armaSelecionada = value),
                  dropdownColor: theme.cardTheme.color, // Dropdown background color
                  style: TextStyle(color: theme.colorScheme.onSurface), // Text color when selected
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<Arma>(
                  value: _armaduraSelecionada,
                  decoration: InputDecoration(
                    labelText: 'Armor', // Translated label
                    prefixIcon: Icon(Icons.shield, color: theme.colorScheme.primary), // Thematic icon
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
                        style: TextStyle(color: theme.colorScheme.onSurface), // Text color for dropdown items
                      ),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _armaduraSelecionada = value),
                  dropdownColor: theme.cardTheme.color, // Dropdown background color
                  style: TextStyle(color: theme.colorScheme.onSurface), // Text color when selected
                ),
                const SizedBox(height: 24),

                // Abilities Section
                ExpansionTile(
                  title: Text(
                    'Abilities (${_habilidadesSelecionadasIds.length})', // Translated
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onBackground,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  collapsedIconColor: theme.colorScheme.primary, // Icon color when collapsed
                  iconColor: theme.colorScheme.primary, // Icon color when expanded
                  backgroundColor: theme.colorScheme.surface, // Background for the tile
                  collapsedBackgroundColor: theme.colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: theme.colorScheme.primaryContainer, width: 1.5),
                  ),
                  children: viewModel.habilidadesDisponiveis.map((habilidade) {
                    return CheckboxListTile(
                      title: Text(
                        habilidade.nome,
                        style: TextStyle(color: theme.colorScheme.onSurface), // Text color
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
                      activeColor: theme.colorScheme.secondary, // Soft Green checkbox when active
                      checkColor: Colors.white, // White check mark
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Submit Button
                ElevatedButton(
                  onPressed: viewModel.isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: theme.colorScheme.secondary, // Soft Green button
                    foregroundColor: theme.colorScheme.onSecondary, // Text color on green
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // Rounded button
                    elevation: 5,
                  ),
                  child: viewModel.isLoading
                      ? CircularProgressIndicator(color: theme.colorScheme.onSecondary)
                      : Text(
                          isEditing ? 'Save Changes' : 'Create Character', // Translated
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

  Widget _buildAttributeField(
      String label, TextEditingController controller, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0), // Very minimal horizontal padding
      child: Container(
        // Removed Card for more direct size control, replaced with Container
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