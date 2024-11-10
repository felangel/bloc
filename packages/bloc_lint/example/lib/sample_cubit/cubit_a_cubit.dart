import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'cubit_a_state.dart';

class ACubit extends Cubit<AState> {
  ACubit() : super(AInitial());
}
