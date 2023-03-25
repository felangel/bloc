/// {@template analytic}
/// A mixin that provides an [eventName] and [parameters] for analytics.
/// {@endtemplate}
class Analytic {
  /// {@macro analytic}
  const Analytic(
    this.eventName, [
    this.parameters = const {},
  ]);

  /// The name of the event.
  final String eventName;

  /// The parameters to send with the event.
  final Map<String, dynamic> parameters;
}
