part of 'jobs_bloc.dart';

@immutable
abstract class JobsState {}

class JobsLoadInProgress extends JobsState {}

class JobsLoadSuccess extends JobsState {
  JobsLoadSuccess(this.jobs);

  final List<Job> jobs;
}

class JobsLoadFailure extends JobsState {}
