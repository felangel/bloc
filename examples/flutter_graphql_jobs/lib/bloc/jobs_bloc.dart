import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_graphql_jobs/api/api.dart';
import 'package:flutter_graphql_jobs/api/job_api_client.dart';
import 'package:meta/meta.dart';

part 'jobs_event.dart';
part 'jobs_state.dart';

class JobsBloc extends Bloc<JobsEvent, JobsState> {
  JobsBloc({@required JobsApiClient jobsApiClient})
      : assert(jobsApiClient != null),
        _jobsApiClient = jobsApiClient,
        super(JobsLoadInProgress());

  final JobsApiClient _jobsApiClient;

  @override
  Stream<JobsState> mapEventToState(
    JobsEvent event,
  ) async* {
    if (event is JobsFetchStarted) {
      yield JobsLoadInProgress();
      try {
        final jobs = await _jobsApiClient.getJobs();
        yield JobsLoadSuccess(jobs);
      } on Exception catch (_) {
        yield JobsLoadFailure();
      }
    }
  }
}
