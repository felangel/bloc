@Tags(['pull-request-only'])
import 'package:build_verify/build_verify.dart';
import 'package:test/test.dart';

void main() {
  test('ensure_build', () {
    expectBuildClean(packageRelativeDirectory: 'packages/bloc_tools');
  });
}
