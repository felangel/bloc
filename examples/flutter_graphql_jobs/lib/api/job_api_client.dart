import 'package:flutter_graphql_jobs/api/api.dart';
import 'package:flutter_graphql_jobs/api/queries/queries.dart' as queries;
import 'package:graphql/client.dart';

class GetJobsRequestFailure implements Exception {}

class JobsApiClient {
  const JobsApiClient({required GraphQLClient graphQLClient})
      : _graphQLClient = graphQLClient;

  factory JobsApiClient.create() {
    final httpLink = HttpLink('https://api.graphql.jobs');
    final link = Link.from([httpLink]);
    return JobsApiClient(
      graphQLClient: GraphQLClient(cache: GraphQLCache(), link: link),
    );
  }

  final GraphQLClient _graphQLClient;

  Future<List<Job>> getJobs() async {
    final result = await _graphQLClient.query(
      QueryOptions(document: gql(queries.getJobs)),
    );
    if (result.hasException) throw GetJobsRequestFailure();
    final data = result.data?['jobs'] as List;
    return data
        .map((dynamic e) => Job.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
