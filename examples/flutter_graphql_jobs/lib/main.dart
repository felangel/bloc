import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_graphql_jobs/api/api.dart';
import 'package:flutter_graphql_jobs/bloc/jobs_bloc.dart';

void main() => runApp(MyApp(jobsApiClient: JobsApiClient.create()));

class MyApp extends StatelessWidget {
  const MyApp({Key key, @required this.jobsApiClient})
      : assert(jobsApiClient != null),
        super(key: key);

  final JobsApiClient jobsApiClient;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocProvider(
        create: (_) => JobsBloc(
          jobsApiClient: jobsApiClient,
        )..add(JobsFetchStarted()),
        child: JobsPage(),
      ),
    );
  }
}

class JobsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Jobs')),
      body: Center(
        child: BlocBuilder<JobsBloc, JobsState>(
          builder: (context, state) {
            if (state is JobsLoadInProgress) {
              return CircularProgressIndicator();
            } else if (state is JobsLoadSuccess) {
              return ListView.builder(
                itemCount: state.jobs.length,
                itemBuilder: (context, index) {
                  final job = state.jobs[index];
                  return ListTile(
                    key: Key(job.id),
                    leading: Icon(Icons.location_city),
                    title: Text(job.title),
                    trailing: Icon(
                      job.isFeatured == true ? Icons.star : Icons.star_border,
                      color: Colors.orangeAccent,
                    ),
                    subtitle: job.locationNames != null
                        ? Text(job.locationNames)
                        : null,
                  );
                },
              );
            } else {
              return Text('Oops something went wrong!');
            }
          },
        ),
      ),
    );
  }
}
