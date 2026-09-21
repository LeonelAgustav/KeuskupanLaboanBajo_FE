import '../../local/app_database.dart';

abstract class RoleRepository {
  Future<List<Role>> getAll();
  Future<Role?> getById(int id);
  Future<int> create({required String nama});
  Future<void> update(int id, {String? nama});
  Future<void> delete(int id);
}