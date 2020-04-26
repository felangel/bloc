# Testing

> Bloc test edilməsi çox rahat olacaq şəkildə hazırlanmışdır.

Sadə olması üçün,  [Əsas Konseptlər](coreconcepts.md)-də yaratdığımız `CounterBloc` üçün testlər yazaq.

Təkrar olması üçün qeyd edək ki, `CounterBloc` aşağıdakı kod şəklindədir

<<<<<<< HEAD
```dart
enum CounterEvent { increment, decrement }

class CounterBloc extends Bloc<CounterEvent, int> {
  @override
  int get initialState => 0;

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    switch (event) {
      case CounterEvent.decrement:
        yield state - 1;
        break;
      case CounterEvent.increment:
        yield state + 1;
        break;
    }
  }
}
```
=======
[counter_bloc.dart](../_snippets/testing/counter_bloc.dart.md ':include')
>>>>>>> 778ca2b88b802862318dfe4655b8a82c89eff719

Testlərimizi yazmadan öncə dependency-lərə test üçün framework-ləri əlavə edəcəyik.

[test](https://pub.dev/packages/test) və [bloc_test](https://pub.dev/packages/bloc_test) framework-lərini `pubspec.yaml`-a əlavə etməliyik.

<<<<<<< HEAD
```yaml
dev_dependencies:
  test: ^1.3.0
  bloc_test: ^3.0.0
```
`CounterBloc`-un testi üçün `counter_bloc_test.dart` yaradaraq və test paketini daxil edərək başlayırıq.

```dart
import 'package:test/test.dart';
import 'package:bloc_test/bloc_test.dart';
```

Daha sonra, `main` funksiyasını və test qrupunu yaratmağa ehtiyacımız var.

```dart
void main() {
    group('CounterBloc', () {

    });
}
```
=======
[pubspec.yaml](../_snippets/testing/pubspec.yaml.md ':include')

`CounterBloc`-un testi üçün `counter_bloc_test.dart` yaradaraq və test paketini daxil edərək başlayırıq.

[counter_bloc_test.dart](../_snippets/testing/counter_bloc_test_imports.dart.md ':include')

Daha sonra, `main` funksiyasını və test qrupunu yaratmağa ehtiyacımız var.

[counter_bloc_test.dart](../_snippets/testing/counter_bloc_test_main.dart.md ':include')
>>>>>>> 778ca2b88b802862318dfe4655b8a82c89eff719

?> **Qeyd**: Qruplar individual testlərin təşkili üçündür və `setUp` və `tearDown` funksiyalarını istifadə edərək, bütün individual testlər üçün ümumi olan şeyləri yarada bilərik.

Beləliklə, bütün testlərimizdə istifadə olunacaq `CounterBloc` obyektini yaradırıq.

<<<<<<< HEAD
```dart
group('CounterBloc', () {
    CounterBloc counterBloc;

    setUp(() {
        counterBloc = CounterBloc();
    });
});
```

İndi individual testlərimizi yazmağa başlaya bilərik.

```dart
group('CounterBloc', () {
    CounterBloc counterBloc;

    setUp(() {
        counterBloc = CounterBloc();
    });

    test('initial state is 0', () {
        expect(counterBloc.initialState, 0);
    });
});
```
=======
[counter_bloc_test.dart](../_snippets/testing/counter_bloc_test_setup.dart.md ':include')

İndi individual testlərimizi yazmağa başlaya bilərik.

[counter_bloc_test.dart](../_snippets/testing/counter_bloc_test_initial_state.dart.md ':include')
>>>>>>> 778ca2b88b802862318dfe4655b8a82c89eff719

?> **Qeyd**: Bütün testlərimizi `pub run test` əmri ilə işlədə bilərik.

Artıq bu nöqtədə bizim ilk düzgün olan testimiz oldu. İndi isə [bloc_test](https://pub.dev/packages/bloc_test) paketini istifadə edərək, daha mürəkkəb test yazaq.

<<<<<<< HEAD
```dart
blocTest(
    'emits [0, 1] when CounterEvent.increment is added',
    build: () => counterBloc,
    act: (bloc) => bloc.add(CounterEvent.increment),
    expect: [0, 1],
);

blocTest(
    'emits [0, -1] when CounterEvent.decrement is added',
    build: () => counterBloc,
    act: (bloc) => bloc.add(CounterEvent.decrement),
    expect: [0, -1],
);
```
=======
[counter_bloc_test.dart](../_snippets/testing/counter_bloc_test_bloc_test.dart.md ':include')
>>>>>>> 778ca2b88b802862318dfe4655b8a82c89eff719

Testləri işlədib, hamısının keçdiyini görməliyik.

Test üçün hər şey bunlardır, test rahat olmalıdır və dəyişiklik edərkən və kodumuzu yenidən düzəldərkən özümüzü əmin hiss etməliyik.

Tam olaraq bir tətbiqin testi nümunəsini görmək üçün [Todo-lar Tətbiqinə](https://github.com/brianegan/flutter_architecture_samples/tree/master/bloc_) nəzər sala bilərsiniz.
