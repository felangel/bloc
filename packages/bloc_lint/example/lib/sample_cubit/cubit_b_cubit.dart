import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'cubit_b_state.dart';

class BCubit extends Cubit<BState> {
  BCubit() : super(BInitial());
}
