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
    
    // CORREÇÃO: A lógica foi movida para dentro do addPostFrameCallback
    // para garantir que seja executada após o primeiro build.
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

  // Nova função para organizar o preenchimento do formulário
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
        "Erro ao pré-selecionar dados (item salvo pode ter sido deletado): $e",
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
          const SnackBar(content: Text('Por favor, selecione uma raça e uma classe.')),
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
              'Personagem ${isEditing ? 'atualizado' : 'criado'} com sucesso!',
            ),
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Personagem' : 'Criar Novo Personagem'),
      ),
      body: Consumer<CriarPersonagemViewModel>(
        builder: (context, viewModel, child) {
          // A verificação de 'isLoading' agora precisa ser mais específica
          // para não mostrar o loading toda vez que o estado do formulário mudar.
          if (viewModel.isLoading && viewModel.racasDisponiveis.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (viewModel.error != null) {
            return Center(child: Text('Erro: ${viewModel.error}'));
          }

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                TextFormField(
                  controller: _nomeController,
                  decoration: const InputDecoration(
                    labelText: 'Nome do Personagem',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v!.trim().isEmpty ? 'Campo obrigatório' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<Raca>(
                  value: _racaSelecionada,
                  decoration: const InputDecoration(
                    labelText: 'Raça',
                    border: OutlineInputBorder(),
                  ),
                  items: viewModel.racasDisponiveis.map((raca) {
                    return DropdownMenuItem(value: raca, child: Text(raca.nome));
                  }).toList(),
                  onChanged: (value) => setState(() => _racaSelecionada = value),
                  validator: (v) => v == null ? 'Selecione uma raça' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<ClassePersonagem>(
                  value: _classeSelecionada,
                  decoration: const InputDecoration(
                    labelText: 'Classe',
                    border: OutlineInputBorder(),
                  ),
                  items: viewModel.classesDisponiveis.map((classe) {
                    return DropdownMenuItem(value: classe, child: Text(classe.nome));
                  }).toList(),
                  onChanged: (value) => setState(() => _classeSelecionada = value),
                  validator: (v) => v == null ? 'Selecione uma classe' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nivelController,
                  decoration: const InputDecoration(
                    labelText: 'Nível',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                const SizedBox(height: 24),
                Text(
                  'Atributos',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.5,
                  children: [
                    _buildAttributeField('FOR', _forController),
                    _buildAttributeField('DES', _desController),
                    _buildAttributeField('CON', _conController),
                    _buildAttributeField('INT', _intController),
                    _buildAttributeField('SAB', _sabController),
                    _buildAttributeField('CAR', _carController),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Equipamentos',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                DropdownButtonFormField<Arma>(
                  value: _armaSelecionada,
                  decoration: const InputDecoration(
                    labelText: 'Arma',
                    border: OutlineInputBorder(),
                  ),
                  items: viewModel.armasDisponiveis.map((arma) {
                    return DropdownMenuItem(
                      value: arma,
                      child: Text(arma.nome),
                    );
                  }).toList(),
                  onChanged: (value) =>
                      setState(() => _armaSelecionada = value),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<Arma>(
                  value: _armaduraSelecionada,
                  decoration: const InputDecoration(
                    labelText: 'Armadura',
                    border: OutlineInputBorder(),
                  ),
                  items: viewModel.armasDisponiveis.map((arma) {
                    return DropdownMenuItem(
                      value: arma,
                      child: Text(arma.nome),
                    );
                  }).toList(),
                  onChanged: (value) =>
                      setState(() => _armaduraSelecionada = value),
                ),
                const SizedBox(height: 24),
                ExpansionTile(
                  title: Text(
                    'Habilidades (${_habilidadesSelecionadasIds.length})',
                  ),
                  children: viewModel.habilidadesDisponiveis.map((habilidade) {
                    return CheckboxListTile(
                      title: Text(habilidade.nome),
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
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: viewModel.isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  child: viewModel.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          isEditing ? 'Salvar Alterações' : 'Criar Personagem',
                        ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAttributeField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      ),
    );
  }
}