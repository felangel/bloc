import 'package:equatable/equatable.dart';

abstract class PostEvent extends Equatable {}

class Fetch extends PostEvent {
  @override
  String toString() => 'Fetch';
}
