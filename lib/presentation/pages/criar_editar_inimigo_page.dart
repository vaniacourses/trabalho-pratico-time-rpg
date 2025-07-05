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
    // CORREÇÃO: Movido para o addPostFrameCallback para evitar o erro de build.
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
          SnackBar(content: Text('Inimigo ${isEditing ? 'atualizado' : 'criado'} com sucesso!')),
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Inimigo' : 'Criar Novo Inimigo'),
      ),
      body: Consumer<InimigosViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading && viewModel.armasDisponiveis.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (viewModel.error != null) {
            return Center(child: Text(viewModel.error!));
          }
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextFormField(
                  controller: _nomeController,
                  decoration: const InputDecoration(
                    labelText: 'Nome do Inimigo',
                  ),
                  validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
                ),
                TextFormField(
                  controller: _tipoController,
                  decoration: const InputDecoration(
                    labelText: 'Tipo (ex: Besta, Humanoide)',
                  ),
                  validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
                ),
                TextFormField(
                  controller: _nivelController,
                  decoration: const InputDecoration(labelText: 'Nível'),
                  keyboardType: TextInputType.number,
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
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: TextFormField(
                        controller: _forController,
                        decoration: const InputDecoration(
                          labelText: 'FOR',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: TextFormField(
                        controller: _desController,
                        decoration: const InputDecoration(
                          labelText: 'DES',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: TextFormField(
                        controller: _conController,
                        decoration: const InputDecoration(
                          labelText: 'CON',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: TextFormField(
                        controller: _intController,
                        decoration: const InputDecoration(
                          labelText: 'INT',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: TextFormField(
                        controller: _sabController,
                        decoration: const InputDecoration(
                          labelText: 'SAB',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: TextFormField(
                        controller: _carController,
                        decoration: const InputDecoration(
                          labelText: 'CAR',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
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
                  items: viewModel.armasDisponiveis
                      .map(
                        (a) => DropdownMenuItem(value: a, child: Text(a.nome)),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _armaSelecionada = v),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<Arma>(
                  value: _armaduraSelecionada,
                  decoration: const InputDecoration(
                    labelText: 'Armadura',
                    border: OutlineInputBorder(),
                  ),
                  items: viewModel.armasDisponiveis
                      .map(
                        (a) => DropdownMenuItem(value: a, child: Text(a.nome)),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _armaduraSelecionada = v),
                ),
                const SizedBox(height: 24),
                ExpansionTile(
                  title: Text(
                    'Habilidades (${_habilidadesSelecionadasIds.length})',
                  ),
                  children: viewModel.habilidadesDisponiveis.map((h) {
                    return CheckboxListTile(
                      title: Text(h.nome),
                      value: _habilidadesSelecionadasIds.contains(h.id),
                      onChanged: (v) => setState(
                        () => v!
                            ? _habilidadesSelecionadasIds.add(h.id)
                            : _habilidadesSelecionadasIds.remove(h.id),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: Text(
                    isEditing ? 'Salvar Alterações' : 'Criar Inimigo',
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}