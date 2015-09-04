CREATE FUNCTION autoget_dest() RETURNS trigger
    LANGUAGE plpgsql
    AS $$DECLARE row text;
BEGIN

FOR row IN (SELECT autore FROM rispostadiretta WHERE id=NEW.risposta)
LOOP
  NEW.destinatario=row;
END LOOP;

RETURN NEW;
END;$$;


ALTER FUNCTION autoget_dest() OWNER TO postgres;

--
-- Name: cascade_interests(); Type: FUNCTION; Schema: -; Owner: postgres
--

CREATE FUNCTION cascade_interests() RETURNS trigger
    LANGUAGE plpgsql
    AS $$DECLARE row integer;
BEGIN
 FOR row IN (
  WITH RECURSIVE indirect_scat(padre, figlio) AS (
   SELECT categoriafiglio AS figlio, categoriapadre AS padre FROM sottocategoria
   UNION ALL
   SELECT s.categoriapadre, s.categoriafiglio FROM sottocategoria AS s, indirect_scat AS ind WHERE s.categoriafiglio=ind.padre
  )
  SELECT DISTINCT figlio FROM indirect_scat WHERE padre = NEW.categoria INTERSECT SELECT categoriafiglio FROM sottocategoria WHERE categoriapadre = NEW.categoria)
 LOOP
  IF NOT EXISTS(SELECT * FROM interesse AS i WHERE i.utente=NEW.utente AND i.categoria=row) THEN
   INSERT INTO interesse VALUES(NEW.utente,row);
  END IF;
 END LOOP;
 RETURN NEW;
END;$$;


ALTER FUNCTION cascade_interests() OWNER TO postgres;

--
-- Name: FUNCTION cascade_interests(); Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON FUNCTION cascade_interests() IS '/**/
/**/';


--
-- Name: domanda_is_open(integer); Type: FUNCTION; Schema: -; Owner: postgres
--

CREATE FUNCTION domanda_is_open(question_id integer) RETURNS boolean
    LANGUAGE sql
    AS $$SELECT open FROM domanda WHERE domanda.id = question_id$$;


ALTER FUNCTION domanda_is_open(question_id integer) OWNER TO postgres;

--
-- Name: domanda_is_sondaggio(integer); Type: FUNCTION; Schema: -; Owner: postgres
--

CREATE FUNCTION domanda_is_sondaggio(question_id integer) RETURNS boolean
    LANGUAGE sql
    AS $$SELECT sondaggio FROM domanda WHERE domanda.id = question_id$$;


ALTER FUNCTION domanda_is_sondaggio(question_id integer) OWNER TO postgres;

--
-- Name: fathers(integer); Type: FUNCTION; Schema: -; Owner: postgres
--

CREATE FUNCTION fathers(son_id integer) RETURNS integer
    LANGUAGE sql
    AS $$SELECT cast((SELECT count(categoriapadre) FROM sottocategoria WHERE son_id=categoriafiglio) AS integer)$$;


ALTER FUNCTION fathers(son_id integer) OWNER TO postgres;

--
-- Name: new_punteggio(text); Type: FUNCTION; Schema: -; Owner: postgres
--

CREATE FUNCTION new_punteggio(user_id text) RETURNS integer
    LANGUAGE sql
    AS $$SELECT CAST((SELECT count(risposta) FROM votorisposta V WHERE V.destinatario = user_id and V.punteggio = 'true')-(SELECT count(risposta) FROM votorisposta V WHERE V.destinatario = user_id and V.punteggio = 'false') as integer)$$;


ALTER FUNCTION new_punteggio(user_id text) OWNER TO postgres;

--
-- Name: point_to_poll(); Type: FUNCTION; Schema: -; Owner: postgres
--

CREATE FUNCTION point_to_poll() RETURNS trigger
    LANGUAGE plpgsql
    AS $$DECLARE row int;
BEGIN

FOR row IN (SELECT domanda FROM rispostasondaggio WHERE id=NEW.risposta)
LOOP
  NEW.sondaggio=row;
END LOOP;

RETURN NEW;
END;$$;


ALTER FUNCTION point_to_poll() OWNER TO postgres;

--
-- Name: update_user_punteggio(); Type: FUNCTION; Schema: -; Owner: postgres
--

CREATE FUNCTION update_user_punteggio() RETURNS trigger
    LANGUAGE plpgsql
    AS $$BEGIN
 PERFORM updatePunteggio(NEW.destinatario);
 UPDATE utente SET vip='true' WHERE punteggio>=0 AND (SELECT count(*) FROM rispostadiretta WHERE NEW.destinatario=autore)>5 AND NEW.destinatario=username;
 RETURN NEW;
END;$$;


ALTER FUNCTION update_user_punteggio() OWNER TO postgres;

--
-- Name: FUNCTION update_user_punteggio(); Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON FUNCTION update_user_punteggio() IS 'UPDATE utente as u SET vip=''true'' WHERE punteggio>=0 AND (SELECT count(*) FROM rispostadiretta AS r WHERE =r.autore)>5;
UPDATE utente SET vip=''true'' WHERE punteggio>=0 AND (SELECT count(*) FROM rispostadiretta WHERE user=autore)>5;';


--
-- Name: update_user_punteggio2(); Type: FUNCTION; Schema: -; Owner: postgres
--

CREATE FUNCTION update_user_punteggio2() RETURNS trigger
    LANGUAGE plpgsql
    AS $$BEGIN
 PERFORM updatePunteggio(NEW.autore);
 UPDATE utente SET vip='true' WHERE punteggio>=0 AND (SELECT count(*) FROM rispostadiretta WHERE NEW.autore=autore)>5 AND NEW.autore=username;
 RETURN NEW;
END;$$;


ALTER FUNCTION update_user_punteggio2() OWNER TO postgres;

--
-- Name: updatepunteggio(text); Type: FUNCTION; Schema: -; Owner: postgres
--

CREATE FUNCTION updatepunteggio(uid text) RETURNS void
    LANGUAGE sql
    AS $$UPDATE utente
SET punteggio = new_punteggio(uid)
WHERE utente.username = uid;$$;


ALTER FUNCTION updatepunteggio(uid text) OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;
