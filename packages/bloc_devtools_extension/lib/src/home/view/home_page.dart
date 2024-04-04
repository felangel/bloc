import 'package:bloc_devtools_extension/src/details/details.dart';
import 'package:bloc_devtools_extension/src/home/home.dart';
import 'package:devtools_app_shared/ui.dart';
import 'package:devtools_extensions/devtools_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeBloc(serviceManager)..add(HomeStarted()),
      child: const HomeView(),
    );
  }
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return RoundedOutlinedBorder(
      clip: true,
      child: Column(
        children: [
          const AreaPaneHeader(
            roundedTopBorder: false,
            includeTopBorder: false,
            title: Text('Blocs'),
          ),
          Expanded(
            child: BlocBuilder<HomeBloc, HomeState>(
              builder: (context, state) => _BlocListView(blocs: state.blocs),
            ),
          ),
        ],
      ),
    );
  }
}

class _BlocListView extends StatelessWidget {
  const _BlocListView({required this.blocs});

  final List<BlocNode> blocs;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.bodyLarge?.copyWith(
      color: theme.colorScheme.primary,
    );
    final subtitleStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.secondary,
    );
    return ListView.separated(
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final bloc = blocs[index];
        return ListTile(
          key: Key('${bloc.name}_${bloc.hashCode}'),
          title: Text(bloc.name, style: titleStyle),
          subtitle: Text(
            bloc.lastModified.format(context),
            style: subtitleStyle,
          ),
          onTap: () => Navigator.of(context).push(
            DetailsPage.route(blocHash: bloc.hash),
          ),
        );
      },
      itemCount: blocs.length,
    );
  }
}

extension on DateTime {
  String format(BuildContext context) {
    return 'Last Modified: ${TimeOfDay.fromDateTime(this).format(context)}';
  }
}
