# قراردادهای نامگذاری

!> قراردادهای نامگذاری زیر صرفاً توصیه شده و کاملاً اختیاری هستند. با خیال راحت از هر گونه قرارداد نامگذاری که ترجیح می دهید استفاده کنید. ممکن است دریابید که برخی از مثال‌ها/اسناد اصولاً به دلیل سادگی/مختصر بودن از قراردادهای نام‌گذاری پیروی نمی‌کنند. این قرارداد ها به شدت برای پروژه های بزرگ با توسعه دهندگان متعدد توصیه می شود.

## قراردادهای کلاس رویداد

> رویدادها باید با **گذشته ساده** نامگذاری شوند، زیرا رویدادها چیزهایی هستند که از دیدگاه Bloc قبلاً اتفاق افتاده اند.

### ساختار

[event](_snippets/bloc_naming_conventions/event_anatomy.md ':include')

?> رویدادهای لود اولیه باید این قرارداد را دنبال کنند: `BlocSubject` + `Started`

!> کلاس های رویداد پایه باید این نامگذاری را داشته باشند: `BlocSubject` + `Event`.

#### مثال ها

✅ **خوب**

[events_good](_snippets/bloc_naming_conventions/event_examples_good.md ':include')

❌ **بد**

[events_bad](_snippets/bloc_naming_conventions/event_examples_bad.md ':include')

## قراردادهای کلاس وضعیت

> وضعیت‌ها باید اسم باشند، چرا که یک وضعیت فقط یک لحظه‌ی خاص در زمان را نمایان می‌کند. دو روش رایج برای نمایش وضعیت وجود دارد: استفاده از زیرکلاس‌ها(Subclasses) یا استفاده از یک کلاس تکی(Single class).

### ساختار

#### زیرکلاس‌ها

[state](_snippets/bloc_naming_conventions/state_anatomy.md ':include')

?> هنگام نمایش وضعیت به عنوان چندین زیرکلاس، `State` باید یکی از موارد زیر را دارا باشد: `Initial` | `Success` | `Failure` | `InProgress` و وضعیت‌های اولیه باید طبق این قرار داد عمل کنند: `BlocSubject` + `Initial`.

#### کلاس تکی

[state](_snippets/bloc_naming_conventions/single_state_anatomy.md ':include')

?> هنگام نمایش وضعیت به عنوان یک کلاس پایه تکی، باید از یک enum با نام `BlocSubject` + `Status` برای نمایش وضعیت‌های مختلف استفاده شود: `initial` | `success` | `failure` | `loading`.

!> کلاس وضعیت پایه همیشه باید به این روش نام گذاری شوند: `BlocSubject` + `State`.

#### مثال ها

✅ **خوب**

##### زیرکلاس‌ها

[states_good](_snippets/bloc_naming_conventions/state_examples_good.md ':include')

##### کلاس تکی

[states_good](_snippets/bloc_naming_conventions/single_state_examples_good.md ':include')

❌ **بد**

[states_bad](_snippets/bloc_naming_conventions/state_examples_bad.md ':include')
