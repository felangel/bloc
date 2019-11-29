# Proč Bloc?

> Bloc umožňuje jednoduše rozdělit prezentační a logickou část, což dělá váš kód _rychlý_, _jednoduše testovatelný_ a _znovupoužitelný_.

Když vytváříte kvalitní produkční aplikace, správa stavu je kritická.

Jako vývojáři chceme:

- vědět, ve kterém stavu je naše aplikace v kterémkoli okamžiku
- snadno otestovat každý případ a ujistit se, že naše aplikace reaguje správně
- zaznamenat každou uživatelskou akci v naší aplikaci, abychom mohli dělat rozhodnutí založené na datech
- pracovat co nejefektivněji jak je možné a znovu používat komponenty jak v naší aplikaci, tak v jiných aplikacích
- mít mnoho vývojářů, kteří bez problémů pracují v jednom code base tak, že dodržují stejné vzory a konvence
- vyvíjet rychlé a reaktivní aplikace

Bloc je navržen tak, aby splňoval všechny tyto potřeby a mnoho dalších.

Existuje mnoho řešení pro state management a rozhodování, které z nich použít může být skličující úkol.

Bloc byl navržen s ohledem na tři základní hodnoty:

- Jednoduchý
  - Snadný pochopit a může být používán vývojáři s rozdílnými dovednostmi.
- Výkonný
  - Pomáhá vytvářet úžasné a komplexní aplikace díky kompozici menších komponent.
- Testovatelný
  - Jednoduše testujte každý aspekt aplikace, abychom mohli snadno a s důvěrou iterovat.

Bloc se snaží provádět změny stavu předvídatelně pomocí řízení, kdy může dojít ke změně stavu a vynucením jediného způsobu, jak změnit stav v rámci celé aplikace.
