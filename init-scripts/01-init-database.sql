-- ============================================================================
-- DATA1500 - Oblig 1: Arbeidskrav I våren 2026
-- Initialiserings-skript for PostgreSQL
-- ============================================================================

CREATE TABLE kunde (
  kunde_id SERIAL PRIMARY KEY,
  fornavn VARCHAR(50) NOT NULL,
  etternavn VARCHAR(50) NOT NULL,
  mobilnummer VARCHAR(15) UNIQUE NOT NULL CHECK (mobilnummer ~ '^[0-9]{8,15}$'),
  epost VARCHAR(100) UNIQUE NOT NULL CHECK (epost LIKE '%@%'),
  registrert_dato DATE DEFAULT CURRENT_DATE
);

CREATE TABLE sykkel (
  sykkel_id SERIAL PRIMARY KEY,
  status VARCHAR(10) CHECK (status IN ('ledig','utleid')),
  kjøpt_dato DATE
);

CREATE TABLE stasjon (
  stasjon_id SERIAL PRIMARY KEY,
  navn VARCHAR(100),
  adresse VARCHAR(200)
);

CREATE TABLE las (
  las_id SERIAL PRIMARY KEY,
  stasjon_id INT REFERENCES stasjon(stasjon_id),
  sykkel_id INT REFERENCES sykkel(sykkel_id)
);

CREATE TABLE utleie (
  utleie_id SERIAL PRIMARY KEY,
  kunde_id INT REFERENCES kunde(kunde_id),
  sykkel_id INT REFERENCES sykkel(sykkel_id),
  utlevert_tid TIMESTAMP NOT NULL,
  innlevert_tid TIMESTAMP,
  beløp NUMERIC(8,2) CHECK (beløp >= 0)
);

-- Testdata
INSERT INTO kunde (fornavn, etternavn, mobilnummer, epost)
SELECT 'Kunde', i, '9000000' || i, 'kunde'||i||'@test.no'
FROM generate_series(1,5) i;

INSERT INTO stasjon (navn, adresse)
SELECT 'Stasjon '||i, 'Gate '||i
FROM generate_series(1,5) i;

INSERT INTO sykkel (status, kjøpt_dato)
SELECT 'ledig', CURRENT_DATE - (i || ' days')::interval
FROM generate_series(1,100) i;

INSERT INTO las (stasjon_id, sykkel_id)
SELECT (i % 5) + 1, i
FROM generate_series(1,100) i;

INSERT INTO utleie (kunde_id, sykkel_id, utlevert_tid, innlevert_tid, beløp)
SELECT
  (i % 5) + 1,
  i,
  NOW() - INTERVAL '2 days',
  NOW() - INTERVAL '1 day',
  49.00
FROM generate_series(1,50) i;




-- Vis at initialisering er fullført (kan se i loggen fra "docker-compose log"
SELECT 'Database initialisert!' as status;
