part of 'jobs_bloc.dart';

@immutable
abstract class JobsEvent {}

class JobsFetchStarted extends JobsEvent {}
