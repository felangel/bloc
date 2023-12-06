import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:devtools_app_shared/service.dart';
import 'package:equatable/equatable.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc(ServiceManager serviceManager)
      : _serviceManager = serviceManager,
        super(const HomeState()) {
    on<HomeStarted>(_onHomeStarted, transformer: sequential());
  }

  final ServiceManager _serviceManager;

  Future<void> _onHomeStarted(
    HomeStarted event,
    Emitter<HomeState> emit,
  ) async {
    try {
      final response = await _serviceManager.callServiceExtensionOnMainIsolate(
        'ext.bloc.getBlocs',
      );
      final blocs = response.json?['blocs'] as List? ?? [];
      emit(
        HomeState(
          blocs: blocs
              .map((b) => BlocNode.fromJson(b as Map<String, dynamic>))
              .toList(),
        ),
      );
    } catch (_) {}

    return emit.onEach(
      _serviceManager.service!.onExtensionEvent,
      onData: (event) {
        final type = event.extensionKind;
        switch (type) {
          case 'bloc:onCreate':
            final bloc = BlocNode.fromJson(
              event.json!['extensionData'] as Map<String, dynamic>,
            );
            emit(HomeState(blocs: [...state.blocs, bloc]));
          case 'bloc:onClose':
            final bloc = BlocNode.fromJson(
              event.json!['extensionData'] as Map<String, dynamic>,
            );
            emit(HomeState(blocs: [...state.blocs]..remove(bloc)));
          case 'bloc:onChange':
            final bloc = BlocNode.fromJson(
              event.json!['extensionData'] as Map<String, dynamic>,
            );
            emit(
              HomeState(
                blocs: [...state.blocs]
                    .replace(
                      where: (b) => b.hash == bloc.hash,
                      update: (_) => bloc,
                    )
                    .toList(),
              ),
            );
        }
      },
    );
  }
}

extension IterableExtension<T> on Iterable<T> {
  Iterable<T> replace({
    required bool Function(T element) where,
    required T Function(T value) update,
  }) {
    return map(
      (element) => where(element) ? update(element) : element,
    );
  }
}
