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

درست مانند `Cubit`، هر `Bloc` دارای متدهای `addError` و `onError` است. می‌توانیم با فراخوانی `addError` از هر نقطه‌ای در داخل `Bloc`، نشان دهیم که یک خطا رخ داده است. سپس با بازنویسی `onError`، می‌توانیم به تمام خطاها واکنش نشان دهیم، همانند `Cubit`.

[counter_bloc.dart](_snippets/core_concepts/counter_bloc_on_error.dart.md ':include')

اگر مجدداً `main.dart` را همانند قبل اجرا کنیم، می‌توانیم ببینیم که وقتی یک خطا گزارش می‌شود، به چه شکلی است.

[script](_snippets/core_concepts/counter_bloc_on_error_output.sh.md ':include')

?> **توجه**: در ابتدا، `onError` محلی فراخوانی می‌شود و سپس `onError` سراسری در `BlocObserver` فراخوانی می‌شود.

?> **توجه**: `onError` و `onChange` برای هر دو نمونه `Bloc` و `Cubit`به یک شکل کار می کنند.

!> هر استثنای کنترل نشده ای که در یک `EventHandler` رخ می دهد نیز به `onError` گزارش می شود.

## Cubit در مقابل Bloc

حالا که مبانی کلاس‌های `Cubit` و `Bloc` را پوشش دادیم، ممکن است تعجب کنید که چه زمانی باید از `Cubit` و چه زمانی از `Bloc` استفاده کنید.

### مزایای Cubit

#### سادگی

یکی از بزرگترین مزیت‌های استفاده از `Cubit`، سادگی آن است. هنگام ایجاد یک `Cubit`، تنها باید وضعیت و توابعی را که می‌خواهیم برای تغییر وضعیت به بیرون (`Cubit`) ارائه دهیم، تعریف کنیم. در مقابل، در ایجاد یک `Bloc`، باید وضعیت‌ها (States)، رویدادها (Events) و پیاده‌سازی `EventHandler` را تعریف کنیم. این (موضوع) باعث می‌شود `Cubit` آسان‌تر قابل درک باشد و کدهای کمتری درگیر شوند.

حالا بیایید به دو پیاده‌سازی شمارنده نگاهی بیندازیم:

##### CounterCubit

[counter_cubit.dart](_snippets/core_concepts/counter_cubit_full.dart.md ':include')

##### CounterBloc

[counter_bloc.dart](_snippets/core_concepts/counter_bloc_full.dart.md ':include')

پیاده‌سازی `Cubit`  کوتاه تر است و به جای تعریف رویدادها به صورت جداگانه، توابع مانند رویدادها عمل می‌کنند. علاوه بر این، در استفاده از `Cubit`، به راحتی می‌توانیم از هر نقطه‌ای `emit` را فراخوانی کنیم تا تغییر وضعیت را اعمال کنیم.

### مزایای Bloc

#### قابلیت ردیابی (Traceability)

یکی از بزرگترین مزایای استفاده از `Bloc` این است که می‌توانیم دنباله‌ای از تغییرات وضعیت را همراه با دقیقاً آنچه که این تغییرات را تحریک و باعث شده، بدانیم. برای وضعیتی که برای عملکرد یک برنامه بسیار حیاتی است، استفاده از رویکرد مبتنی بر رویداد می‌تواند بسیار مفید باشد تا همه رویدادها را در کنار تغییرات وضعیت (State changes) را ثبت کنیم.

یکی از موارد استفاده متداول می‌تواند مدیریت `AuthenticationState` باشد. برای سادگی، بگذارید بگوییم که می‌توانیم `AuthenticationState` را از طریق یک `enum` نمایش دهیم:

[authentication_state.dart](_snippets/core_concepts/authentication_state.dart.md ':include')

ممکن است دلایل زیادی وجود داشته باشد که چرا وضعیت برنامه می تواند از `authenticated` به `unauthenticated` تغییر کند. به عنوان مثال، کاربر ممکن است دکمه خروج را لمس کرده و درخواست خروج از برنامه را ارسال کند. از طرف دیگر، شاید توکن دسترسی کاربر لغو شده و او به طور اجباری خارج شده باشد. با استفاده از `Bloc`، می‌توانیم به وضوح پیگیری کنیم که وضعیت برنامه چگونه به یک وضعیت خاص رسیده است.

[script](_snippets/core_concepts/authentication_transition.sh.md ':include')

کلاس `Transition` بالا تمام اطلاعاتی که برای درک دلیل تغییر وضعیت نیاز داریم را به ما می‌دهد. اگر از یک `Cubit` برای مدیریت `AuthenticationState` استفاده کرده بودیم، لاگ‌های ما به شکل زیر خواهند بود:

[script](_snippets/core_concepts/authentication_change.sh.md ':include')

در این لاگ، به ما اطلاع می‌دهد که کاربر خارج شده است اما توضیحی درباره دلیل این اتفاق نمی‌دهد, این موضوع ممکن است برای رفع اشکال و درک نحوه تغییر وضعیت برنامه در طول زمان بسیار حیاتی باشد.

#### Event Transformations پیشرفته

یکی از حوزه‌هایی که `Bloc` نسبت به `Cubit` برتری دارد، زمانی است که نیاز به استفاده از عملگرهای واکنشی مانند `buffer`، `debounceTime`، `throttle` و غیره داریم.

`Bloc` دارای یک سینک رویداد (Event sink) است که به ما امکان می‌دهد جریان ورودی رویدادها را کنترل و تبدیل کنیم.

به عنوان مثال، اگر قصد داشته باشیم یک جستجوی زمان واقعی را پیاده سازی کنیم، احتمالاً می‌خواهیم درخواست‌ها را به سمت سرور به تأخیر بیندازیم تا از محدودیت نرخ (Rate limited) استفاده کننده جلوگیری کنیم و همچنین بر روی هزینه و بار سرور صرفه جویی کنیم.

با استفاده از `Bloc` می‌توانیم یک `EventTransformer` سفارشی ارائه دهیم تا روش پردازش رویدادهای ورودی توسط `Bloc` را تغییر دهیم.

[counter_bloc.dart](_snippets/core_concepts/debounce_event_transformer.dart.md ':include')

با استفاده از کد فوق، می‌توانیم به راحتی رویدادهای ورودی را با کمترین کد اضافی به تأخیر بیندازیم.

?> 💡 **نکته**: بسته [package:bloc_concurrency](https://pub.dev/packages/bloc_concurrency) برای  مجموعه از تبدیل‌کننده‌های (Transformers) رویداد با رویکرد و قواعد خاص را بررسی کنید.

?> 💡 **نکته**: اگر هنوز مطمئن نیستید که از کدام یک استفاده کنید، با `Cubit` شروع کنید و در صورت نیاز می‌توانید در آینده به `Bloc` بروید و کد را بازسازی یا ارتقا دهید.
