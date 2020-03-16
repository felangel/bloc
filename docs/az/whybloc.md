# Niyə Bloc?

> Bloc dizayn kodları olan hissənin (presentation) məntiqi hissədən (business logic) ayrılmasını, kodunuzun sürətli, test etmək üçün asan və yenidən istifadəyə yararlı olmasını asanlaşdırır.

İstehsal keyfiyyətli tətbiqləri quran zaman, vəziyyətin (state) idadə edilməsi kritik olur.

Developer olaraq, biz istəyirik ki:

-  Tətbiqimizin istənilən anda, istənilən nöqtədə hansı vəziyyətdə olmasını bilək.
- Tətbiqimizin düzgün cavab verdiyinə əmin olmaq üçün, bütün halları asanlıqla test edə bilək.
- Hər bir istifadəçinin tətbiqlə qarşılıqlı əlaqəsini (interaction) qeyd alaraq, bu məlumatlar əsasında qərarlar qəbul edə bilək.
- Mümkün qədər səmərəli işləyək və həm cari tətbiqimizdə və həm də digər tətbiqlərimizdə komponentləri yenidən istifadə edək.
- Çoxlu developer heç bir problem olmadan, eyni pattern və konvensiyaları izləyərək, bir kod bazasında işləyə bilsinlər.
- Sürrtəli və reaktiv tətbiqlər yaradaq.

Bloc bu ehtiyaclarn hamısını və daha çox şeyləri qarşılamaq üçün tərtib edilmişdir.

Çoxlu vəziyyətin idarə edilməsi üçün həllər vardır və istifadə üçün hansının yaxşı olduğunu seçmək çətin tapşırıq ola bilər.

Bloc 3 əsas dəyəri nəzərə alaraq, tərtib edilmişdir:

- Sadə
  - anlamaq asandır və müxtəlif səviyyəli developerlər tərəfindən istifadə oluna bilər.
- Güclü
  - İnanılmaz, kompleks tətbiqləri, onları kiçik komponentlərə bölərək, yaratmağa kömək edir.
- Test edilə bilən
  - Tətbiqin hər bir aspektini asanlıqla test etməyə imkan verir, beləliklə biz inamla təkrar edə bilərik.

Bloc vəziyyətdə dəyişiklik olan zamanı tənzimləyərək, vəziyyət dəyişiklikləri etməyə və bütün tətbiq boyunca tək yol ilə vəziyyətin dəyişməsinə çalışır.
