-- ============================================================================
-- DATA1500 - Obligatorisk oppgave 1: Database-oppsett
-- ============================================================================

CREATE TABLE kunde (
    kunde_id    SERIAL PRIMARY KEY,
    fornavn     VARCHAR(100) NOT NULL,
    etternavn   VARCHAR(100) NOT NULL,
    mobilnr     VARCHAR(20)  UNIQUE NOT NULL,
    epost       VARCHAR(255) UNIQUE NOT NULL,
    CONSTRAINT chk_mobilnr CHECK (mobilnr ~ '^\+?[0-9]{8,15}$'),
    CONSTRAINT chk_epost   CHECK (epost ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

CREATE TABLE sykkel (
    sykkel_id       SERIAL PRIMARY KEY,
    modell          VARCHAR(100) NOT NULL,
    innkjopsdato    DATE NOT NULL
);

CREATE TABLE stasjon (
    stasjon_id  SERIAL PRIMARY KEY,
    navn        VARCHAR(100) NOT NULL,
    adresse     VARCHAR(255) NOT NULL
);

CREATE TABLE las (
    las_id      SERIAL PRIMARY KEY,
    stasjon_id  INTEGER REFERENCES stasjon(stasjon_id)
);

CREATE TABLE utleie (
    utleie_id           SERIAL PRIMARY KEY,
    kunde_id            INTEGER NOT NULL REFERENCES kunde(kunde_id),
    sykkel_id           INTEGER NOT NULL REFERENCES sykkel(sykkel_id),
    start_stasjon_id    INTEGER NOT NULL REFERENCES stasjon(stasjon_id),
    slutt_stasjon_id    INTEGER REFERENCES stasjon(stasjon_id),
    start_las_id        INTEGER REFERENCES las(las_id),
    slutt_las_id        INTEGER REFERENCES las(las_id),
    utleie_tidspunkt    TIMESTAMP NOT NULL,
    innlevert_tidspunkt TIMESTAMP,
    belop               NUMERIC(10,2),
    CONSTRAINT chk_tidspunkt CHECK (innlevert_tidspunkt IS NULL OR innlevert_tidspunkt > utleie_tidspunkt),
    CONSTRAINT chk_belop     CHECK (belop IS NULL OR belop >= 0)
);

-- ============================================================================
-- Testdata: Kunder
-- ============================================================================

INSERT INTO kunde (fornavn, etternavn, mobilnr, epost) VALUES
    ('Ole',    'Hansen',   '+4791234567', 'ole.hansen@example.com'),
    ('Kari',   'Olsen',    '+4792345678', 'kari.olsen@example.com'),
    ('Per',    'Andersen', '+4793456789', 'per.andersen@example.com'),
    ('Lise',   'Johansen', '+4794567890', 'lise.johansen@example.com'),
    ('Erik',   'Larsen',   '+4795678901', 'erik.larsen@example.com'),
    ('Anna',   'Nilsen',   '+4796789012', 'anna.nilsen@example.com'),
    ('Marte',  'Berg',     '+4797890123', 'marte.berg@example.com'),
    ('Jonas',  'Dahl',     '+4798901234', 'jonas.dahl@example.com'),
    ('Sofie',  'Holm',     '+4799012345', 'sofie.holm@example.com'),
    ('Thomas', 'Strand',   '+4791122334', 'thomas.strand@example.com');

-- ============================================================================
-- Testdata: Stasjoner
-- ============================================================================

INSERT INTO stasjon (navn, adresse) VALUES
    ('Sentrum Stasjon',       'Karl Johans gate 1 Oslo'),
    ('Universitetet Stasjon', 'Blindern Oslo'),
    ('Grünerløkka Stasjon',   'Thorvald Meyers gate 10 Oslo'),
    ('Aker Brygge Stasjon',   'Stranden 1 Oslo'),
    ('Majorstuen Stasjon',    'Bogstadveien 50 Oslo');

-- ============================================================================
-- Testdata: Låser (20 per stasjon, totalt 100)
-- ============================================================================

INSERT INTO las (stasjon_id)
SELECT s.stasjon_id
FROM stasjon s
CROSS JOIN generate_series(1, 20);

-- ============================================================================
-- Testdata: Sykler (totalt 100)
-- ============================================================================

INSERT INTO sykkel (modell, innkjopsdato)
SELECT
    CASE (n % 5)
        WHEN 0 THEN 'City Bike Pro'
        WHEN 1 THEN 'Urban Cruiser'
        WHEN 2 THEN 'EcoBike 3000'
        WHEN 3 THEN 'SpeedRider X'
        ELSE        'ComfortBike 500'
    END,
    DATE '2023-01-01' + (n % 365) * INTERVAL '1 day'
FROM generate_series(1, 100) AS n;

-- ============================================================================
-- Testdata: Utleier (totalt 50)
-- ============================================================================

INSERT INTO utleie (
    kunde_id, sykkel_id,
    start_stasjon_id, slutt_stasjon_id,
    start_las_id, slutt_las_id,
    utleie_tidspunkt, innlevert_tidspunkt,
    belop
)
SELECT
    (n % 10) + 1,
    (n % 100) + 1,
    (n % 5) + 1,
    ((n + 2) % 5) + 1,
    (n % 100) + 1,
    ((n + 10) % 100) + 1,
    TIMESTAMP '2023-06-01 08:00:00' + (n * INTERVAL '3 days'),
    TIMESTAMP '2023-06-01 09:00:00' + (n * INTERVAL '3 days'),
    (n % 10) * 5.0 + 10.0
FROM generate_series(0, 49) AS n;

-- ============================================================================
-- Tilgangskontroll
-- ============================================================================

CREATE ROLE kunde_rolle;
GRANT SELECT ON kunde, sykkel, stasjon, las, utleie TO kunde_rolle;

CREATE USER kunde_1 WITH PASSWORD 'kunde123';
GRANT kunde_rolle TO kunde_1;

-- ============================================================================
-- Indekser for ytelse
-- ============================================================================

CREATE INDEX idx_utleie_kunde    ON utleie(kunde_id);
CREATE INDEX idx_utleie_sykkel   ON utleie(sykkel_id);
CREATE INDEX idx_utleie_start    ON utleie(start_stasjon_id);
CREATE INDEX idx_utleie_slutt    ON utleie(slutt_stasjon_id);
CREATE INDEX idx_las_stasjon     ON las(stasjon_id);

-- ============================================================================
SELECT 'Database initialisert!' AS status;
