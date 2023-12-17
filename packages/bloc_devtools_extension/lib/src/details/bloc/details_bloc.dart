import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:bloc_devtools_extension/src/home/home.dart';
import 'package:devtools_app_shared/service.dart';
import 'package:equatable/equatable.dart';

part 'details_event.dart';
part 'details_state.dart';

class DetailsBloc extends Bloc<DetailsEvent, DetailsState> {
  DetailsBloc(
    ServiceManager serviceManager, {
    required this.blocHash,
  })  : _serviceManager = serviceManager,
        super(const DetailsState()) {
    on<DetailsStarted>(_onDetailsStarted, transformer: restartable());
  }

  final int blocHash;

  final ServiceManager _serviceManager;

  Future<void> _onDetailsStarted(
    DetailsStarted event,
    Emitter<DetailsState> emit,
  ) async {
    try {
      final response = await _serviceManager.callServiceExtensionOnMainIsolate(
        'ext.bloc.getBlocs',
      );
      final blocs = (response.json?['blocs'] as List? ?? [])
          .map((b) => BlocNode.fromJson(b as Map<String, dynamic>))
          .toList();
      final bloc = blocs.where((bloc) => bloc.hash == blocHash);
      emit(DetailsState(bloc: bloc.firstOrNull));
    } catch (_) {}

    return emit.onEach(
      _serviceManager.service!.onExtensionEvent,
      onData: (event) {
        final type = event.extensionKind;
        switch (type) {
          case 'Flutter.FrameworkInitialization':
            emit(const DetailsState());
            add(const DetailsStarted());
          case 'bloc:onClose':
            final bloc = BlocNode.fromJson(
              event.json!['extensionData'] as Map<String, dynamic>,
            );
            if (bloc.hash == blocHash) emit(const DetailsState());
          case 'bloc:onChange':
            final bloc = BlocNode.fromJson(
              event.json!['extensionData'] as Map<String, dynamic>,
            );
            if (bloc.hash == blocHash) emit(DetailsState(bloc: bloc));
        }
      },
    );
  }
}
