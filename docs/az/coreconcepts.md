# Əsas Konseptlər

?> Zəhmət olmasa, [bloc](https://pub.dev/packages/bloc)-la işləməzdən öncə, aşağıdakı bölmələri diqqətli şəkildə oxuyub, anladığınıza əmin olun.

Bloc istifadə etmək üçün, bir sıra vacib konseptləri anlamaq lazımdır.

Növbəti bölmələrdə, bu əsas konseptlərin hər biri haqqında ətraflı müzakirə aparacaq və onların real tətbiqlərdə necə istifadə olunmasını sayğac tətbiqi ilə görəcəyik.

## Hadisələr (Events)

> Hadisələr Bloc-un girişidir (input). Bunlar, adətən istifadəçinin tətbiq ilə qarşılıqlı əlaqəsinə - hər hansı düyməyə basılmaya, lifecycle hadisələrinə (məsələn səhifənin yüklənməsi) cavab olaraq, Bloc-a əlavə olunur.

Bir tətbiqi tərtib edərkən, əvvəlcə istifadəçinin onu necə istifadə edəcəyini müəyyən etməliyik. Bizim sayğac tətbiqində sayğacı azaltmaq və artırmaq üçün iki düymə olacaq.

İstifadəçi düymələrdən birinə basan zaman, bizim tətbiqimizin beynini (əsas hissəsini) xəbərdar edə bilməliyik və bu xəbərdarlığa əsasən istifadəçiyə cavab verilə bilər; elə buna görə də, bizim hadisələrə (events) ehtiyacımız var.

Sayğac tətbiqimizdə, tətbiqin əsas hissəsini həm artırma, həm də azaltma üçün xəbərdar edə bilməliyik, buna görə də, hadisələri müəyyənləşdirməyə ehtiyacımız var.

```dart
enum CounterEvent { increment, decrement }
```

Bu tətbiqdə, hadisələrimiz sadə olduğu üçün biz `enum` istifadə etdik, amma daha mürəkkəb hallarda, əsasən də bloc-a hər hansı informasiyanı ötürmək lazım olduqda, `class`-dan istifadə etmək lazım gəlir.

Bu nöqtədə, ilk hadisəmizi müəyyən etdik!. Diqqət edin ki, biz indiyə qədər Bloc istifadə etmədik və burada heç bir sehr yoxdur; bu sadəcə Dart kodlarıdır.

## Vəziyyətlər (States)

> Vəziyyətlər Bloc-un çıxışıdır (output) və tətbiqin vəziyyətini göstərir. İstifadəçi interfeysinin komponentləri bu vəziyyətlərə əsasən xəbərdar edilə və cari vəziyyətə uyğun olaraq, özlərinin lazım olan hissələrini yeniləyə bilərlər.

Beləliklə, bizim tətbiqin cavab verəcəyi iki hadisəni - `CounterEvent.increment` və `CounterEvent.decrement`-i müəyyən etdik.

İndi isə, biz tətbiqimizin vəziyyətini necə nümayiş etdirəcəyimizi müəyyən etməliyik.

Biz, sayğac düzəltdiyimiz üçün, vəziyyət (state) sadədir: bu sayğacın cari qiymətini göstərən tam ədəddir (integer).

Biz daha mürəkkəb nümunələr görəcəyik, amma bu halda, primitiv tip, tətbiqin vəziyyətini göstərmək üçün uyğundur.

## Keçidlər (Transitions)

> Bir vəziyyətdən digərinə dəyişmə keçid (transition) adlanır. Keçid (Transition) cari vəziyyətdən, hadisədən və növbəti vəziyyətdən ibarətdir.

İstifadəçi sayğac tətbiqini işlədən zaman, `İncrement` və `Decrement` hadisələri ilə bloc-u tətikləyəcək və buna uyğun olaraq, bloc sayğacın vəziyyətini yeniləyəcək. Bütün vəziyyət dəyişiklikləri `Keçidlər (Transitions)`-in ardıcıllığı kimi göstərilə bilər.

Məsələn, əgər istifadəçi tətbiqin açaraq, artırma (increment) düyməsinə basarsa, biz aşağıdakı `Keçid (Transition)`-i görəcəyik.

```json
{
  "currentState": 0,
  "event": "CounterEvent.increment",
  "nextState": 1
}
```

Bütün vəziyyət dəyişikliyi yadda saxlanıldığı üçün, tətbiqlərimizi çox rahat şəkildə istifadə edə və istifadəçinin tətbiqlə bütün qarşılıqlı əlaqələrini və vəziyyət dəyişikliklərini bir yerdən izləyə bilərik.

## Stream-lər (Streams)

?> `Streamlər` haqqında daha çox məlumat almaq üçün rəsmi [Dart Dokumentasiyasını](https://dart.dev/tutorials/language/streams) yoxlayın.

> Stream asinxron dataların ardıcıllığıdır.

Bloc [RxDart](https://pub.dev/packages/rxdart) kitabxanası üzərində qurulub; buna baxmayaraq, `RxDart`-ın həyata keçirilməsi üçün spesifik olan hər şeyi mücərrədləşdirir.

Bloc-u istifadə etmək üçün, `Streamlər`-i və onların necə işləməsini anlamaq vacibdir.

> Əgər siz `Streamlər` ilə tanış deyilsinizsə, bunu bir borudan axan su kimi təsəvvür edin. Bu boru `Stream`-dir və su isə asinxron datadır.

Dart dilində, `Stream`-ləri `async*` funksiya yazaraq, yarada bilərik.

```dart
Stream<int> countStream(int max) async* {
    for (int i = 0; i < max; i++) {
        yield i;
    }
}
```

Funksiyanı `async*` kimi yaradaraq, biz `yield` açarsözündən istifadə edə bilərik və bu əmr vasitəsilə funksiyadan `Stream` datasını geri qaytara bilərik. Yuxarıdakı nümunəyə əsasən, 0-dan başlayaraq, `max` adı ilə verilmiş parametr-ə qədər olan bütün tam ədədləri `Stream` kimi geri qaytarırıq.

Hər dəfə `yield` əmrini `async*` funksiyada istifadə edərkən, datanın bu hissəsini `Stream`-ə daxil etmiş oluruq. 

Yuxarıdakı `Stream`-i bir neçə şəkildə bitirə bilərik. Əgər, tam ədədlərin `Stream`-in cəmini geri qaytaran funksiya yazmaq istəyiriksə. bu belə ola bilər:

```dart
Future<int> sumStream(Stream<int> stream) async {
    int sum = 0;
    await for (int value in stream) {
        sum += value;
    }
    return sum;
}
```

Yuxarıdakı funksiyanı `async` ilə işarə edərək, `await` açar sözünü istifadə edə və geriyə tam ədədlərin `Future`-ni qaytara bildik. Bu nümunədə, stream-dən gələcək olan bütün qiymətləri gözləyir və sonda bu tam ədədlərin cəmini geri qaytarırıq. 

Bunların hamısını aşağıdakı şəkildə birləşdirə bilərik:

```dart
void main() async {
    /// Initialize a stream of integers 0-9
    Stream<int> stream = countStream(10);
    /// Compute the sum of the stream of integers
    int sum = await sumStream(stream);
    /// Print the sum
    print(sum); // 45
}
```

## Bloclar (Blocs)

>  Bloc (**B**usiness **Lo**gic **C**omponent) Bloc tərəfindən qəbul edilən `Hadisələr (Events)`-in `Stream`-i, `Vəziyyətlər (States)`-in `Stream`-nə çevirən komponentdir. Yuxarıda da qeyd edildiyi kimi, Bloc-u beyin kimi təsəvvür edin.

> Hər bir Bloc əsas bloc paketinin bir hissəsi olan `Bloc` class-ını miras almalıdır (İnheritance, extend etməlidir).

```dart
import 'package:bloc/bloc.dart';

class CounterBloc extends Bloc<CounterEvent, int> {

}
```

Yuxarıdakı kod parçasında, `CounterBloc`-u `CounterEvent`-ləri `int`-lərə çevirən Bloc kimi elan etdik. (Burada, CounterEvent hadisə, int isə vəziyyətdir).

> Hər bir Bloc başlanğıc vəziyyəti müəyyən etməlidir, bu hər hansı event qəbul edilməmişdən qabaq lazım olan ilkin vəziyyətdir.

Bu nümunədə, sayğacın `0`-dan başlamasını istəyirik, deməli başlanğıc vəziyyətini 0 elan edəcəyik.

```dart
@override
int get initialState => 0;
```

> Hər bir Bloc `mapEventToState` adlı funksiyanı işlətməlidir. Bu funksiya `event`-i arqument kimi qəbul edir və geriyə mütləq dizayn hissəsi tərəfindən istifadə olunan yeni `vəziyyətlər`-in `Stream`-ni qaytarmalıdır. İstədiyim vaxt cari bloc-un vəziyyətini `state` özəlliyi ilə əldə edə bilərik.

```dart
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
```

Bu nöqtədə, biz `CounterBloc`-u tam funksional etmiş olduq.

```dart
import 'package:bloc/bloc.dart';

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

!> Bloc təkrar vəziyyətləri ləğv edir. Əgər Bloc-un yield etdiyi `State nextState` özəlliyi `state == nextState` olarsa, heç bir keçid (transition) baş verməyəcək və `Stream<State>`-də heç bir dəyişiklik olmayacaq.

Bu nöqtədə, yəqin ki, təəccüblənirsiniz ki, _"Hadisə zamanı Bloc-u necə xəbərdar edəcəm?"_.

> Hər bir Bloc-un `add` adlı metodu vardır. `Add` `hadisə (event)`-ni qəbul edir və bu hadisəyə əsasən, `mapEventToState` metodunu tətikləyir. `Add` dizayn kodları olan hissədən və ya Bloc-un özündə çağrıla və yeni `hadisə (event)`-yə əsasən Bloc-a xəbər verə bilər. 

Bz 0-dan 3-ə qədər sayan sadə tətbiq yarada bilərik.

```dart
void main() {
    CounterBloc bloc = CounterBloc();

    for (int i = 0; i < 3; i++) {
        bloc.add(CounterEvent.increment);
    }
}
```

!> Susmaya görə, hadisələr həmişə ardıcıllıqla işləyəcək, yəni ki, yeni əlavə olunan hadisələr əvvəlki hadisələri gözləyəcəkdir. `mapEventToState` metodu öz işini bitirdikdə, hadisə də tam işləmiş sayılır.

Yuxarıdakı kod parçasına əsasən, keçidlər aşağıdakı kimi olacaq:

```json
{
    "currentState": 0,
    "event": "CounterEvent.increment",
    "nextState": 1
}
{
    "currentState": 1,
    "event": "CounterEvent.increment",
    "nextState": 2
}
{
    "currentState": 2,
    "event": "CounterEvent.increment",
    "nextState": 3
}
```

Təəssüf ki, `onTransition` metodunu Bloc-umuzda istifadə etmədən, bu keçidlərin heç birini görə bilməyəcəyik.

> `onTransition`Bloc daxilində olan `Keçidlər (Transtions)`-i idarə etmək üçün istifadə olunan metoddur. `onTransition` Bloc-un `vəziyyət (state)`-i yenilmədən öncə çağırılır.

?> **İpucu**: `onTransition` bloc-a xas olan loglama/analitika üçün ideal yerdir.

```dart
@override
void onTransition(Transition<CounterEvent, int> transition) {
    print(transition);
}
```

Hal-hazırda, `onTransition` metodunu Bloc-a daxil etdik və bu halda, yeni `Keçid (Transition)` baş verərkən istədiyimiz prosesi icra edə bilərik.

`Keçidlər (Transitions)`-i bloc səviyyəsində idarə edə bildiyimiz kimi, `Exception`-ları da idarə edə bilərik.

> `onError` metodu Bloc daxilində olan `Exception`-ı idarə etmək üçün, istifadə olunan metoddur. Susmaya görə, bütün exceptionlar ləğv olunur və `Bloc`-un funksionallığına heç bir təsir olmur.

?> **Qeyd**: Əgər vəziyyət stream-i error-u `StackTrace` olmadan qəbul edərsə, stacktrace arqumenti `null` ola bilər. 

?> **Tip**: `onError` metodu bloc-a xas olan error-ları idarə etmək üçün, ideal yerdir.

```dart
@override
void onError(Object error, StackTrace stackTrace) {
  print('$error, $stackTrace');
}
```

Hal-hazırda, `onError` metodunu Bloc-a daxil etdik və `Exception` baş verərkən, istədiyimiz prosesi burada icra edə bilərik.

## BlocDelegate

Bloc istifadə etməyin üstünlüklərindən biri budur ki, biz bütün Bloc-larda olan `Keçidlər (Transitions)`-i bir yerdən əldə edə bilərik. Bu nümunədə, bir Bloc olmasına baxmayaraq, böyük tətbiqlərdə müxtəlif hissələrdə tətbiqin vəziyyətini idarə etmək üçün çoxlu Bloc olması gözləniləndir.

Əgər bütün `Keçidlər (Transitions)`-ə cavab olaraq, nəsə etmək istəyiriksə. sadəcə özümüzün `BlocDelegate`-ni yarada bilərik.

```dart
class SimpleBlocDelegate extends BlocDelegate {
  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print(transition);
  }
}
```

?> **Qeyd**: Ehtiyacımız olan, `BlocDelegate` classını extend etmək və `onTransition` metodunu daxil etməkdir.

. Bloc-a bizim `SimpleBlocDelegate`-i istifadə etməsini demək üçün, sadəcə `main` funksiyasında bunu qeyd etməyimiz lazımdır. 

```dart
void main() {
  BlocSupervisor.delegate = SimpleBlocDelegate();
  CounterBloc bloc = CounterBloc();

  for (int i = 0; i < 3; i++) {
    bloc.add(CounterEvent.increment);
  }
}
```

Əgər bütün `Hadisələr (Events)`-ə cavab olaraq, nəsə etmək istəyiriksə, `onEvent` metodunu `SimpleBlocDelegate`-ə əlavə edə bilərik.

```dart
class SimpleBlocDelegate extends BlocDelegate {
  @override
  void onEvent(Bloc bloc, Object event) {
    super.onEvent(bloc, event);
    print(event);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print(transition);
  }
}
```

Əgər bütün `Exception`-lara cavab olaraq, nəsə etmək istəyiriksə, `onError` metodunu `SimpleBlocDelegate`-ə əlavə edə bilərik..

```dart
class SimpleBlocDelegate extends BlocDelegate {
  @override
  void onEvent(Bloc bloc, Object event) {
    super.onEvent(bloc, event);
    print(event);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print(transition);
  }

  @override
  void onError(Bloc bloc, Object error, StackTrace stacktrace) {
    super.onError(bloc, error, stacktrace);
    print('$error, $stacktrace');
  }
}
```

?> **Qeyd**: `BlocSupervisor` bütün Bloclara nəzarət edən və onların vəzifələrini `BlocDelegate`-ə ötürən singleton classdır .
