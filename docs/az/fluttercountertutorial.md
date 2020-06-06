# Flutter Sayğac dərsi

![beginner](https://img.shields.io/badge/level-beginner-green.svg)

> Sıradakı dərsdə, Bloc kitabxanasını istifadə edərək, Flutter-də Sayğac düzəldəcəyik.

![demo](../assets/gifs/flutter_counter.gif)

## Quraşdırma

Yeni Flutter proyekti yaradaraq başlayacağıq.

[script](../_snippets/flutter_counter_tutorial/flutter_create.sh.md ':include')

Daha sonra `pubspec.yaml`-dakı kontentləri aşağıdakı kimi əvəzləyirik

[pubspec.yaml](../_snippets/flutter_counter_tutorial/pubspec.yaml.md ':include')

və dependency-lərimizi quraşdırırıq

[script](../_snippets/flutter_counter_tutorial/flutter_packages_get.sh.md ':include')

Sayğac tətbiqimiz sadəcə sayğacın qiymətini azaltmaq/artırmaq üçün 2 düymədən və sayğacın cari qiymətini göstərmək üçün `Text` widget-indən ibarət olacaq. `CounterEvent`-ləri yaratmağa başlayaq.

## Counter Events (Counter Hadisələri)

[counter_event.dart](../_snippets/flutter_counter_tutorial/counter_event.dart.md ':include')

## Counter States (Counter Vəziyyətləri)

Sate-imiz sadəcə integer (tam ədəd) olduğu üçün, əlavə class yaratmağa ehtiyac yoxdur!

## Counter Bloc

[counter_bloc.dart](../_snippets/flutter_counter_tutorial/counter_bloc.dart.md ':include')

?> **Qeyd**: `CounterBloc` elanından görə bilərik ki, `CounterEvent`-lər input kimi və integer-lər isə output kimi istifadə ediləcək.

## Sayğac Tətbiqi

Now that we have our `CounterBloc` fully implemented, we can get started creating our Flutter application.
Artıq bizim tam yaradılmış `CounterBloc` var, artıq Flutter tətbiqini yaratmağa başlaya bilərik.

[main.dart](../_snippets/flutter_counter_tutorial/main.dart.md ':include')

?> **Qeyd**: `CounterBloc` obyektinin bütün subtree üzrə (`CounterPage`) əlçatan olması üçün `flutter_bloc` içərisində olan `BlocProvider` istifadə edirik. `BlocProvider` həmçinin `CounterBloc`-ın avtomatik bağlanmasını təmin edir, `StatefulWidget` istifadə etməyə ehtiyac yoxdur.

## Sayğac səhifəsi

Sonda, sadəcə Sayğac səhifəsini yaratmaq qaldı.

[counter_page.dart](../_snippets/flutter_counter_tutorial/counter_page.dart.md ':include')

?> **Qeyd**: `BlocProvider.of<CounterBloc>(context)` istifadə edərək, `CounterBloc` obyektini `CounterPage`-i əhatə edən `BlocProvider` sayəsində əldə edə bilirik.

?> **Qeyd**: İstifadəçi interfeysini vəziyyət dəyişikliklərinə uyğun olaraq (sayğac qiymətində olan dəyişikliklər) yeniləmək üçün `flutter_bloc` içərisində olan `BlocBuilder` istifadə edirik.

?> **Qeyd**: `BlocBuilder` ötürülə bilən `bloc` parametri qəbul edir, amma biz bloc-un tipini və vəziyyətin tipini qeyd edərək `BlocBuilder`-in lazım olan bloc-u tapmasını təmin də bilərik, beləliklə bizim açıq şəkildə `BlocProvider.of<CounterBloc>(context)` yazmağımıza ehtiyac yoxdur.

!> Əgər bu bloc yalnız bir widget üçün keçərlidir və `BlocProvider` və cari `BuilderContext` ilə əldə etmək mümkün deyilsə,`BlocBuilder`-də bloc-u yalnız o zaman aşkar şəkildə əlavə edin.

Bu qədər! Biz presentation (dizayn) təbəqəsini business logic (məntiq kodu) hissədən ayırdıq. `CounterPage` səhifəsinin düyməyə basan zaman nə baş verdiyi haqqında heç bir məlumatı yoxdur; bu sadəcə hadisəni (event) `CounterBloc`-u xəbərdar etmək üçün əlavə edir. Beləliklə, `CounterBloc` hissəsinin vəziyyət dəyişən zaman dizaynda nə baş verdiyi haqqında heç bir məlumatı, ideyası yoxdur; bu sadəcə `CounterEvent`-ləri integer-ə (tam ədədə) çevirir.

Biz tətbiqimizi `flutter run` əmri vasitəsi ilə başlada və cihazımızda və ya simulator/emulator-da görə bilərik.

Bu nümunənin tam kodu [buradan](https://github.com/felangel/Bloc/tree/master/packages/flutter_bloc/example) əldə oluna bilər.
