# دستورالعمل‌ها: نمایش SnackBar با استفاده از BlocListener

> در این دستورالعمل، قصد داریم نحوه استفاده از `BlocListener` برای نمایش یک `SnackBar` به عنوان پاسخ به تغییر وضعیت در یک bloc را مورد بررسی قرار دهیم.

![demo](./assets/gifs/recipes_flutter_snack_bar.gif)

## Bloc

بیایید یک `DataBloc` ابتدایی بسازیم که `DataEvents` را پردازش کرده و `DataStates` را تولید می کند.

### DataEvent

به سادگی، `DataBloc` ما فقط به یک `DataEvent` به نام `FetchData` پاسخ خواهد داد.

[data_event.dart](_snippets/recipes_flutter_show_snack_bar/data_event.dart.md ':include')

### DataState

`DataBloc` ما می‌تواند یکی از سه `DataState` مختلف را داشته باشد:

- `Initial` - وضعیت اولیه قبل از افزودن هرگونه رویدادی اضافه می شوند (`emit` می شوند).
- `Loading` - وضعیت بلوک در حالی که به طور ناهمزمان در حال "fetching data" است.
- `Success` - وضعیت بلوک زمانی که با موفقیت "fetched data" را دریافت کرده است.

[data_state.dart](_snippets/recipes_flutter_show_snack_bar/data_state.dart.md ':include')

### DataBloc

DataBloc ما باید چیزی شبیه به این باشد:

[data_bloc.dart](_snippets/recipes_flutter_show_snack_bar/data_bloc.dart.md ':include')

?> **نکته:** در اینجا از `Future.delayed` برای شبیه‌سازی تاخیر (به مانند زمانی که منتظر است تا داده ها از سرور دریافت شوند) استفاده می‌کنیم.

## لایه رابط کاربری (UI Layer)

حالا بیایید ببینیم چگونه `DataBloc` خود را به یک ویجت متصل کنیم و در پاسخ به یک وضعیت موفق (Success)، یک `SnackBar` نمایش دهیم.

[main.dart](_snippets/recipes_flutter_show_snack_bar/main.dart.md ':include')

?> به منظور **انجام کارها (DO THINGS)** در پاسخ به تغییرات وضعیت در `DataBloc` خود، از ویجت `BlocListener` استفاده می‌کنیم.

?> به منظور **رندر کردن ویجت‌ها (RENDER WIDGETS)** در پاسخ به تغییرات وضعیت در `DataBloc` خود، از ویجت `BlocBuilder` استفاده می‌کنیم.

!> ما **هرگز** "کارهایی (Do things)" را در پاسخ به تغییرات وضعیت در متد `builder` از `BlocBuilder` انجام نمی‌دهیم زیرا این متد ممکن است توسط چارچوب فلاتر بارها فراخوانی شود. متد `builder` باید یک [تابع خالص](https://en.wikipedia.org/wiki/Pure_function) باشد که فقط در پاسخ به وضعیت بلاک، یک ویجت را برگرداند.

منبع کامل این روش را می توانید در [اینجا](https://gist.github.com/felangel/1e5b2c25b263ad1aa7bbed75d8c76c44) بیابید.
