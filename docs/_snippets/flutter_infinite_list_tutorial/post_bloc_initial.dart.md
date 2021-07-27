```dart
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_infinite_list/bloc/bloc.dart';
import 'package:flutter_infinite_list/post.dart';

part 'post_event.dart';
part 'post_state.dart';

const _postLimit = 20;

class PostBloc extends Bloc<PostEvent, PostState> {
  PostBloc({required this.httpClient}) : super(const PostState());

  final http.Client httpClient;

  @override
  Stream<PostState> mapEventToState(PostEvent event) async* {
    // TODO: implement mapEventToState
    yield null;
  }
}
```
