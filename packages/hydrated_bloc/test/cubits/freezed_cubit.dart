import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'freezed_cubit.freezed.dart';
part 'freezed_cubit.g.dart';

class FreezedCubit extends HydratedCubit<Tree> {
  FreezedCubit() : super(null);

  void setQuestion(Tree tree) => emit(tree);

  @override
  Map<String, dynamic> toJson(Tree state) => state?.toJson();

  @override
  Tree fromJson(Map<String, dynamic> json) => Tree.fromJson(json);
}

@freezed
abstract class Question with _$Question {
  const factory Question({
    int id,
    String question,
  }) = _Question;

  factory Question.fromJson(Map<String, dynamic> json) =>
      _$QuestionFromJson(json);
}

@freezed
abstract class Tree with _$Tree {
  const factory Tree({
    Question question,
    Tree left,
    Tree right,
  }) = _QTree;

  factory Tree.fromJson(Map<String, dynamic> json) => _$TreeFromJson(json);
}
