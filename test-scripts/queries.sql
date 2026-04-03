-- ============================================================================
-- DATA1500 - Oblig 1: Testspørringer
-- ============================================================================

-- Kjør med: docker exec -it data1500-postgres psql -U admin -d oblig01 -P pager=off -f /test-scripts/queries.sql

-- ============================================================================
-- Oppgave 5.1: Hent alle sykler
-- ============================================================================

SELECT * FROM sykkel;

-- ============================================================================
-- Oppgave 5.2: Etternavn, fornavn og mobilnr for alle kunder, sortert på etternavn
-- ============================================================================

SELECT
    etternavn,
    fornavn,
    mobilnr
FROM kunde
ORDER BY etternavn ASC;

-- ============================================================================
-- Oppgave 5.3: Sykler tatt i bruk etter 1. april 2023
-- ============================================================================

SELECT
    s.sykkel_id,
    s.modell,
    u.utleie_tidspunkt
FROM sykkel s
JOIN utleie u ON s.sykkel_id = u.sykkel_id
WHERE u.utleie_tidspunkt > '2023-04-01';

-- ============================================================================
-- Oppgave 5.4: Totalt antall kunder i ordningen
-- ============================================================================

SELECT COUNT(*) AS antall_kunder
FROM kunde;

-- ============================================================================
-- Oppgave 5.5: Alle kunder med antall utleieforhold (inkl. kunder uten utleier)
-- ============================================================================

SELECT
    k.fornavn,
    k.etternavn,
    COUNT(u.utleie_id) AS antall_utleier
FROM kunde k
LEFT JOIN utleie u ON k.kunde_id = u.kunde_id
GROUP BY k.kunde_id, k.fornavn, k.etternavn
ORDER BY antall_utleier DESC;

-- ============================================================================
-- Oppgave 5.6: Kunder som aldri har leid sykkel
-- ============================================================================

SELECT
    k.fornavn,
    k.etternavn,
    k.epost
FROM kunde k
LEFT JOIN utleie u ON k.kunde_id = u.kunde_id
WHERE u.utleie_id IS NULL;

-- ============================================================================
-- Oppgave 5.7: Sykler som aldri har vært utleid
-- ============================================================================

SELECT
    s.sykkel_id,
    s.modell,
    s.innkjopsdato
FROM sykkel s
LEFT JOIN utleie u ON s.sykkel_id = u.sykkel_id
WHERE u.utleie_id IS NULL;

-- ============================================================================
-- Oppgave 5.8: Sykler ikke levert tilbake innen ett døgn, med kundeinformasjon
-- ============================================================================

SELECT
    s.sykkel_id,
    s.modell,
    k.fornavn,
    k.etternavn,
    k.mobilnr,
    u.utleie_tidspunkt,
    u.innlevert_tidspunkt
FROM utleie u
JOIN sykkel s ON s.sykkel_id = u.sykkel_id
JOIN kunde  k ON k.kunde_id  = u.kunde_id
WHERE
    (
        u.innlevert_tidspunkt IS NULL
        AND u.utleie_tidspunkt < NOW() - INTERVAL '1 day'
    )
    OR
    (
        u.innlevert_tidspunkt - u.utleie_tidspunkt > INTERVAL '1 day'
    );

-- ============================================================================
SELECT 'Spørringer fullført!' AS status;

-- Kjør med: docker-compose exec postgres psql -h -U admin -d data1500_db -f test-scripts/queries.sql
