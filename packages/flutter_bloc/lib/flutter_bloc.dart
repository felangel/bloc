/// Flutter widgets that make it easy to implement the BLoC design pattern.
/// Built to be used with the [bloc state management package](https://pub.dev/packages/bloc).
///
/// Get started at [bloclibrary.dev](https://bloclibrary.dev) 🚀
library flutter_bloc;

export 'package:bloc/bloc.dart';
export 'package:provider/provider.dart'
    show ProviderNotFoundException, ReadContext, SelectContext, WatchContext;

export './src/bloc_builder.dart';
export './src/bloc_consumer.dart';
export './src/bloc_listener.dart';
export './src/bloc_provider.dart';
export './src/bloc_selector.dart';
export './src/multi_bloc_listener.dart';
export './src/multi_bloc_provider.dart';
export './src/multi_repository_provider.dart';
export './src/repository_provider.dart';
