<p align="center">
<img src="https://raw.githubusercontent.com/felangel/bloc/master/docs/assets/bloc_logo_full.png" height="100" alt="Bloc" />
</p>

<p align="center">
<a href="https://github.com/felangel/bloc/actions"><img src="https://img.shields.io/github/workflow/status/felangel/bloc/build.svg?logo=github" alt="build"></a>
<a href="https://codecov.io/gh/felangel/bloc"><img src="https://codecov.io/gh/felangel/Bloc/branch/master/graph/badge.svg" alt="codecov"></a>
<a href="https://github.com/felangel/bloc"><img src="https://img.shields.io/github/stars/felangel/bloc.svg?style=flat&logo=github&colorB=deeppink&label=stars" alt="Star on Github"></a>
<a href="https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc"><img src="https://vsmarketplacebadge.apphb.com/version-short/FelixAngelov.bloc.svg" alt="Version"></a>
<a href="https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc"><img src="https://vsmarketplacebadge.apphb.com/installs-short/FelixAngelov.bloc.svg" alt="Installs"></a>
<a href="https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc"><img src="https://vsmarketplacebadge.apphb.com/rating-short/FelixAngelov.bloc.svg" alt="Ratings"></a>
<a href="https://flutter.dev/docs/development/data-and-backend/state-mgmt/options#bloc--rx"><img src="https://img.shields.io/badge/flutter-website-deepskyblue.svg" alt="Flutter Website"></a>
<a href="https://github.com/Solido/awesome-flutter#standard"><img src="https://img.shields.io/badge/awesome-flutter-blue.svg?longCache=true" alt="Awesome Flutter"></a>
<a href="http://fluttersamples.com"><img src="https://img.shields.io/badge/flutter-samples-teal.svg?longCache=true" alt="Flutter Samples"></a>
<a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-purple.svg" alt="License: MIT"></a>
<a href="https://discord.gg/bloc"><img src="https://img.shields.io/discord/649708778631200778.svg?logo=discord&color=blue" alt="Discord"></a>
<a href="https://github.com/felangel/bloc"><img src="https://tinyurl.com/bloc-library" alt="Bloc Library"></a>
</p>

---

## نمای کلی

محیط [VSCode](https://code.visualstudio.com/) از [کتابخانه Bloc](https://bloclibrary.dev) پشتیبانی می کند و ابزارهایی را برای ایجاد مؤثر [Bloc ها](https://github.com/felangel/bloc) و [Cubits ها](https://github.com/felangel/cubit) برای هر دو برنامه [فلاتر](https://flutter.dev/) و [انگولار دارت](https://angulardart.dev/) فراهم می کند.

## نصب

افزونه Bloc را می توان از [بازارچه (Marketplace) VSCode](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc) یا با [جستجو در VSCode](https://code.visualstudio.com/docs/editor/extension-gallery#_search-for-an-extension) نصب کرد.

## فرمان ها

| فرمان            | توضیحات          |
| ------------------ | -------------------- |
| `Bloc: New Bloc`   | ایجاد یک Bloc جدید  |
| `Cubit: New Cubit` | ایجاد یک Cubit جدید |

می توانید فرمان ها یا دستورات را با اجرای پالت دستور (View -> Command Palette) و اجرای نام دستور فعال کنید، یا می توانید روی دایرکتوری که می خواهید Bloc/Cubit را در آن ایجاد کنید، راست کلیک کرده و دستور را از منوی میانبر انتخاب کنید.

![demo](https://raw.githubusercontent.com/felangel/bloc/master/extensions/vscode/assets/new-bloc-usage.gif)

## عملیات کد (Code Actions)

| Action                         | Description                                    |
| ------------------------------ | ---------------------------------------------- |
| `Wrap with BlocBuilder`        | ویجت فعلی را درون یک `BlocBuilder` قرار میدهد        |
| `Wrap with BlocListener`       | ویجت فعلی را درون یک `BlocListener` قرار میدهد       |
| `Wrap with BlocConsumer`       | ویجت فعلی را درون یک `BlocConsumer` قرار میدهد       |
| `Wrap with BlocProvider`       | ویجت فعلی را درون یک `BlocProvider` قرار میدهد       |
| `Wrap with RepositoryProvider` | ویجت فعلی را درون یک `RepositoryProvider` قرار میدهد |

![demo](https://raw.githubusercontent.com/felangel/bloc/master/extensions/vscode/assets/wrap-with-usage.gif)

## قطعه‌ کدها (Snippets)

### Bloc

| میانبر            | توضیحات                                |
| ------------------- | ------------------------------------------ |
| `bloc`              | ایجاد یک کلاس `Bloc`                     |
| `cubit`             | ایجاد یک کلاس `Cubit`                    |
| `blocobserver`      | ایجاد یک کلاس `BlocObserver`             |
| `blocprovider`      | ایجاد یک ویجت `BlocProvider`            |
| `multiblocprovider` | ایجاد یک ویجت `MultiBlocProvider`       |
| `repoprovider`      | ایجاد یک ویجت `RepositoryProvider`      |
| `multirepoprovider` | ایجاد یک ویجت `MultiRepositoryProvider` |
| `blocbuilder`       | ایجاد یک ویجت `BlocBuilder`             |
| `bloclistener`      | ایجاد یک ویجت `BlocListener`            |
| `multibloclistener` | ایجاد یک ویجت `MultiBlocListener`       |
| `blocconsumer`      | ایجاد یک ویجت `BlocConsumer`            |
| `blocof`            | میانبر برای `BlocProvider.of()`           |
| `repoof`            | میانبر برای `RepositoryProvider.of()`     |
| `read`              | میانبر برای `context.read()`              |
| `watch`             | میانبر برای `context.watch()`             |
| `select`            | میانبر برای `context.select()`            |
| `blocstate`         | ایجاد یک کلاس وضعیت                      |
| `blocevent`         | ایجاد یک کلاس ایونت                     |

### Freezed Bloc

| میانبر     | توضیحات                                                     |
| ------------ | --------------------------------------------------------------- |
| `feventwhen` | ایجاد یک تابع Map Event to State با استفاده از freeze.when |
| `feventmap`  | ایجاد یک تابع Map Event to State با استفاده از freeze.map  |
| `fstate`     | ایجاد یک زیر وضعیت                                             |
| `fevent`     | ایجاد یک زیر رویداد                                             |
