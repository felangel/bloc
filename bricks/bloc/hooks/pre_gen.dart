import 'package:mason/mason.dart';

Future<void> run(HookContext context) async {
  final style = context.vars['style'] as String;

  final events = <Map<String, dynamic>>[];
  if (context.logger.confirm('? Do you want to add events?')) {
    context.logger.info('Enter event names (empty line to finish):');
    while (true) {
      final input = context.logger.prompt(
        '  Event name (leave empty to finish)',
      );
      if (input.isEmpty) break;
      events.add({'eventName': input});
    }
  }

  final states = <Map<String, dynamic>>[];
  if (context.logger.confirm('? Do you want to add states?')) {
    context.logger.info('Enter state names (empty line to finish):');
    while (true) {
      final input = context.logger.prompt(
        '  State name (leave empty to finish)',
      );
      if (input.isEmpty) break;
      states.add({'stateName': input});
    }
  }

  context.vars = {
    ...context.vars,
    'use_basic': style == 'basic',
    'use_equatable': style == 'equatable',
    'use_freezed': style == 'freezed',
    'events': events,
    'has_events': events.isNotEmpty,
    'states': states,
    'has_states': states.isNotEmpty,
  };
}
