import 'package:flutter/foundation.dart';
import 'package:mockito/mockito.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPathProviderPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  MockPathProviderPlatform({
    @required this.temporaryPath,
    @required this.getTemporaryPathCalled,
  });
  final String temporaryPath;
  final VoidCallback getTemporaryPathCalled;

  @override
  Future<String> getTemporaryPath() async {
    getTemporaryPathCalled();
    return temporaryPath;
  }
}
