### Note: Nemám source pro to `.pdf`, tak si to tam budeš muset doplnit sám

# Popis

## Diagram případů užití

- Se systémem pracují převážně uživatelé, kteří jsou obyčejní kouzelníci. Dokáží zobrazovat si různé informace a evidovat případné zachycené stopy. Stopy mohou zachytávat i různé detektory magie a případě zachycení stopy způsobené předmětem s dostatečnou nebezpečností je vyhlášen poplach.
- Dále se systémem pracují zaměstnanci ministerstva, kteří jsou kouzelníci s vyššími pravomocemi a spravují všechny mudlovské a magické předměty v databázi.
- Posledním aktorem v systému je zprávce, který spravuje přímo jednotlivé kouzelníky.

## ER diagram
Hlavní tabulky databáze jsou tabulka kouzelníků a tabulka předmětů, které můžou kouzelníci vlastnit. Protože kouzelník může vlastnit více jak jeden předmět, tak je využita spojovací tabulka, která uchovává i doplňující informace o vlastnictví předmětů.
Každý předmět je jednoznačně identifikovatelný runovým kódem, ať se jedná o obyčejný mudlovský a nebo kouzelný předmět. Mudlovské předměty obsahují cenu a výrobce, od kterého si jej kouzelník zakoupil. Tabulka kouzelných předmětů obsahuje informace jako typ a nebezpečnost předmětu.
Předmět zanechává stopy různého typu, které jsou zachytnutelné v určitý čas buď kouzelníkem a nebo detektorem magie, který se rozlišeuje svým stavem a citlivostí a zachytavá jen určité typy stop.