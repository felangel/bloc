import 'package:bloc_lint/src/rules/avoid_async_emit.dart';
import 'package:test/test.dart';

import '../lint_test_helper.dart';

void main() {
  group(AvoidAsyncEmit, () {
    lintTest(
      'does not report when emit is guarded by if (!isClosed)',
      rule: AvoidAsyncEmit.new,
      path: 'my_cubit.dart',
      content: '''
import 'package:flutter_bloc/flutter_bloc.dart';

class MyCubit extends Cubit<int> {
  MyCubit() : super(0);

  Future<void> foo() async {
    if (!isClosed) emit(1);
  }
}
''',
    );

    lintTest(
      'does not report when emit is guarded by if (isClosed == false)',
      rule: AvoidAsyncEmit.new,
      path: 'my_cubit.dart',
      content: '''
import 'package:flutter_bloc/flutter_bloc.dart';

class MyCubit extends Cubit<int> {
  MyCubit() : super(0);

  Future<void> foo() async {
    if (isClosed == false) emit(1);
  }
}
''',
    );

    lintTest(
      'reports when await is before emit in guard',
      rule: AvoidAsyncEmit.new,
      path: 'my_cubit.dart',
      content: '''
import 'package:flutter_bloc/flutter_bloc.dart';

class MyCubit extends Cubit<int> {
  MyCubit() : super(0);

  Future<void> foo() async {
    if (!isClosed) {
      await Future.value(1);
      emit(1);
      ^^^^
    }
  }
}
''',
    );

    lintTest(
      'reports when guard is a function call',
      rule: AvoidAsyncEmit.new,
      path: 'my_cubit.dart',
      content: '''
import 'package:flutter_bloc/flutter_bloc.dart';

class MyCubit extends Cubit<int> {
  MyCubit() : super(0);

  bool isClosedCalculator() => isClosed;

  Future<void> foo() async {
    if (!isClosedCalculator()) {
      emit(1);
      ^^^^
    }
  }
}
''',
    );

    lintTest(
      'does not report when emit is called in sync method',
      rule: AvoidAsyncEmit.new,
      path: 'my_cubit.dart',
      content: '''
import 'package:flutter_bloc/flutter_bloc.dart';

class MyCubit extends Cubit<int> {
  MyCubit() : super(0);

  void loadData() {
    emit(5);
  }
}
''',
    );

    lintTest(
      // ignore: lines_longer_than_80_chars
      'does not report when emit is guarded by if (!isClosed) with await before',
      rule: AvoidAsyncEmit.new,
      path: 'my_cubit.dart',
      content: '''
import 'package:flutter_bloc/flutter_bloc.dart';

class MyCubit extends Cubit<int> {
  MyCubit() : super(0);

  Future<void> loadData() async {
    final data = await Future.value(42);
    if (!isClosed) {
      emit(data);
    }
  }
}
''',
    );

    lintTest(
      'does not report when emit is guarded by if (isClosed){ return; }',
      rule: AvoidAsyncEmit.new,
      path: 'my_cubit.dart',
      content: '''
import 'package:flutter_bloc/flutter_bloc.dart';

class MyCubit extends Cubit<int> {
  MyCubit() : super(0);

  Future<void> loadData() async {
    final data = await Future.value(42);
    if (isClosed) {
        return;
    }
    emit(data);
  }
}
''',
    );

    lintTest(
      // ignore: lines_longer_than_80_chars
      'does not report when emit is guarded by if (isClosed == false) {return;}',
      rule: AvoidAsyncEmit.new,
      path: 'my_cubit.dart',
      content: '''
import 'package:flutter_bloc/flutter_bloc.dart';

class MyCubit extends Cubit<int> {
  MyCubit() : super(0);

  Future<void> loadData() async {
    final data = await Future.value(42);
    if (isClosed == false) {
        return;
    }
    emit(data);
  }
}
''',
    );

    lintTest(
      'reports when emit is not guarded in async method',
      rule: AvoidAsyncEmit.new,
      path: 'my_cubit.dart',
      content: '''
import 'package:flutter_bloc/flutter_bloc.dart';

class MyCubit extends Cubit<int> {
  MyCubit() : super(0);

  Future<void> loadData() async {
    final data = await Future.value(42);
  
    emit(data);
    ^^^^
  }
}
''',
    );

    lintTest(
      'reports when await is before emit in if (!isClosed) block',
      rule: AvoidAsyncEmit.new,
      path: 'my_cubit.dart',
      content: '''
import 'package:flutter_bloc/flutter_bloc.dart';

class MyCubit extends Cubit<int> {
  MyCubit() : super(0);

  Future<void> loadData() async {
    int data = await Future.value(42);
    if (!isClosed) {
        data = await Future.value(52);
        emit(data);      
        ^^^^
    }
  }
}
''',
    );

    lintTest(
      'reports when emit is outside if (!isClosed) block',
      rule: AvoidAsyncEmit.new,
      path: 'my_cubit.dart',
      content: '''
import 'package:flutter_bloc/flutter_bloc.dart';

class MyCubit extends Cubit<int> {
  MyCubit() : super(0);

  Future<void> loadData() async {
    int data = await Future.value(42);
    if(!isClosed) {
        print('sike');
    }
    emit(data);
    ^^^^
  }
}
''',
    );

    lintTest(
      'reports when guard is a complex expression',
      rule: AvoidAsyncEmit.new,
      path: 'my_cubit.dart',
      content: '''
import 'package:flutter_bloc/flutter_bloc.dart';

class MyCubit extends Cubit<int> {
  MyCubit() : super(0);
    
  Future<void> loadData() async {
    int data = await Future.value(42);
    if(!isClosed && state == 15) {
      emit(data);
      ^^^^
    }
  }
}
''',
    );

    lintTest(
      'reports when guard is a function call',
      rule: AvoidAsyncEmit.new,
      path: 'my_cubit.dart',
      content: '''
import 'package:flutter_bloc/flutter_bloc.dart';

class MyCubit extends Cubit<int> {
  MyCubit() : super(0);

  bool isClosedCalculator() => isClosed;
    
  Future<void> loadData() async {
    int data = await Future.value(42);
    if(!isClosedCalculator()) {
      emit(data);
      ^^^^
    }
  }
}
''',
    );

    lintTest(
      'reports when guard is a variable comparison',
      rule: AvoidAsyncEmit.new,
      path: 'my_cubit.dart',
      content: '''
import 'package:flutter_bloc/flutter_bloc.dart';

class MyCubit extends Cubit<int> {
  MyCubit() : super(0);


  final bool x = true;
    
  Future<void> loadData() async {
    int data = await Future.value(42);
    if(isClosed == x) {
      return;
    }
    emit(data);
    ^^^^
  }
}
''',
    );

    lintTest(
      'does not report when emit is guarded by if (!isClosed) in Bloc',
      rule: AvoidAsyncEmit.new,
      path: 'my_bloc.dart',
      content: '''
import 'package:flutter_bloc/flutter_bloc.dart';

class MyBloc extends Bloc<int, int> {
  MyBloc() : super(0);

  @override
  Stream<int> mapEventToState(int event) async* {
    if (!isClosed) emit(1);
  }
}
''',
    );

    lintTest(
      'reports when emit is not guarded in async method in Bloc',
      rule: AvoidAsyncEmit.new,
      path: 'my_bloc.dart',
      content: '''
import 'package:flutter_bloc/flutter_bloc.dart';

class MyBloc extends Bloc<int, int> {
  MyBloc() : super(0);

  @override
  Stream<int> mapEventToState(int event) async* {
    await Future.value(42);
    emit(1);
    ^^^^
  }
}
''',
    );

    lintTest(
      'does not report when emit is called in sync method in Bloc',
      rule: AvoidAsyncEmit.new,
      path: 'my_bloc.dart',
      content: '''
import 'package:flutter_bloc/flutter_bloc.dart';

class MyBloc extends Bloc<int, int> {
  MyBloc() : super(0);

  @override
  Stream<int> mapEventToState(int event) sync* {
    emit(1);
  }
}
''',
    );
  });

  lintTest(
    'does not report when emit is guarded by if (isClosed) return;',
    rule: AvoidAsyncEmit.new,
    path: 'my_cubit.dart',
    content: '''
import 'package:flutter_bloc/flutter_bloc.dart';

class MyCubit extends Cubit<int> {
  MyCubit() : super(0);

  Future<void> foo() async {
    await Future.value(1);
    if (isClosed) return;
    emit(1);
  }
}
''',
  );

  lintTest(
    'does not report when emit is guarded by if (isClosed == false) return;',
    rule: AvoidAsyncEmit.new,
    path: 'my_cubit.dart',
    content: '''
import 'package:flutter_bloc/flutter_bloc.dart';

class MyCubit extends Cubit<int> {
  MyCubit() : super(0);

  Future<void> foo() async {
    await Future.value(1);
    if (isClosed == false) return;
    emit(1);
  }
}
''',
  );
}
