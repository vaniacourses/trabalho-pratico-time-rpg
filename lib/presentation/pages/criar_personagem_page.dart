import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trabalho_rpg/domain/entities/atributos_base.dart';
import 'package:trabalho_rpg/domain/entities/classe_personagem.dart';
import 'package:trabalho_rpg/domain/entities/raca.dart';
import 'package:trabalho_rpg/domain/factories/personagem_params.dart';
import 'package:trabalho_rpg/presentation/providers/criar_personagem_view_model.dart';

class CriarPersonagemPage extends StatefulWidget {
  const CriarPersonagemPage({super.key});

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

  @override
  void initState() {
    super.initState();
    // Pede ao ViewModel para carregar as opções de Raça e Classe.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CriarPersonagemViewModel>(context, listen: false)
          .carregarDadosIniciais();
    });
  }

  @override
  void dispose() {
    // Limpeza dos controllers
    _nomeController.dispose();
    _nivelController.dispose();
    _forController.dispose();
    // ... etc para todos os controllers
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
        nivel: int.parse(_nivelController.text),
        racaId: _racaSelecionada!.id,
        classeId: _classeSelecionada!.id,
        atributos: AtributosBase(
          forca: int.parse(_forController.text),
          destreza: int.parse(_desController.text),
          constituicao: int.parse(_conController.text),
          inteligencia: int.parse(_intController.text),
          sabedoria: int.parse(_sabController.text),
          carisma: int.parse(_carController.text),
        ),
      );

      final success = await Provider.of<CriarPersonagemViewModel>(context, listen: false)
          .criarEsalvarPersonagem(params);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Personagem criado com sucesso!')),
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar Novo Personagem')),
      body: Consumer<CriarPersonagemViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
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
                  decoration: const InputDecoration(labelText: 'Nome do Personagem'),
                  validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
                ),
                DropdownButtonFormField<Raca>(
                  value: _racaSelecionada,
                  decoration: const InputDecoration(labelText: 'Raça'),
                  items: viewModel.racasDisponiveis.map((raca) {
                    return DropdownMenuItem(value: raca, child: Text(raca.nome));
                  }).toList(),
                  onChanged: (value) => setState(() => _racaSelecionada = value),
                  validator: (v) => v == null ? 'Campo obrigatório' : null,
                ),
                DropdownButtonFormField<ClassePersonagem>(
                  value: _classeSelecionada,
                  decoration: const InputDecoration(labelText: 'Classe'),
                  items: viewModel.classesDisponiveis.map((classe) {
                    return DropdownMenuItem(value: classe, child: Text(classe.nome));
                  }).toList(),
                  onChanged: (value) => setState(() => _classeSelecionada = value),
                  validator: (v) => v == null ? 'Campo obrigatório' : null,
                ),
                TextFormField(
                  controller: _nivelController,
                  decoration: const InputDecoration(labelText: 'Nível'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20),
                Text('Atributos', style: Theme.of(context).textTheme.titleLarge),
                // Uma grid simples para os atributos
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 2,
                  children: [
                    _buildAttributeField('FOR', _forController),
                    _buildAttributeField('DES', _desController),
                    _buildAttributeField('CON', _conController),
                    _buildAttributeField('INT', _intController),
                    _buildAttributeField('SAB', _sabController),
                    _buildAttributeField('CAR', _carController),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Salvar Personagem'),
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
      ),
    );
  }
}