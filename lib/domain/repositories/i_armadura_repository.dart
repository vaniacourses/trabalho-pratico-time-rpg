import 'package:trabalho_rpg/domain/entities/armadura.dart';

abstract class IArmaduraRepository {
  Future<List<Armadura>> getAllArmaduras();
  Future<Armadura?> getArmaduraById(String id);
  Future<void> saveArmadura(Armadura armadura);
  Future<void> deleteArmadura(String id);
}