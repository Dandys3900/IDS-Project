DROP TABLE IF EXISTS Kouzelnici;
DROP TABLE IF EXISTS Predmety;
DROP TABLE IF EXISTS MudlovskePredmety;
DROP TABLE IF EXISTS KouzelnePredmety;
DROP TABLE IF EXISTS Vlastnictvi;
DROP TABLE IF EXISTS TypyStop;
DROP TABLE IF EXISTS StopyKouzelnychPredmetu;
DROP TABLE IF EXISTS Detektory;
DROP TABLE IF EXISTS StopyZachytnutelneDetektory;
DROP TABLE IF EXISTS ZachyceneStopy;

CREATE TABLE Kouzelnici
(
    -- TODO omezeni hodnoty runovehoJmena
    runoveJmeno NVARCHAR2(255) PRIMARY KEY,
    obcanskeJmeno NVARCHAR2(255) NOT NULL,
    kouzelnickaUroven INT NOT NULL CHECK (kouzelnickaUroven BETWEEN 0 AND 211),
    ulice NVARCHAR2(255) NOT NULL,
    mesto NVARCHAR2(255) NOT NULL,
    psc INT NOT NULL,
    cisloDomu INT NOT NULL CHECK (cisloDomu > 0)
);

CREATE TABLE Predmety
(
    runovyKod NVARCHAR2(255) PRIMARY KEY,
    nazev NVARCHAR2(255) NOT NULL
);

CREATE TABLE MudlovskePredmety
(
    runovyKod NVARCHAR2(255) REFERENCES Predmety(runovyKod) ON DELETE CASCADE,
    vyrobce NVARCHAR2(255) NOT NULL,
    cena DECIMAL(10, 2),
    PRIMARY KEY(runovyKod)
);

CREATE TABLE KouzelnePredmety
(
    runovyKod NVARCHAR2(255) REFERENCES Predmety(runovyKod) ON DELETE CASCADE,
    velikost INT NOT NULL CHECK (velikost > 0),
    nebezpecnost INT NOT NULL CHECK (nebezpecnost BETWEEN 0 AND 10),
    typ NVARCHAR2(255) NOT NULL,
    PRIMARY KEY(runovyKod)
);

CREATE TABLE Vlastnictvi
(
    -- TODO pouzit to v te discord zalozce https://discord.com/channels/461541385204400138/591341448386052117/1219659106013679667
    idVlastnictvi INT PRIMARY KEY,
    zpusobZiskani NVARCHAR2(255) NOT NULL,
    -- muze byt NULL (nemusi ho nuten ztratit)
    zpusobZtraty NVARCHAR2(255),
    runovyKodPredmetu NVARCHAR2(255) REFERENCES Predmety(runovyKod),
    runoveJmenoKouzelnika NVARCHAR2(255) REFERENCES Kouzelnici(runoveJmeno)
);

CREATE TABLE TypyStop
(
    idTypu INT PRIMARY KEY,
    typ NVARCHAR2(255) NOT NULL
);

CREATE TABLE StopyKouzelnychPredmetu
(
    runovyKod NVARCHAR2(255) REFERENCES Predmety(runovyKod),
    idTypu INT REFERENCES TypyStop(idTypu),
    PRIMARY KEY(runovyKod, idTypu)
);

CREATE TABLE Detektory
(
    idDetektoru INT PRIMARY KEY,
    stav NVARCHAR2(255) NOT NULL,
    citlivost INT NOT NULL CHECK (citlivost BETWEEN 0 AND 100)
);

CREATE TABLE StopyZachytnutelneDetektory
(
    idDetektoru INT REFERENCES Detektory(idDetektoru),
    idTypu INT REFERENCES TypyStop(idTypu),
    PRIMARY KEY(idDetektoru, idTypu)
);

CREATE TABLE ZachyceneStopy
(
    idZachyceni INT PRIMARY KEY,
    poziceSaturnu INT NOT NULL CHECK (poziceSaturnu BETWEEN 1 AND 365),
    poziceJupiteru INT NOT NULL CHECK (poziceJupiteru BETWEEN 1 AND 365),
    pocetObehuJupiteru INT NOT NULL CHECK (pocetObehuJupiteru > 0),
    mesicniFaze NVARCHAR2(255) NOT NULL CHECK(mesicniFaze in ('nov', 'prvni ctvrt', 'uplnek', 'posledni ctvrt')),
    runoveJmenoKouzelnika NVARCHAR2(255) REFERENCES Kouzelnici(runoveJmeno),
    idDetektoru INT REFERENCES Detektory(idDetektoru),
    CONSTRAINT bylNekymZachycen_check CHECK(runoveJmenoKouzelnika IS NOT NULL OR idDetektoru IS NOT NULL),
    idTypu INT REFERENCES TypyStop(idTypu),
    runovyKodPredmetu NVARCHAR2(255) REFERENCES Predmety(runovyKod)
);
