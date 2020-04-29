# Testing

> Bloc test edilməsi çox rahat olacaq şəkildə hazırlanmışdır.

Sadə olması üçün,  [Əsas Konseptlər](coreconcepts.md)-də yaratdığımız `CounterBloc` üçün testlər yazaq.

Təkrar olması üçün qeyd edək ki, `CounterBloc` aşağıdakı kod şəklindədir

[counter_bloc.dart](../_snippets/testing/counter_bloc.dart.md ':include')

Testlərimizi yazmadan öncə dependency-lərə test üçün framework-ləri əlavə edəcəyik.

[test](https://pub.dev/packages/test) və [bloc_test](https://pub.dev/packages/bloc_test) framework-lərini `pubspec.yaml`-a əlavə etməliyik.

[pubspec.yaml](../_snippets/testing/pubspec.yaml.md ':include')

`CounterBloc`-un testi üçün `counter_bloc_test.dart` yaradaraq və test paketini daxil edərək başlayırıq.

[counter_bloc_test.dart](../_snippets/testing/counter_bloc_test_imports.dart.md ':include')

Daha sonra, `main` funksiyasını və test qrupunu yaratmağa ehtiyacımız var.

[counter_bloc_test.dart](../_snippets/testing/counter_bloc_test_main.dart.md ':include')

?> **Qeyd**: Qruplar individual testlərin təşkili üçündür və `setUp` və `tearDown` funksiyalarını istifadə edərək, bütün individual testlər üçün ümumi olan şeyləri yarada bilərik.

Beləliklə, bütün testlərimizdə istifadə olunacaq `CounterBloc` obyektini yaradırıq.

[counter_bloc_test.dart](../_snippets/testing/counter_bloc_test_setup.dart.md ':include')

İndi individual testlərimizi yazmağa başlaya bilərik.

[counter_bloc_test.dart](../_snippets/testing/counter_bloc_test_initial_state.dart.md ':include')

?> **Qeyd**: Bütün testlərimizi `pub run test` əmri ilə işlədə bilərik.

Artıq bu nöqtədə bizim ilk düzgün olan testimiz oldu. İndi isə [bloc_test](https://pub.dev/packages/bloc_test) paketini istifadə edərək, daha mürəkkəb test yazaq.

[counter_bloc_test.dart](../_snippets/testing/counter_bloc_test_bloc_test.dart.md ':include')

Testləri işlədib, hamısının keçdiyini görməliyik.

Test üçün hər şey bunlardır, test rahat olmalıdır və dəyişiklik edərkən və kodumuzu yenidən düzəldərkən özümüzü əmin hiss etməliyik.

Tam olaraq bir tətbiqin testi nümunəsini görmək üçün [Todo-lar Tətbiqinə](https://github.com/brianegan/flutter_architecture_samples/tree/master/bloc_) nəzər sala bilərsiniz.
