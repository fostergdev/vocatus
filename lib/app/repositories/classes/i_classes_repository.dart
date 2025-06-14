import 'package:vocatus/app/models/classe.dart';

abstract class IClasseRepository {
  Future<Classe> createClasse(Classe classe);
  Future<List<Classe>> readClasses({int? year, bool active = true});
  Future<void> updateClasse(Classe classe);
 
}
