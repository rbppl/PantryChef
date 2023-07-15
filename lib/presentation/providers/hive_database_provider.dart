import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantry_chef/data/local/hive_database.dart';
import 'package:pantry_chef/di/service_locator.dart';

final hiveDatabaseProvider = Provider<HiveDatabase>((ref) {
  return getIt<HiveDatabase>();
});
