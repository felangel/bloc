import 'package:mason/mason.dart';

Future<void> run(HookContext context) async {
  final style = context.vars['style'];
  context.vars = {
    ...context.vars,
    'use_basic': style == 'basic',
    'use_equatable': style == 'equatable',
    'use_freezed': style == 'freezed',
  };
}
