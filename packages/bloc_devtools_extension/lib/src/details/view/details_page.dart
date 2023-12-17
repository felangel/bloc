import 'package:bloc_devtools_extension/src/details/details.dart';
import 'package:devtools_app_shared/ui.dart';
import 'package:devtools_extensions/devtools_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DetailsPage extends StatelessWidget {
  const DetailsPage({required this.blocHash, super.key});

  static Route<void> route({required int blocHash}) {
    return MaterialPageRoute<void>(
      builder: (context) => DetailsPage(blocHash: blocHash),
    );
  }

  final int blocHash;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DetailsBloc(serviceManager, blocHash: blocHash)
        ..add(const DetailsStarted()),
      child: const DetailsView(),
    );
  }
}

class DetailsView extends StatelessWidget {
  const DetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<DetailsBloc>().state.bloc;
    return Scaffold(
      appBar: AppBar(
        title: Text(bloc?.name ?? '--'),
        centerTitle: false,
      ),
      body: RoundedOutlinedBorder(
        clip: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AreaPaneHeader(
              roundedTopBorder: false,
              includeTopBorder: false,
              title: Text('Details'),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Text('State: ${bloc?.state ?? '--'}'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
