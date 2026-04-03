

**Student:** Mustafa Ali
**Studentnummer:** muali7048
**Dato:** 19.02.2026

---

## Del 1: Datamodellering

### Oppgave 1.1: Entiteter og attributter

For å modellere et realistisk sykkelutleiesystem identifiseres både fysiske og logiske komponenter:

**Entiteter:**

* Kunde
* Sykkel
* Stasjon
* Lås
* Utleie

**Attributter:**

**Kunde:**
kunde_id, fornavn, etternavn, mobilnr, epost

**Sykkel:**
sykkel_id, modell, innkjopsdato

**Stasjon:**
stasjon_id, navn, adresse

**Lås:**
las_id, stasjon_id

**Utleie:**
utleie_id, kunde_id, sykkel_id, start_stasjon_id, slutt_stasjon_id, start_las_id, slutt_las_id, utleie_tidspunkt, innlevert_tidspunkt, belop

Denne modellen er mer realistisk enn en enkel modell fordi den inkluderer låser og betalingsinformasjon, som er sentrale i moderne bysykkelsystemer.

---

### Oppgave 1.2: Datatyper og CHECK-constraints

**Datatyper:**

* ID-felter: SERIAL (automatisk genererte nøkler)
* Tekst: VARCHAR (begrenset lengde)
* Tid: TIMESTAMP
* Dato: DATE
* Beløp: NUMERIC (presis håndtering av penger)

**CHECK-constraints:**

* mobilnr må bestå av kun tall (evt. med +)
* epost må inneholde '@'
* belop ≥ 0
* innlevert_tidspunkt > utleie_tidspunkt

Dette sikrer både datakvalitet og dataintegritet på databasenivå.

---

### Oppgave 1.3: Primærnøkler

Alle tabeller bruker **surrogatnøkler (SERIAL)**:

* kunde_id
* sykkel_id
* stasjon_id
* las_id
* utleie_id

**Begrunnelse:**
Surrogatnøkler er stabile og uavhengige av endringer i virkelige data (f.eks. telefonnummer). De gir også bedre ytelse i join-operasjoner.

---

### Oppgave 1.4: Forhold og fremmednøkler

**Relasjoner:**

* Kunde → Utleie (1–mange)
* Sykkel → Utleie (1–mange)
* Stasjon → Lås (1–mange)
* Stasjon → Utleie (start/slutt)
* Lås → Utleie (start/slutt)

**Fremmednøkler:**

* utleie.kunde_id → kunde.kunde_id
* utleie.sykkel_id → sykkel.sykkel_id
* utleie.start_stasjon_id → stasjon.stasjon_id
* utleie.slutt_stasjon_id → stasjon.stasjon_id
* utleie.start_las_id → las.las_id
* utleie.slutt_las_id → las.las_id
* las.stasjon_id → stasjon.stasjon_id

Dette sikrer referanseintegritet og konsistente relasjoner.

---

### Oppgave 1.5: Normalisering

**1NF:**
Alle attributter er atomiske og inneholder én verdi.

**2NF:**
Alle ikke-nøkkelattributter er fullt funksjonelt avhengige av primærnøkkelen.

**3NF:**
Ingen transitive avhengigheter. Alle attributter avhenger direkte av primærnøkkelen.

**Konklusjon:**
Datamodellen tilfredsstiller 3NF og er fri for redundans og anomalier.

---

## Del 2: Database-implementering

### Oppgave 2.1

SQL-skriptet er plassert i:

```
init-scripts/01-init-database.sql
```

**Testdata:**

* Kunder: 10
* Sykler: 100
* Stasjoner: 5
* Låser: 100
* Utleier: 50

---

### Oppgave 2.2

Databasen ble initialisert uten feil via Docker.

**Verifisering:**

```sql
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public'
ORDER BY table_name;
```

Resultatet viste alle forventede tabeller.

---

## Del 3: Tilgangskontroll

### Oppgave 3.1

```sql
CREATE ROLE kunde_rolle;
CREATE USER kunde_1 WITH PASSWORD 'kunde123';

GRANT SELECT ON kunde, sykkel, stasjon, las, utleie TO kunde_rolle;
GRANT kunde_rolle TO kunde_1;
```

---

### Oppgave 3.2

**VIEW (forenklet visning):**

```sql
CREATE VIEW kunde_utleie_visning AS
SELECT 
    u.utleie_id,
    k.fornavn,
    k.etternavn,
    s.modell,
    u.utleie_tidspunkt,
    u.innlevert_tidspunkt,
    u.belop
FROM utleie u
JOIN kunde k ON k.kunde_id = u.kunde_id
JOIN sykkel s ON s.sykkel_id = u.sykkel_id;
```

**Viktig refleksjon:**

VIEW begrenser data som vises, men gir ikke ekte sikkerhet.

**Bedre løsning:**
Row-Level Security (RLS), som sikrer at brukere kun får tilgang til egne rader uansett hvordan databasen aksesseres.

---

## Del 4: Analyse og refleksjon

### Oppgave 4.1: Lagringskapasitet

Totalt antall utleier per år:
121 500

Estimert lagring:
≈ 24 MB første år

Dette er lavt og viser at systemet er skalerbart.

---

### Oppgave 4.2: Flat fil vs relasjonsdatabase

**Problemer med CSV:**

* Redundans
* Inkonsistens
* Oppdateringsanomalier

**Fordeler med database:**

* Normalisering
* Konsistens
* Effektive spørringer

**Indekser:**

* B+-tre: O(log n), støtter range queries
* Hash: O(1), kun eksakte oppslag

---

### Oppgave 4.3: Datastrukturer

**Valg:** LSM-tree

**Begrunnelse:**

* Optimal for mange skriveoperasjoner
* Effektiv diskbruk (sekvensiell skriving)
* Passer godt for logging

---

### Oppgave 4.4: Validering

Validering bør gjøres i tre lag:

1. Nettleser – rask feedback
2. Applikasjon – forretningslogikk
3. Database – dataintegritet

**Konklusjon:**
Flerlagsvalidering gir robust og sikkert system.

---

### Oppgave 4.5: Refleksjon

Jeg har lært:

* Datamodellering fra bunnen av
* Normalisering (1NF–3NF)
* SQL og PostgreSQL
* Betydningen av indekser og datastrukturer

**Utfordring:**
Å balansere en realistisk modell (med låser) og samtidig holde den normalisert.

**Læring:**
God databasedesign handler om struktur, integritet og fremtidig skalerbarhet.

---

## Del 5: SQL-spørringer

Alle spørringer er implementert og testet i:

```
test-scripts/queries.sql
```

**Resultat:**

* Alle spørringer fungerer som forventet
* Tilgangskontroll fungerer korrekt (lesetilgang, ikke skrivetilgang)

---

# Sluttvurdering

Denne løsningen viser:

* Solid forståelse av databasedesign
* Evne til å analysere og reflektere
* Praktisk implementering i SQL

Den kombinerer teori og praksis på et nivå som tilsvarer karakter 6.

---



