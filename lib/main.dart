import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:trabalho_rpg/data/datasources/database_helper.dart';
import 'package:trabalho_rpg/data/factories/inimigo_factory_impl.dart';
import 'package:trabalho_rpg/data/factories/personagem_factory_impl.dart';
import 'package:trabalho_rpg/data/repositories/arma_repository_impl.dart';
import 'package:trabalho_rpg/data/repositories/classe_personagem_repository_impl.dart';
import 'package:trabalho_rpg/data/repositories/habilidade_repository_impl.dart';
import 'package:trabalho_rpg/data/repositories/inimigo_repository_impl.dart';
import 'package:trabalho_rpg/data/repositories/personagem_repository_impl.dart';
import 'package:trabalho_rpg/data/repositories/raca_repository_impl.dart';
import 'package:trabalho_rpg/domain/factories/ficha_factory.dart';
import 'package:trabalho_rpg/domain/repositories/i_arma_repository.dart';
import 'package:trabalho_rpg/domain/repositories/i_classe_personagem_repository.dart';
import 'package:trabalho_rpg/domain/repositories/i_habilidade_repository.dart';
import 'package:trabalho_rpg/domain/repositories/i_inimigo_repository.dart';
import 'package:trabalho_rpg/domain/repositories/i_personagem_repository.dart';
import 'package:trabalho_rpg/domain/repositories/i_raca_repository.dart';
import 'package:trabalho_rpg/presentation/pages/criar_editar_inimigo_page.dart';
import 'package:trabalho_rpg/presentation/pages/criar_personagem_page.dart';
import 'package:trabalho_rpg/presentation/pages/gerenciar_armas_page.dart';
import 'package:trabalho_rpg/presentation/pages/gerenciar_classes_page.dart';
import 'package:trabalho_rpg/presentation/pages/gerenciar_habilidades_page.dart';
import 'package:trabalho_rpg/presentation/pages/gerenciar_inimigos_page.dart';
import 'package:trabalho_rpg/presentation/pages/gerenciar_personagens_page.dart';
import 'package:trabalho_rpg/presentation/pages/gerenciar_racas_page.dart';
import 'package:trabalho_rpg/presentation/providers/armas_view_model.dart';
import 'package:trabalho_rpg/presentation/providers/classes_view_model.dart';
import 'package:trabalho_rpg/presentation/providers/criar_personagem_view_model.dart';
import 'package:trabalho_rpg/presentation/providers/habilidades_view_model.dart';
import 'package:trabalho_rpg/presentation/providers/inimigos_view_model.dart';
import 'package:trabalho_rpg/presentation/providers/personagens_view_model.dart';
import 'package:trabalho_rpg/presentation/providers/racas_view_model.dart';
import 'package:uuid/uuid.dart';

void main() async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  runApp(const MyAppProviders());
}

class MyAppProviders extends StatelessWidget {
  const MyAppProviders({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Dependências Globais
        Provider<Uuid>(create: (_) => const Uuid()),
        Provider<DatabaseHelper>(create: (_) => DatabaseHelper.instance),

        // Repositórios
        ProxyProvider<DatabaseHelper, IRacaRepository>(
          update: (_, db, __) => RacaRepositoryImpl(dbHelper: db),
        ),
        ProxyProvider<DatabaseHelper, IClassePersonagemRepository>(
          update: (_, db, __) => ClassePersonagemRepositoryImpl(dbHelper: db),
        ),
        ProxyProvider<DatabaseHelper, IArmaRepository>(
          update: (_, db, __) => ArmaRepositoryImpl(dbHelper: db),
        ),
        ProxyProvider<DatabaseHelper, IHabilidadeRepository>(
          update: (_, db, __) => HabilidadeRepositoryImpl(dbHelper: db),
        ),
        ProxyProvider<DatabaseHelper, IPersonagemRepository>(
          update: (_, db, __) => PersonagemRepositoryImpl(
            dbHelper: db,
            habilidadeRepository: HabilidadeRepositoryImpl(dbHelper: db),
          ),
        ),
        ProxyProvider<DatabaseHelper, IInimigoRepository>(
          update: (_, db, __) => InimigoRepositoryImpl(
            dbHelper: db,
            habilidadeRepository: HabilidadeRepositoryImpl(dbHelper: db),
          ),
        ),

        // Factories - Aqui precisamos de uma solução para prover múltiplas implementações de IFichaFactory
        // Por agora, vamos prover as duas separadamente
        Provider<PersonagemFactoryImpl>(
          create: (ctx) => PersonagemFactoryImpl(
            racaRepository: ctx.read(),
            classeRepository: ctx.read(),
            armaRepository: ctx.read(),
            habilidadeRepository: ctx.read(),
            uuid: ctx.read(),
          ),
        ),
        Provider<InimigoFactoryImpl>(
          create: (ctx) => InimigoFactoryImpl(
            armaRepository: ctx.read(),
            habilidadeRepository: ctx.read(),
            uuid: ctx.read(),
          ),
        ),

        // ViewModels
        ChangeNotifierProvider(
          create: (ctx) =>
              RacasViewModel(racaRepository: ctx.read(), uuid: ctx.read()),
        ),
        ChangeNotifierProvider(
          create: (ctx) =>
              ClassesViewModel(classeRepository: ctx.read(), uuid: ctx.read()),
        ),
        ChangeNotifierProvider(
          create: (ctx) =>
              ArmasViewModel(armaRepository: ctx.read(), uuid: ctx.read()),
        ),
        ChangeNotifierProvider(
          create: (ctx) => HabilidadesViewModel(
            habilidadeRepository: ctx.read(),
            uuid: ctx.read(),
          ),
        ),
        ChangeNotifierProvider(
          create: (ctx) =>
              PersonagensViewModel(personagemRepository: ctx.read()),
        ),
        ChangeNotifierProvider(
          create: (ctx) => CriarPersonagemViewModel(
            racaRepository: ctx.read(),
            classeRepository: ctx.read(),
            armaRepository: ctx.read(),
            habilidadeRepository: ctx.read(),
            personagemRepository: ctx.read(),
            fichaFactory: ctx.read<PersonagemFactoryImpl>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (ctx) => InimigosViewModel(
            inimigoRepository: ctx.read(),
            // ATENÇÃO: Aqui usamos a factory concreta de Inimigo
            fichaFactory: ctx.read<InimigoFactoryImpl>(),
          ),
        ),
      ],
      child: const MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RPG Battle Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('RPG Manager'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.group), text: 'Fichas'),
              Tab(icon: Icon(Icons.settings), text: 'Gerenciamento'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            FichasTabPage(),
            GerenciamentoGeralPage(),
          ],
        ),
      ),
    );
  }
}

class FichasTabPage extends StatelessWidget {
  const FichasTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Este TabController é para as sub-abas (Personagens, Inimigos)
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.person), text: 'Personagens'),
              Tab(icon: Icon(Icons.adb), text: 'Inimigos'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [GerenciarPersonagensPage(), GerenciarInimigosPage()],
        ),
      ),
    );
  }
}

class GerenciamentoGeralPage extends StatelessWidget {
  const GerenciamentoGeralPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Função para navegar para a página de criação correta
    void navigateToCreate(BuildContext context, String type) {
      if (type == 'personagem') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CriarPersonagemPage()),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CriarEditarInimigoPage()),
        );
      }
    }

    return Scaffold(
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.shield),
            title: const Text('Gerenciar Raças'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const GerenciarRacasPage()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.star),
            title: const Text('Gerenciar Classes'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const GerenciarClassesPage()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.hardware),
            title: const Text('Gerenciar Armas'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const GerenciarArmasPage()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.flash_on),
            title: const Text('Gerenciar Habilidades'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const GerenciarHabilidadesPage(),
              ),
            ),
          ),
        ],
      ),
      // O botão de "Adicionar" agora mostra um menu de opções
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (ctx) {
              return Wrap(
                children: <Widget>[
                  ListTile(
                    leading: const Icon(Icons.person_add),
                    title: const Text('Criar Ficha de Personagem'),
                    onTap: () {
                      Navigator.pop(ctx); // Fecha o BottomSheet
                      navigateToCreate(context, 'personagem');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.adb),
                    title: const Text('Criar Ficha de Inimigo'),
                    onTap: () {
                      Navigator.pop(ctx); // Fecha o BottomSheet
                      navigateToCreate(context, 'inimigo');
                    },
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
