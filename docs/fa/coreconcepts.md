# مفاهیم اصلی (پکیج :bloc)

?> لطفاً قبل از کار با [package:bloc](https://pub.dev/packages/bloc) حتماً بخش‌های زیر را به دقت بخوانید.

چندین مفهوم اصلی وجود دارد که برای درک نحوه استفاده از بسته Bloc حیاتی است.

در بخش‌های جلوتر، می‌خواهیم هر یک از آنها را با جزئیات کامل مورد بحث قرار دهیم و همچنین نحوه اعمال آنها در یک برنامه شمارنده را بررسی کنیم.

## جریان‌ها (Streams)

?> برای اطلاعات بیشتر در مورد `جریان ها`، [داکیومنت رسمی دارت](https://dart.dev/tutorials/language/streams) را بررسی کنید.

> جریان مجموعه ای از داده های ناهمزمان است.

برای استفاده از کتابخانه Bloc، داشتن درک اولیه از `جریان‌ها` و نحوه کار آنها بسیار مهم است.

> اگر با جریان ها آشنا نیستید، کافی است به لوله‌ای فکر کنید که آب در آن جریان دارد. لوله، جریان (`Stream`) و آب، داده ناهمزمان (Asynchronous data) است.

ما می‌توانیم با نوشتن یک تابع `async*` (تولید کننده async) در Dart، یک جریان ایجاد کنیم.

[count_stream.dart](_snippets/core_concepts/count_stream.dart.md ':include')

با مشخص کردن یک تابع به‌عنوان `async*`، می‌توانیم از کلمه کلیدی `yield` استفاده کنیم و یک `Stream` از داده‌ها را برگردانیم. در مثال بالا، ما یک جریانی (`Stream`) از اعداد را تا پارامتر `max` برمی گردانیم.

هر بار که در یک تابع `async*`، عمل `yield` را انجام میدهیم، آن قطعه داده را از طریق `Stream` هل می‌دهیم.

ما می‌توانیم `Stream` فوق را به روش‌های مختلفی استفاده کنیم. اگر بخواهیم تابعی بنویسیم که مجموع یک `Stream` از اعداد را برگرداند، می تواند چیزی شبیه به زیر باشد:

[sum_stream.dart](_snippets/core_concepts/sum_stream.dart.md ':include')

با مشخص کردن تابع فوق به عنوان `async`، می توانیم از کلمه کلیدی `await` استفاده کرده و یک `Future` از اعداد صحیح را برگردانیم. در این مثال، ما منتظر هر مقدار در جریان هستیم و مجموع همه اعداد در جریان را برمی گردانیم.

ما می توانیم همه آن را به این صورت کنار هم بگذاریم:

[main.dart](_snippets/core_concepts/streams_main.dart.md ':include')

اکنون که درک اولیه ای از نحوه عملکرد `Streams` در Dart داریم، آماده هستیم تا در مورد هسته اصلی بسته Bloc بیاموزیم: یک `Cubit`.

## Cubit

> یک `Cubit` کلاسی است که از `BlocBase` ارث (extends) برده است و می تواند برای مدیریت هر نوع حالتی (State) گسترش یابد.

![Cubit Architecture](assets/cubit_architecture_full.png)

یک `Cubit` می‌تواند توابعی داشته باشد که با فراخوانی آن‌ها، تغییرات در وضعیت ایجاد شود.

> وضعیت ها (States) خروجی یک `Cubit` هستند و بخشی از وضعیت برنامه شما را، نشان می دهند. اجزای UI می توانند از وضعیت ها مطلع شوند و بخش هایی از خود را بر اساس وضعیت فعلی دوباره ترسیم کنند (وضعیت را تغییر دهند).

> **نکته**: برای کسب اطلاعات بیشتر در مورد ریشه `Cubit` [این Issue](https://github.com/felangel/cubit/issues/69) را بررسی کنید.

### ساخت یک Cubit

ما می‌توانیم یک `CounterCubit` ایجاد کنیم مانند:

[counter_cubit.dart](_snippets/core_concepts/counter_cubit.dart.md ':include')

هنگام ایجاد یک `Cubit`، باید نوع ,وضعیتی را که `Cubit` مدیریت خواهد کرد، تعریف کنیم. در مورد `CounterCubit` بالا، وضعیت را می‌توان از طریق `int` نشان داد، اما در موارد پیچیده‌تر ممکن است به جای یک داده‌ی اولیه(primitive type)، از `class` استفاده شود.

دومین کاری که باید هنگام ایجاد یک `Cubit` انجام دهیم، مشخص کردن حالت اولیه(Initial state) است. ما می توانیم این کار را با فراخوانی `super` با مقدار حالت اولیه انجام دهیم. در قطعه کد بالا(Snippet)، حالت اولیه را به صورت داخلی روی `0` تنظیم می‌کنیم، اما همچنین می‌توانیم با پذیرش یک مقدار خارجی، اجازه دهیم `Cubit` انعطاف‌پذیرتر باشد:

[counter_cubit.dart](_snippets/core_concepts/counter_cubit_initial_state.dart.md ':include')

این به ما این امکان را می‌دهد که نمونه‌های `CounterCubit` را با وضعیت‌های اولیه(Initial states) متفاوت ایجاد کنیم، مانند:

[main.dart](_snippets/core_concepts/counter_cubit_instantiation.dart.md ':include')

### تغییرات وضعیت

> هر `Cubit` توانایی تولید وضعیت جدید را از طریق `emit` دارد.

[counter_cubit.dart](_snippets/core_concepts/counter_cubit_increment.dart.md ':include')

در تکه کد بالا، `CounterCubit` یک متد عمومی به نام `increment` را ارائه می‌دهد که می‌توان آن را از بیرون صدا زد تا `CounterCubit` را از افزایش وضعیت خود آگاه کند. وقتی `increment` فراخوانی می‌شود، می‌توانیم با استفاده از `state` برای دسترسی به وضعیت فعلی `Cubit` استفاده کرده و با اضافه کردن 1 به وضعیت فعلی، یک وضعیت جدید را با استفاده از `emit` اعلام کنیم.

!> متد `emit` محافظت شده(Protected) است، به این معنی که باید تنها در داخل یک `Cubit` استفاده شود.

### استفاده از یک Cubit 

اکنون می‌توانیم از `CounterCubit` که پیاده‌سازی کرده‌ایم، استفاده کنیم!

#### استفاده پایه(Basic)

[main.dart](_snippets/core_concepts/counter_cubit_basic_usage.dart.md ':include')

در تکه کد بالا، ما با شروع ایجاد یک نمونه از `CounterCubit` آغاز می‌کنیم. سپس وضعیت کنونی Cubit که وضعیت اولیه است (زیرا هیچ وضعیت جدیدی هنوز اعلام(Emit) نشده است) را چاپ می‌کنیم. در مرحله بعد، متد `increment` را فراخوانی می‌کنیم تا یک تغییر وضعیت را ایجاد کنیم. در پایان، وضعیت `Cubit` را دوباره چاپ می‌کنیم که از `0` به `1` تغییر کرده است، و متد `close` را بر روی `Cubit` صدا می‌زنیم(Call) تا Stream داخلی وضعیت بسته شود.

#### استفاده از جریان (Stream) 

`Cubit` یک `Stream` ارائه می‌دهد که به ما امکان می‌دهد تا به تغییرات وضعیت در لحظه دسترسی داشته باشیم.

[main.dart](_snippets/core_concepts/counter_cubit_stream_usage.dart.md ':include')

در تکه کد فوق، ما به `CounterCubit` مشترک(Subscribe) می‌شویم(به تغییراتش گوش میدهیم) و در هر تغییر وضعیت، `print` را صدا می‌زنیم. سپس، تابع `increment` را فراخوانی می‌کنیم که یک وضعیت جدید ارسال(Emit) خواهد کرد. در نهایت، وقتی دیگر نمی‌خواهیم به تغییرات گوش دهیم، دستور `cancel` را بر روی `subscription` اجرا کرده و `Cubit` را بسته می‌کنیم.

?> **توجه**: دستور `await Future.delayed(Duration.zero)` برای این مثال اضافه شده است تا از لغو اشتراک به صورت فوری جلوگیری شود.

!> تنها تغییرات وضعیت‌های بعدی در هنگام فراخوانی `listen` بر روی یک `Cubit` دریافت خواهد شد.

### مشاهده(Observing) یک Cubit

> وقتی یک `Cubit` وضعیت جدیدی را انتشار (Emit) می‌دهد، یک `Change` اتفاق می‌افتد. ما می‌توانیم تمام تغییراتی که برای یک `Cubit` خاص رخ می‌دهد را با بازنویسی(Override) متد `onChange` مشاهده کنیم.

[counter_cubit.dart](_snippets/core_concepts/counter_cubit_on_change.dart.md ':include')

سپس می‌توانیم با `Cubit` تعامل داشته باشیم و تمام تغییرات خروجی کنسول را مشاهده(Observe) کنیم.

[main.dart](_snippets/core_concepts/counter_cubit_on_change_usage.dart.md ':include')

مثال بالا خروجی می دهد:

[script](_snippets/core_concepts/counter_cubit_on_change_output.sh.md ':include')

?> **توجه**: یک `Change` درست قبل از به‌روزرسانی وضعیت `Cubit` رخ می‌دهد. یک `Change` از `currentState` و `nextState` تشکیل شده است.

#### BlocObserver

یک مزیت اضافی از استفاده از کتابخانه Bloc این است که می‌توانیم به تمام `Changes` در یک مکان دسترسی داشته باشیم. حتی اگر در این برنامه تنها یک `Cubit` داشته باشیم، در برنامه‌های بزرگ‌تر، داشتن تعداد زیادی `Cubits` که بخش‌های مختلف وضعیت برنامه را مدیریت می‌کنند، نسبتاً معمول است.

اگر می‌خواهیم بتوانیم کاری را در پاسخ به همه `Changes` انجام دهیم، می‌توانیم به سادگی `BlocObserver` خود را ایجاد کنیم.

[simple_bloc_observer_on_change.dart](_snippets/core_concepts/simple_bloc_observer_on_change.dart.md ':include')

?> **توجه**: تنها کاری که باید انجام دهیم این است که `BlocObserver` را گسترش داده (Extend کنید) و متد `onChange` را بازنویسی (Override) کنیم.

برای استفاده از `SimpleBlocObserver`، فقط کافیست تغییراتی در تابع `main` اعمال کنیم.

[main.dart](_snippets/core_concepts/simple_bloc_observer_on_change_usage.dart.md ':include')

سپس قطعه کد بالا خروجی زیر را خواهد داشت:

[script](_snippets/core_concepts/counter_cubit_on_change_usage_output.sh.md ':include')

?> **نکته**: ابتدا `onChange` داخلی بازنویسی شده فراخوانی می‌شود، سپس `onChange` در `BlocObserver` فراخوانی می‌شود.

?> 💡 **نکته**: در `BlocObserver` به علاوه `Change` خود، دسترسی به نمونه `Cubit` نیز داریم.

### مدیریت خطا (Error Handling)

> هر `Cubit` دارای یک متد `addError` است که می‌توان از آن برای نشان دادن رخ داد خطا استفاده شود.

[counter_cubit.dart](_snippets/core_concepts/counter_cubit_on_error.dart.md ':include')

?> **توجه**: `onError` میتواند در `Cubit` بازنویسی شود تا با تمام خطاهای مربوط به `Cubit` خاصی برخورد کند.

`onError` همچنین میتواند در `BlocObserver` بازنویسی شود تا با خطاهای گزارش شده به صورت سراسری برخورد کند.

[simple_bloc_observer.dart](_snippets/core_concepts/simple_bloc_observer_on_error.dart.md ':include')

اگر برنامه را مجددا اجرا کنیم، باید خروجی زیر را مشاهده کنیم:

[script](_snippets/core_concepts/counter_cubit_on_error_output.sh.md ':include')

?> **نکته**: همانند `onChange`، بازنویسی `onError` داخلی قبل از بازنویسی `BlocObserver` سراسری فراخوانی می‌شود.

## Bloc

> یک `Bloc` یک کلاس پیشرفته‌تر است که به جای توابع، به `events` برای ایجاد تغییرات `state` متکی است. همچنین، `Bloc` از `BlocBase` ارث‌بری می‌کند که بدان معنی است که دارای یک API عمومی مشابه با `Cubit` است. با این حال، به جای فراخوانی `function` در `Bloc` و `emit` مستقیم یک `state` جدید، `Bloc` ها، `event` ها را دریافت می کنند و `event` های امده را به `state` های خروجی تبدیل می کنند.

![Bloc Architecture](assets/bloc_architecture_full.png)

### Creating a Bloc

ساختن یک `Bloc` مشابه ساختن یک `Cubit` است، با این تفاوت که علاوه بر تعریف وضعیتی که قصد مدیریت آن را داریم، باید همچنین رویدادی که `Bloc` قابلیت پردازش آن را دارد را نیز تعریف کنیم.

> رویدادها، ورودی‌های یک Bloc هستند. آن‌ها معمولاً به عنوان پاسخ به تعاملات کاربر مانند کلیک روی دکمه‌ها یا رویدادهای چرخه حیات مانند بارگذاری صفحه اضافه می‌شوند.

[counter_bloc.dart](_snippets/core_concepts/counter_bloc.dart.md ':include')

مانند ایجاد `CounterCubit`, ما باید با ارسال آن به کلاس پدر از طریق `super`، حالت اولیه را مشخص کنیم.

### State Changes

`Bloc` نیازمند ثبت کردن (Register) کنترل کننده رویداد (event handler) از طریق واسط `on<Event>` است، بر عکس `Cubit` که توابع را استفاده می‌کند. یک کنترل کننده رویداد مسئول تبدیل هر رویداد ورودی به صفر یا چند وضعیت خروجی است.

[counter_bloc.dart](_snippets/core_concepts/counter_bloc_event_handler.dart.md ':include')

?> 💡 **نکته**: یک `EventHandler` دسترسی به رویداد اضافه شده و همچنین یک `Emitter` دارد که می‌تواند در پاسخ به رویداد ورودی، صفر یا چند وضعیت را ارسال (emit) کند. (منظور از صفر یعنی میتواند چیزی emit نکند)

سپس می‌توانیم `EventHandler` را بروزرسانی کنیم تا به رویداد `CounterIncrementPressed` پاسخ دهد:

[counter_bloc.dart](_snippets/core_concepts/counter_bloc_increment.dart.md ':include')

در قطعه کد بالا، یک `EventHandler` را ثبت (Register) کرده‌ایم تا به مدیریت تمام رویدادهای `CounterIncrementPressed` بپردازد. برای هر رویداد ورودی `CounterIncrementPressed` می‌توانیم با استفاده از تابع بازگرداننده `state` به وضعیت فعلی بلوک دسترسی پیدا کنیم و با استفاده از `emit(state + 1)` وضعیت را ارسال کنیم. (منظور از تابع بازگرداننده تابع getter است)

?> توجه: از آنجایی که کلاس `Bloc` از `BlocBase` گسترش می یابد، ما در هر لحظه از طریق تابع `getter` متغیر  `state` به وضعیت فعلی `Bloc` دسترسی داریم، درست به مانند `Cubit`.

!> بلوک‌ها هرگز نباید به طور مستقیم وضعیت‌های جدید را `emit` کنند. در عوض، هر تغییر وضعیت، باید به عنوان پاسخ به وقوع یک رویداد ورودی در داخل یک `EventHandler` صورت گیرد.

!> هم بلوک‌ها (Blocs) و هم کیوبیت‌ها (Cubits) از وضعیت‌های تکراری چشم‌پوشی می‌کنند. اگر ما `State nextState` را emit کنیم و در واقع `state == nextState` باشد، در این صورت هیچ تغییر وضعیتی رخ نخواهد داد.

### استفاده از یک Bloc

در این نقطه، می‌توانیم یک نمونه از `CounterBloc` را ایجاد کنیم و از آن استفاده کنیم!

#### استفاده پایه

[main.dart](_snippets/core_concepts/counter_bloc_usage.dart.md ':include')

در قطعه کد بالا، ابتدا یک نمونه از `CounterBloc` ایجاد می‌کنیم. سپس وضعیت فعلی `Bloc` که وضعیت اولیه است (زیرا هیچ وضعیت جدیدی هنوز ارسال نشده است) را چاپ می‌کنیم. بعد، رویداد `CounterIncrementPressed` را اضافه می‌کنیم تا یک تغییر وضعیت را ایجاد کنیم. در نهایت، وضعیت `Bloc` را دوباره چاپ می‌کنیم که از `0` به `1` تغییر کرده است و تابه `close` را برای بستن جریان وضعیت داخلی `Bloc` صدا میزنیم.

?> **توجه**: `await Future.delayed(Duration.zero)` اضافه شده است تا اطمینان حاصل شود که منتظر تکرار بعدی حلقه رویداد (به `EventHandler` اجازه می‌دهد تا رویداد را پردازش کند) می‌مانیم.

#### استفاده از جریان

همانند `Cubit`، کلاس `Bloc` نوع خاصی از `Stream` است، به این معنی که می‌توانیم به یک `Bloc` گوش دهیم (Subscribe) تا به‌روزرسانی‌های بلادرنگ وضعیت آن را دریافت کنیم.

[main.dart](_snippets/core_concepts/counter_bloc_stream_usage.dart.md ':include')

در قطعه کد بالا، به `CounterBloc` گوش میدهیم (Subscribe) و در هر تغییر وضعیت، تابع `print` را فراخوانی می‌کنیم. سپس رویداد `CounterIncrementPressed` را اضافه می‌کنیم که باعث فعال شدن `EventHandler` `on<CounterIncrementPressed>` و ارسال یک وضعیت جدید می‌شود. در نهایت، با فراخوانی `cancel` روی جریانی که به آن گوش داده ایم (Subscribe) و زمانی که دیگر نمی‌خواهیم به‌روزرسانی‌ها را دریافت کنیم، گوش دادن را لغو می‌کنیم (UnSubscribe) و `Bloc` را بسته می‌کنیم.

?> **توجه**: `await Future.delayed(Duration.zero)` در این مثال اضافه شده است تا از لغو فوری جریان گوش داده شده (Subscribe) جلوگیری شود.

### گوش داد (Observe) به یک Bloc

از آنجا که `Bloc` از `BlocBase` به ارث می‌برد، می‌توانیم با استفاده از `onChange` تمام تغییرات وضعیت یک `Bloc` را مشاهده (Observe) کنیم.

[counter_bloc.dart](_snippets/core_concepts/counter_bloc_on_change.dart.md ':include')

سپس می‌توانیم `main.dart` را به این شکل به‌روزرسانی کنیم:

[main.dart](_snippets/core_concepts/counter_bloc_on_change_usage.dart.md ':include')

حالا اگر قطعه کد بالا را اجرا کنیم، خروجی به شکل زیر خواهد بود:

[script](_snippets/core_concepts/counter_bloc_on_change_output.sh.md ':include')

یکی از عوامل تمایزدهنده بین `Bloc` و `Cubit` این است که به دلیل اینکه `Bloc` بر اساس رویدادها عمل می‌کند، می‌توانیم اطلاعاتی درباره عاملی که تغییر وضعیت را ایجاد کرد، به دست آوریم.

برای این کار می‌توانیم `onTransition` را بازنویسی(Override) کنیم.

> تغییر از یک وضعیت به وضعیت دیگر را یک `Transition` می‌نامیم. یک `Transition` شامل وضعیت فعلی، رویداد و وضعیت بعدی است.

[counter_bloc.dart](_snippets/core_concepts/counter_bloc_on_transition.dart.md ':include')

سپس اگر همان قطعه کد `main.dart` قبلی را دوباره اجرا کنیم، باید خروجی زیر را ببینیم:

[script](_snippets/core_concepts/counter_bloc_on_transition_output.sh.md ':include')

?> **توجه**: `onTransition` قبل از `onChange` فراخوانی می‌شود و شامل رویدادی است که تغییر از `currentState` به `nextState` را ایجاد کرده است.

#### BlocObserver

همانند قبل، می‌توانیم `onTransition` را در یک `BlocObserver` سفارشی بازنویسی کنیم تا تمام تغییراتی که از یک مکان واحد اتفاق می‌افتند را مشاهده کنیم.

[simple_bloc_observer.dart](_snippets/core_concepts/simple_bloc_observer_on_transition.dart.md ':include')

می‌توانیم `SimpleBlocObserver` را همانند قبل مقداردهی اولیه کنیم.

[main.dart](_snippets/core_concepts/simple_bloc_observer_on_transition_usage.dart.md ':include')

حالا اگر قطعه کد بالا را اجرا کنیم، خروجی باید به شکل زیر باشد:

[script](_snippets/core_concepts/simple_bloc_observer_on_transition_output.sh.md ':include')

?> **توجه**: تابع `onTransition` ابتدا (متغیر محلی قبل از سراسری) و سپس تابع `onChange` در ادامه فراخوانی می‌شود.

یک ویژگی منحصر به فرد دیگر از نمونه‌های (Instances) کلاس `Bloc` این است که ما را قادر می‌سازد `onEvent` را بازنویسی کنیم. این متد هر زمان که یک رویداد جدید به Bloc اضافه می‌شود، فراخوانی شده و همانند `onChange` و `onTransition`، امکان بازنویسی `onEvent` به صورت محلی و یا سراسری وجود دارد.

[counter_bloc.dart](_snippets/core_concepts/counter_bloc_on_event.dart.md ':include')

[simple_bloc_observer.dart](_snippets/core_concepts/simple_bloc_observer_on_event.dart.md ':include')

ما می‌توانیم همان فایل `main.dart` را که قبلاً داشتیم، اجرا کنیم و باید خروجی زیر را مشاهده کنیم:

[script](_snippets/core_concepts/simple_bloc_observer_on_event_output.sh.md ':include')

?> **توجه**: تابع `onEvent` به محض اضافه شدن رویداد فراخوانی می‌شود. `onEvent` محلی قبل از `onEvent` سراسری در `BlocObserver` فراخوانی می‌شود.

### مدیریت خطا(Error Handling)

Just like with `Cubit`, each `Bloc` has an `addError` and `onError` method. We can indicate that an error has occurred by calling `addError` from anywhere inside our `Bloc`. We can then react to all errors by overriding `onError` just as with `Cubit`.

[counter_bloc.dart](_snippets/core_concepts/counter_bloc_on_error.dart.md ':include')

If we rerun the same `main.dart` as before, we can see what it looks like when an error is reported:

[script](_snippets/core_concepts/counter_bloc_on_error_output.sh.md ':include')

?> **Note**: The local `onError` is invoked first followed by the global `onError` in `BlocObserver`.

?> **Note**: `onError` and `onChange` work the exact same way for both `Bloc` and `Cubit` instances.

!> Any unhandled exceptions that occur within an `EventHandler` are also reported to `onError`.

## Cubit vs. Bloc

Now that we've covered the basics of the `Cubit` and `Bloc` classes, you might be wondering when you should use `Cubit` and when you should use `Bloc`.

### Cubit Advantages

#### Simplicity

One of the biggest advantages of using `Cubit` is simplicity. When creating a `Cubit`, we only have to define the state as well as the functions which we want to expose to change the state. In comparison, when creating a `Bloc`, we have to define the states, events, and the `EventHandler` implementation. This makes `Cubit` easier to understand and there is less code involved.

Now let's take a look at the two counter implementations:

##### CounterCubit

[counter_cubit.dart](_snippets/core_concepts/counter_cubit_full.dart.md ':include')

##### CounterBloc

[counter_bloc.dart](_snippets/core_concepts/counter_bloc_full.dart.md ':include')

The `Cubit` implementation is more concise and instead of defining events separately, the functions act like events. In addition, when using a `Cubit`, we can simply call `emit` from anywhere in order to trigger a state change.

### Bloc Advantages

#### Traceability

One of the biggest advantages of using `Bloc` is knowing the sequence of state changes as well as exactly what triggered those changes. For state that is critical to the functionality of an application, it might be very beneficial to use a more event-driven approach in order to capture all events in addition to state changes.

A common use case might be managing `AuthenticationState`. For simplicity, let's say we can represent `AuthenticationState` via an `enum`:

[authentication_state.dart](_snippets/core_concepts/authentication_state.dart.md ':include')

There could be many reasons as to why the application's state could change from `authenticated` to `unauthenticated`. For example, the user might have tapped a logout button and requested to be signed out of the application. On the other hand, maybe the user's access token was revoked and they were forcefully logged out. When using `Bloc` we can clearly trace how the application state got to a certain state.

[script](_snippets/core_concepts/authentication_transition.sh.md ':include')

The above `Transition` gives us all the information we need to understand why the state changed. If we had used a `Cubit` to manage the `AuthenticationState`, our logs would look like:

[script](_snippets/core_concepts/authentication_change.sh.md ':include')

This tells us that the user was logged out but it doesn't explain why which might be critical to debugging and understanding how the state of the application is changing over time.

#### Advanced Event Transformations

Another area in which `Bloc` excels over `Cubit` is when we need to take advantage of reactive operators such as `buffer`, `debounceTime`, `throttle`, etc.

`Bloc` has an event sink that allows us to control and transform the incoming flow of events.

For example, if we were building a real-time search, we would probably want to debounce the requests to the backend in order to avoid getting rate-limited as well as to cut down on cost/load on the backend.

With `Bloc` we can provide a custom `EventTransformer` to change the way incoming events are processed by the `Bloc`.

[counter_bloc.dart](_snippets/core_concepts/debounce_event_transformer.dart.md ':include')

With the above code, we can easily debounce the incoming events with very little additional code.

?> 💡 **Tip**: Check out [package:bloc_concurrency](https://pub.dev/packages/bloc_concurrency) for an opinionated set of event transformers.

?> 💡 **Tip**: If you are still unsure about which to use, start with `Cubit` and you can later refactor or scale-up to a `Bloc` as needed.
