import 'package:hydrated_bloc/hydrated_bloc.dart';

part '{{name.snakeCase()}}_event.dart';
part '{{name.snakeCase()}}_state.dart';

class {{name.pascalCase()}}Cubit extends HydratedCubit<{{name.pascalCase()}}State> {
  {{name.pascalCase()}}Cubit() : super(const {{name.pascalCase()}}State());

  @override
  Map<String, dynamic> toJson({{name.pascalCase()}}State state) {
    // TODO: implement toJson
  }

  @override
  {{name.pascalCase()}}State fromJson(Map<String, dynamic> json) {
    // TODO: implement fromJson
  }
}
