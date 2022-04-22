import 'package:hydrated_bloc/hydrated_bloc.dart';

part '{{name.snakeCase()}}_event.dart';
part '{{name.snakeCase()}}_state.dart';

class {{name.pascalCase()}}Bloc extends HydratedBloc<{{name.pascalCase()}}Event, {{name.pascalCase()}}State> {
  {{name.pascalCase()}}Bloc() : super(const {{name.pascalCase()}}State()) {
    on<{{name.pascalCase()}}Event>((event, emit) {
      // TODO: implement event handler
    });
  }

  @override
  Map<String, dynamic> toJson({{name.pascalCase()}}State state) {
    // TODO: implement toJson
  }

  @override
  {{name.pascalCase()}}State fromJson(Map<String, dynamic> json) {
    // TODO: implement fromJson
  }
}
