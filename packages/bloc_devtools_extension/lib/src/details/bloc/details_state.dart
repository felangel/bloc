part of 'details_bloc.dart';

class DetailsState extends Equatable {
  const DetailsState({this.bloc});

  final BlocNode? bloc;

  @override
  List<Object?> get props => [bloc];
}
