/// {@template analytic}
/// An interface that represents an analytics event.
/// {@endtemplate}
abstract class Analytic {
  /// The name of the event.
  String get eventName;

  /// The parameters to send with the event.
  Map<String, dynamic> get parameters => const {};
}
