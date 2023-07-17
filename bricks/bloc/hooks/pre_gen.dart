import 'package:mason/mason.dart';

Future<void> run(HookContext context) async {
  final style = context.vars['style'];
  final states = context.vars['states'] as List;
  final events = context.vars['events'] as List;
  context.vars = {
    ...context.vars,
    'initial_state':
        states.firstOrNull ?? style == 'freezed' ? 'initial' : 'state',
    'has_states': states.isNotEmpty,
    'has_events': events.isNotEmpty,
    'use_basic': style == 'basic',
    'use_equatable': style == 'equatable',
    'use_freezed': style == 'freezed',
  };
}
