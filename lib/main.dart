import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:trabalho_rpg/data/datasources/database_helper.dart';
import 'package:trabalho_rpg/tests/crud_test_runner.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  final dbHelper = DatabaseHelper.instance;
  final runner = CrudTestRunner(dbHelper);

  try {
    // await runner.testarCrudDePersonagem();
    // await runner.testarCrudDeInimigo();
    // await runner.testarCrudDeGrupo();
    // await runner.testarFactoryDePersonagem();
    // await runner.testarFactoryDeInimigo();
    await runner.testarStrategyHabilidade();

  } catch (e) {
    print('!!!!!!!!!! UM ERRO OCORREU DURANTE O TESTE !!!!!!!!!!');
    print(e);
  }
}
