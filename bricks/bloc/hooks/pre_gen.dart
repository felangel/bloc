import 'package:mason/mason.dart';

void run(HookContext context) {
  final logger = context.logger;
  bool hasEvents = true;
  if (!logger.confirm(
    '? Do you want to add events to your bloc?',
    defaultValue: false,
  )) {
    context.vars = {
      ...context.vars,
      'hasEvents': false,
    };


    hasEvents = false;
  }
  if (hasEvents) {
    logger.alert(lightYellow.wrap('enter "e" to exit adding events'));
    logger.alert('Format: eventName e.g, myEvent:');
    final events = <Map<String, dynamic>>[];

    while (true) {
      final event = logger.prompt(':').replaceAll(RegExp('\\s+'), ' ').trim();
      if (event.toLowerCase() == 'e') {
        break;
      }
      // TODO check if event only contains alphabetical characters


      final eventName = event;
      events.add({
        'eventName': eventName,

      });
    }
    context.vars = {
      ...context.vars,
      'events': events,
      'hasEvents': events.isNotEmpty,
    };
  }


  // adding states
  if (!logger.confirm(
    '? Do you want to add states to your bloc?',
    defaultValue: false,
  )) {
    context.vars = {
      ...context.vars,
      'hasStates': false,
    };
    return;
  }

  logger.alert(lightYellow.wrap('enter "e" to exit adding states'));
  logger.alert('Format: stateName e.g, myState:');
  final states = <Map<String, dynamic>>[];

  while (true) {
    final state = logger.prompt(':').replaceAll(RegExp('\\s+'), ' ').trim();
    if (state.toLowerCase() == 'e') {
      break;
    }
    // TODO check if state only contains alphabetical characters


    final stateName = state;
    states.add({
      'stateName': stateName,

    });
  }
  context.vars = {
    ...context.vars,
    'states': states,
    'hasStates': states.isNotEmpty,
  };
}