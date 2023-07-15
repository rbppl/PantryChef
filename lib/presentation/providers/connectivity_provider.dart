import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantry_chef/data/api/connectivity_service.dart';
import 'package:pantry_chef/di/service_locator.dart';

final connectivityProvider = FutureProvider<bool>((ref) async {
  final connectivityService = getIt<ConnectivityService>();
  return await connectivityService.isConnected();
});
