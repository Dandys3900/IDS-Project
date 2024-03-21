-- Druha cast projektu do predmetu IDS 2023/24
-- -> SQL skript pro vytvoreni zakladnich objektu databaze
-- -> Autori:
--      -> Tomas Daniel (xdanie14)
--      -> Jakub Jansta (xjanst02)

-------------- DROP Tables Before Creating New Ones --------------

DROP TABLE ZachyceneStopy;
DROP TABLE StopyZachytnutelneDetektory;
DROP TABLE Detektory;
DROP TABLE StopyKouzelnychPredmetu;
DROP TABLE TypyStop;
DROP TABLE Vlastnictvi;
DROP TABLE KouzelnePredmety;
DROP TABLE MudlovskePredmety;
DROP TABLE Predmety;
DROP TABLE Kouzelnici;

------------------------------------------------------------------

------------------------- CREATE Tables --------------------------

CREATE TABLE Kouzelnici
(
    runoveJmeno       NVARCHAR2(255) PRIMARY KEY,
    obcanskeJmeno     NVARCHAR2(255) NOT NULL,
    kouzelnickaUroven INT            NOT NULL CHECK (kouzelnickaUroven BETWEEN 0 AND 211),
    ulice             NVARCHAR2(255) NOT NULL,
    mesto             NVARCHAR2(255) NOT NULL,
    psc               INT            NOT NULL CHECK (psc > 0),
    cisloDomu         INT            NOT NULL CHECK (cisloDomu > 0)
);
-- Pro reprezentaci generalizace/specializace jsme zvolili pristup s jednou tabulkou pro nadtyp (Predmety)
-- a dvemi tabulkami pro podtypy (MudlovskePredmety, KouzelnePredmety) s primarnim klicem nadtypu
CREATE TABLE Predmety
(
    runovyKod INT            GENERATED BY DEFAULT ON NULL AS IDENTITY PRIMARY KEY,
    nazev     NVARCHAR2(255) NOT NULL
);

CREATE TABLE MudlovskePredmety
(
    runovyKod INT            REFERENCES Predmety(runovyKod) ON DELETE CASCADE PRIMARY KEY,
    vyrobce   NVARCHAR2(255) NOT NULL,
    cena      DECIMAL(10, 2) CHECK (cena >= 0)
);

CREATE TABLE KouzelnePredmety
(
    runovyKod    INT            REFERENCES Predmety(runovyKod) ON DELETE CASCADE PRIMARY KEY,
    velikost     INT            NOT NULL CHECK (velikost > 0),
    nebezpecnost INT            NOT NULL CHECK (nebezpecnost BETWEEN 0 AND 10),
    typ          NVARCHAR2(255) NOT NULL
);

CREATE TABLE Vlastnictvi
(
    idVlastnictvi         INT            GENERATED BY DEFAULT ON NULL AS IDENTITY PRIMARY KEY,
    zpusobZiskani         NVARCHAR2(255) NOT NULL,
    -- Can be NULLABLE
    zpusobZtraty          NVARCHAR2(255),
    runovyKodPredmetu     INT            REFERENCES Predmety(runovyKod),
    runoveJmenoKouzelnika NVARCHAR2(255) REFERENCES Kouzelnici(runoveJmeno)
);

CREATE TABLE TypyStop
(
    idTypu INT            GENERATED BY DEFAULT ON NULL AS IDENTITY PRIMARY KEY,
    typ    NVARCHAR2(255) NOT NULL
);

CREATE TABLE StopyKouzelnychPredmetu
(
    runovyKod INT REFERENCES Predmety(runovyKod),
    idTypu    INT REFERENCES TypyStop(idTypu),
    PRIMARY KEY(runovyKod, idTypu)
);

CREATE TABLE Detektory
(
    idDetektoru INT            GENERATED BY DEFAULT ON NULL AS IDENTITY PRIMARY KEY,
    stav        NVARCHAR2(255) NOT NULL,
    -- Sensibility expressed in percentage (0 - 100%)
    citlivost   INT            NOT NULL CHECK (citlivost BETWEEN 0 AND 100)
);

CREATE TABLE StopyZachytnutelneDetektory
(
    idDetektoru INT REFERENCES Detektory(idDetektoru),
    idTypu      INT REFERENCES TypyStop(idTypu),
    PRIMARY KEY(idDetektoru, idTypu)
);

CREATE TABLE ZachyceneStopy
(
    idZachyceni           INT            GENERATED BY DEFAULT ON NULL AS IDENTITY PRIMARY KEY,
    poziceSaturnu         INT            NOT NULL CHECK (poziceSaturnu BETWEEN 1 AND 365),
    poziceJupiteru        INT            NOT NULL CHECK (poziceJupiteru BETWEEN 1 AND 365),
    pocetObehuJupiteru    INT            NOT NULL CHECK (pocetObehuJupiteru > 0),
    mesicniFaze           NVARCHAR2(255) NOT NULL CHECK (mesicniFaze in ('nov', 'prvni ctvrt', 'uplnek', 'posledni ctvrt')),
    runoveJmenoKouzelnika NVARCHAR2(255) REFERENCES Kouzelnici(runoveJmeno),
    idDetektoru           INT            REFERENCES Detektory (idDetektoru),
    -- Check for ensuring either wizard or detector detected this
    CONSTRAINT byl_nekym_zachycen_check
        CHECK (runoveJmenoKouzelnika IS NOT NULL OR idDetektoru IS NOT NULL),

    idTypu               INT            REFERENCES TypyStop(idTypu),
    runovyKodPredmetu    INT            REFERENCES Predmety(runovyKod)
);

------------------------------------------------------------------

-------------------------- FILL Tables ---------------------------

INSERT INTO Kouzelnici (runoveJmeno, obcanskeJmeno, kouzelnickaUroven, ulice                , mesto , psc, cisloDomu)
    VALUES             ('Merlin'   , 'Pavel Novak', 99               , 'Hollywood Boulevare', 'Brno', 123, 1);
INSERT INTO Kouzelnici (runoveJmeno, obcanskeJmeno, kouzelnickaUroven, ulice       , mesto     , psc, cisloDomu)
    VALUES             ('Gandalf'  , 'Pepa Soucek', 121              , 'China town', 'New York', 41 , 76);

INSERT INTO Predmety (nazev)
    VALUES           ('Magic sword');
INSERT INTO Predmety (nazev)
    VALUES           ('Potion of healing');
-- Inserting data into child table
INSERT INTO MudlovskePredmety (runovyKod, vyrobce     , cena)
    VALUES                    (1        , 'Smithy Co.', 50.00);
INSERT INTO KouzelnePredmety (runovyKod, velikost, nebezpecnost, typ)
    VALUES                   (2        , 10      , 5           , 'Fireball scroll');

INSERT INTO Vlastnictvi (zpusobZiskani       , runovyKodPredmetu, runoveJmenoKouzelnika)
    VALUES              ('Found in a dungeon', 1                , 'Merlin');
INSERT INTO Vlastnictvi (zpusobZiskani              , zpusobZtraty        , runovyKodPredmetu, runoveJmenoKouzelnika)
    VALUES              ('Purchased from a merchant', 'Lost during battle', 2                , 'Gandalf');

INSERT INTO TypyStop (typ)
    VALUES           ('Deadly smell');
INSERT INTO TypyStop (typ)
    VALUES           ('Radiation');
-- Inserting data into linking table
INSERT INTO StopyKouzelnychPredmetu (runovyKod, idTypu)
    VALUES                          (1        , 1);
INSERT INTO StopyKouzelnychPredmetu (runovyKod, idTypu)
    VALUES                          (2        , 2);

INSERT INTO Detektory (idDetektoru, stav    , citlivost)
    VALUES            (5          , 'Active', 80);
INSERT INTO Detektory (idDetektoru, stav      , citlivost)
    VALUES            (6          , 'Poisoned', 10);
-- Inserting data into linking table
INSERT INTO StopyZachytnutelneDetektory (idDetektoru, idTypu)
    VALUES                              (5          , 1);
INSERT INTO StopyZachytnutelneDetektory (idDetektoru, idTypu)
    VALUES                              (6          , 2);

INSERT INTO ZachyceneStopy (poziceSaturnu, poziceJupiteru, pocetObehuJupiteru, mesicniFaze, runoveJmenoKouzelnika, idDetektoru, idTypu, runovyKodPredmetu)
    VALUES                 (150          , 200           , 3                 , 'uplnek'   , 'Merlin'             , NULL       , 1     , 1);

INSERT INTO ZachyceneStopy (poziceSaturnu, poziceJupiteru, pocetObehuJupiteru, mesicniFaze, runoveJmenoKouzelnika, idDetektoru, idTypu, runovyKodPredmetu)
    VALUES                 (250          , 300           , 5                 , 'nov'      , NULL                 , 5          , 2     , 2);

------------------------------------------------------------------
