
--
-- Name: argomentodomanda; Type: TABLE; Schema: prova; Owner: postgres; Tablespace:
--

CREATE TABLE argomentodomanda (
    domanda integer NOT NULL,
    categoria integer NOT NULL
);


ALTER TABLE argomentodomanda OWNER TO postgres;

--
-- Name: cat_id; Type: SEQUENCE; Schema: prova; Owner: postgres
--

CREATE SEQUENCE cat_id
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    NO MAXVALUE
    CACHE 1;


ALTER TABLE cat_id OWNER TO postgres;

--
-- Name: categoria; Type: TABLE; Schema: prova; Owner: postgres; Tablespace:
--

CREATE TABLE categoria (
    id integer DEFAULT nextval('cat_id'::regclass) NOT NULL,
    titolo text NOT NULL
);


ALTER TABLE categoria OWNER TO postgres;

--
-- Name: dom_id; Type: SEQUENCE; Schema: prova; Owner: postgres
--

CREATE SEQUENCE dom_id
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dom_id OWNER TO postgres;

--
-- Name: domanda; Type: TABLE; Schema: prova; Owner: postgres; Tablespace:
--

CREATE TABLE domanda (
    id integer DEFAULT nextval('dom_id'::regclass) NOT NULL,
    testo text NOT NULL,
    link text,
    autore text NOT NULL,
    descrizione text,
    sondaggio boolean DEFAULT false NOT NULL,
    open boolean DEFAULT true NOT NULL
);


ALTER TABLE domanda OWNER TO postgres;

--
-- Name: COLUMN domanda.sondaggio; Type: COMMENT; Schema: prova; Owner: postgres
--

COMMENT ON COLUMN domanda.sondaggio IS 'false -> dirette, true -> sondaggio';


--
-- Name: interesse; Type: TABLE; Schema: prova; Owner: postgres; Tablespace:
--

CREATE TABLE interesse (
    utente text NOT NULL,
    categoria integer NOT NULL
);


ALTER TABLE interesse OWNER TO postgres;

--
-- Name: rdir_id; Type: SEQUENCE; Schema: prova; Owner: postgres
--

CREATE SEQUENCE rdir_id
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE rdir_id OWNER TO postgres;

--
-- Name: rispostadiretta; Type: TABLE; Schema: prova; Owner: postgres; Tablespace:
--

CREATE TABLE rispostadiretta (
    id integer DEFAULT nextval('rdir_id'::regclass) NOT NULL,
    autore text NOT NULL,
    domanda integer NOT NULL,
    testo text NOT NULL,
    data timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE rispostadiretta OWNER TO postgres;

--
-- Name: rson_id; Type: SEQUENCE; Schema: prova; Owner: postgres
--

CREATE SEQUENCE rson_id
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE rson_id OWNER TO postgres;

--
-- Name: rispostasondaggio; Type: TABLE; Schema: prova; Owner: postgres; Tablespace:
--
CREATE TABLE rispostasondaggio (
    id integer DEFAULT nextval('rson_id'::regclass) NOT NULL,
    domanda integer NOT NULL,
    testo text NOT NULL
);


ALTER TABLE rispostasondaggio OWNER TO postgres;

--
-- Name: sottocategoria; Type: TABLE; Schema: prova; Owner: postgres; Tablespace:
--

CREATE TABLE sottocategoria (
    categoriapadre integer NOT NULL,
    categoriafiglio integer NOT NULL
);


ALTER TABLE sottocategoria OWNER TO postgres;

--
-- Name: utente; Type: TABLE; Schema: prova; Owner: postgres; Tablespace:
--

CREATE TABLE utente (
    username text NOT NULL,
    email text NOT NULL,
    password text NOT NULL,
    punteggio integer DEFAULT 0 NOT NULL,
    datanascita text,
    residenza text,
    vip boolean DEFAULT false
);


ALTER TABLE utente OWNER TO postgres;

--
-- Name: votosondaggio; Type: TABLE; Schema: prova; Owner: postgres; Tablespace:
--

CREATE TABLE votosondaggio (
    utente text NOT NULL,
    risposta integer NOT NULL,
    anon boolean DEFAULT false NOT NULL,
    sondaggio integer NOT NULL
);


ALTER TABLE votosondaggio OWNER TO postgres;

--
-- Name: voti_sondaggio; Type: VIEW; Schema: prova; Owner: postgres
--

CREATE VIEW voti_sondaggio AS
 SELECT r.id,
    count(v.utente) AS voti
   FROM (rispostasondaggio r
     LEFT JOIN ( SELECT votosondaggio.utente,
            votosondaggio.risposta
           FROM votosondaggio) v ON ((r.id = v.risposta)))
  GROUP BY r.id
  ORDER BY count(v.utente) DESC;


ALTER TABLE voti_sondaggio OWNER TO postgres;

--
-- Name: votorisposta; Type: TABLE; Schema: prova; Owner: postgres; Tablespace:
--

CREATE TABLE votorisposta (
    utente text NOT NULL,
    risposta integer NOT NULL,
    destinatario text NOT NULL,
    punteggio boolean DEFAULT true NOT NULL
);


ALTER TABLE votorisposta OWNER TO postgres;


--
-- FUNCTIONS
--

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

--
--  ADD CONSTRAINTS
--


--
-- Name: Utente_email_key; Type: CONSTRAINT; Schema: prova; Owner: postgres; Tablespace:
--

ALTER TABLE ONLY utente
    ADD CONSTRAINT "Utente_email_key" UNIQUE (email);


--
-- Name: Utente_pkey; Type: CONSTRAINT; Schema: prova; Owner: postgres; Tablespace:
--

ALTER TABLE ONLY utente
    ADD CONSTRAINT "Utente_pkey" PRIMARY KEY (username);


--
-- Name: argomentodomandechiave; Type: CONSTRAINT; Schema: prova; Owner: postgres; Tablespace:
--

ALTER TABLE ONLY argomentodomanda
    ADD CONSTRAINT argomentodomandechiave PRIMARY KEY (domanda, categoria);


--
-- Name: categoria_pkey; Type: CONSTRAINT; Schema: prova; Owner: postgres; Tablespace:
--

ALTER TABLE ONLY categoria
    ADD CONSTRAINT categoria_pkey PRIMARY KEY (id);


--
-- Name: categoria_titolo_key; Type: CONSTRAINT; Schema: prova; Owner: postgres; Tablespace:
--

ALTER TABLE ONLY categoria
    ADD CONSTRAINT categoria_titolo_key UNIQUE (titolo);


--
-- Name: domanda_pkey; Type: CONSTRAINT; Schema: prova; Owner: postgres; Tablespace:
--

ALTER TABLE ONLY domanda
    ADD CONSTRAINT domanda_pkey PRIMARY KEY (id);


--
-- Name: interessechiave; Type: CONSTRAINT; Schema: prova; Owner: postgres; Tablespace:
--

ALTER TABLE ONLY interesse
    ADD CONSTRAINT interessechiave PRIMARY KEY (utente, categoria);


--
-- Name: rispostadiretta_pkey; Type: CONSTRAINT; Schema: prova; Owner: postgres; Tablespace:
--

ALTER TABLE ONLY rispostadiretta
    ADD CONSTRAINT rispostadiretta_pkey PRIMARY KEY (id);
ALTER TABLE ONLY rispostadiretta
    ADD CONSTRAINT is_diretta CHECK ((false = domanda_is_sondaggio(domanda)));

ALTER TABLE ONLY rispostadiretta
    ADD CONSTRAINT question_open CHECK ((true = domanda_is_open(domanda)));
--
-- Name: rispostasondaggio_pkey; Type: CONSTRAINT; Schema: prova; Owner: nicokant; Tablespace:
--

ALTER TABLE ONLY rispostasondaggio
    ADD CONSTRAINT rispostasondaggio_pkey PRIMARY KEY (id);
ALTER TABLE ONLY rispostasondaggio
    ADD CONSTRAINT is_sondaggio CHECK ((true = domanda_is_sondaggio(domanda)));
ALTER TABLE ONLY rispostasondaggio
    ADD CONSTRAINT question_open CHECK ((true = domanda_is_open(domanda)));

--
-- Name: sottocategoriachiave; Type: CONSTRAINT; Schema: prova; Owner: postgres; Tablespace:
--

ALTER TABLE ONLY sottocategoria
    ADD CONSTRAINT sottocategoriachiave PRIMARY KEY (categoriapadre, categoriafiglio);


ALTER TABLE ONLY sottocategoria
    ADD CONSTRAINT only_a_father CHECK ((fathers(categoriafiglio) < 1));


--
-- Name: votorisposta_pkey; Type: CONSTRAINT; Schema: prova; Owner: postgres; Tablespace:
--

ALTER TABLE ONLY votorisposta
    ADD CONSTRAINT votorisposta_pkey PRIMARY KEY (utente, risposta);

ALTER TABLE ONLY votorisposta
  ADD CONSTRAINT same_user CHECK ((utente <> destinatario));
--
-- Name: votosondaggiochiave; Type: CONSTRAINT; Schema: prova; Owner: postgres; Tablespace:
--

ALTER TABLE ONLY votosondaggio
    ADD CONSTRAINT votosondaggiochiave PRIMARY KEY (utente, sondaggio);


--
-- Name: cascade_preferences; Type: TRIGGER; Schema: prova; Owner: postgres
--

CREATE TRIGGER cascade_preferences AFTER INSERT OR UPDATE ON interesse FOR EACH ROW EXECUTE PROCEDURE cascade_interests();


--
-- Name: get_dest; Type: TRIGGER; Schema: prova; Owner: postgres
--

CREATE TRIGGER get_dest BEFORE INSERT ON votorisposta FOR EACH ROW EXECUTE PROCEDURE autoget_dest();


--
-- Name: poll; Type: TRIGGER; Schema: prova; Owner: postgres
--

CREATE TRIGGER poll BEFORE INSERT ON votosondaggio FOR EACH ROW EXECUTE PROCEDURE point_to_poll();


--
-- Name: update_user_punteggio; Type: TRIGGER; Schema: prova; Owner: postgres
--

CREATE TRIGGER update_user_punteggio AFTER INSERT ON votorisposta FOR EACH ROW EXECUTE PROCEDURE update_user_punteggio();


--
-- Name: update_user_punteggio; Type: TRIGGER; Schema: prova; Owner: postgres
--

CREATE TRIGGER update_user_punteggio AFTER INSERT ON rispostadiretta FOR EACH ROW EXECUTE PROCEDURE update_user_punteggio2();


--
-- Name: argomentodomandeidcategoria; Type: FK CONSTRAINT; Schema: prova; Owner: postgres
--

ALTER TABLE ONLY argomentodomanda
    ADD CONSTRAINT argomentodomandeidcategoria FOREIGN KEY (categoria) REFERENCES categoria(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: argomentodomandeiddomanda; Type: FK CONSTRAINT; Schema: prova; Owner: postgres
--

ALTER TABLE ONLY argomentodomanda
    ADD CONSTRAINT argomentodomandeiddomanda FOREIGN KEY (domanda) REFERENCES domanda(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: autoredomanda; Type: FK CONSTRAINT; Schema: prova; Owner: postgres
--

ALTER TABLE ONLY domanda
    ADD CONSTRAINT autoredomanda FOREIGN KEY (autore) REFERENCES utente(username) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: interessecategoria; Type: FK CONSTRAINT; Schema: prova; Owner: postgres
--

ALTER TABLE ONLY interesse
    ADD CONSTRAINT interessecategoria FOREIGN KEY (categoria) REFERENCES categoria(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: interesseutente; Type: FK CONSTRAINT; Schema: prova; Owner: postgres
--

ALTER TABLE ONLY interesse
    ADD CONSTRAINT interesseutente FOREIGN KEY (utente) REFERENCES utente(username) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: rdirautore; Type: FK CONSTRAINT; Schema: prova; Owner: postgres
--

ALTER TABLE ONLY rispostadiretta
    ADD CONSTRAINT rdirautore FOREIGN KEY (autore) REFERENCES utente(username) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: rdirdomanda; Type: FK CONSTRAINT; Schema: prova; Owner: postgres
--

ALTER TABLE ONLY rispostadiretta
    ADD CONSTRAINT rdirdomanda FOREIGN KEY (domanda) REFERENCES domanda(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: sondaggio; Type: FK CONSTRAINT; Schema: prova; Owner: nicokant
--

ALTER TABLE ONLY rispostasondaggio
    ADD CONSTRAINT sondaggio FOREIGN KEY (domanda) REFERENCES domanda(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: sottocategoriafiglio; Type: FK CONSTRAINT; Schema: prova; Owner: postgres
--

ALTER TABLE ONLY sottocategoria
    ADD CONSTRAINT sottocategoriafiglio FOREIGN KEY (categoriafiglio) REFERENCES categoria(id) ON UPDATE CASCADE ON DELETE CASCADE;

--
-- Name: sottocategoriapadre; Type: FK CONSTRAINT; Schema: prova; Owner: postgres
--

ALTER TABLE ONLY sottocategoria
    ADD CONSTRAINT sottocategoriapadre FOREIGN KEY (categoriapadre) REFERENCES categoria(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: votorispostaautore; Type: FK CONSTRAINT; Schema: prova; Owner: postgres
--

ALTER TABLE ONLY votorisposta
    ADD CONSTRAINT votorispostaautore FOREIGN KEY (utente) REFERENCES utente(username) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: votorispostadestinatario; Type: FK CONSTRAINT; Schema: prova; Owner: postgres
--

ALTER TABLE ONLY votorisposta
    ADD CONSTRAINT votorispostadestinatario FOREIGN KEY (destinatario) REFERENCES utente(username) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: votorispostaid; Type: FK CONSTRAINT; Schema: prova; Owner: postgres
--

ALTER TABLE ONLY votorisposta
    ADD CONSTRAINT votorispostaid FOREIGN KEY (risposta) REFERENCES rispostadiretta(id) ON UPDATE CASCADE ON DELETE CASCADE;

--
-- Name: votosondaggioautore; Type: FK CONSTRAINT; Schema: prova; Owner: postgres
--

ALTER TABLE ONLY votosondaggio
    ADD CONSTRAINT votosondaggioautore FOREIGN KEY (utente) REFERENCES utente(username) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: votosondaggiorisp; Type: FK CONSTRAINT; Schema: prova; Owner: postgres
--

ALTER TABLE ONLY votosondaggio
    ADD CONSTRAINT votosondaggiorisp FOREIGN KEY (risposta) REFERENCES rispostasondaggio(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: votosondaggiosondaggio; Type: FK CONSTRAINT; Schema: prova; Owner: postgres
--

ALTER TABLE ONLY votosondaggio
    ADD CONSTRAINT votosondaggiosondaggio FOREIGN KEY (sondaggio) REFERENCES domanda(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- INSERT DATA
--

INSERT INTO utente VALUES ('rbono', 'abcd@ef.it', '3.14', 0, '03/04/2014', NULL, false);
INSERT INTO utente VALUES ('nadia.c', 'nadia.corvino@gmail.com', 'qazwsxedc', -1, NULL, NULL, false);
INSERT INTO utente VALUES ('nico', 'niccolocantu@gmail.com', 'a', 4, NULL, NULL, true);
INSERT INTO utente VALUES ('tizio', 'tizio@gmail.com', 'a', -1, '06/17/2014', 'Pianeta di Re Kaio', false);
INSERT INTO utente VALUES ('al90', 'al90@msn.it', 'a', 0, NULL, 'la Terra di Al', false);
INSERT INTO utente VALUES ('bender', 'robot34@ct.it', 'a', -1, NULL, NULL, false);

INSERT INTO categoria VALUES (4, 'musica');
INSERT INTO categoria VALUES (5, 'informatica');
INSERT INTO categoria VALUES (6, 'videogames');
INSERT INTO categoria VALUES (7, 'calcio');
INSERT INTO categoria VALUES (8, 'sport');
INSERT INTO categoria VALUES (9, 'basket');
INSERT INTO categoria VALUES (10, 'viaggi');
INSERT INTO categoria VALUES (11, 'italia');

INSERT INTO sottocategoria VALUES (5, 6);
INSERT INTO sottocategoria VALUES (10, 11);
INSERT INTO sottocategoria VALUES (8, 9);
INSERT INTO sottocategoria VALUES (8, 7);

INSERT INTO domanda VALUES (34, 'Chi va al concerto di caparezza??', 'http://clubtenco.it/wp/wp-content/uploads/2014/11/24685.jpg', 'nico', 'una capa rezza', false, true);
INSERT INTO domanda VALUES (35, 'Dove vi piacerebbe di più andare al mare?', 'http://www.valentinapaiotta.it/wp-content/uploads/2015/03/vacanze.jpg', 'nico', 'vacanzeee!!!', true, true);
INSERT INTO domanda VALUES (36, 'Chi sono gli ultimi acquisti della Juve?', '', 'tizio', '', false, true);
INSERT INTO domanda VALUES (37, 'Quale tipo di videogiochi vi piacciono?', '', 'tizio', '', true, true);
INSERT INTO domanda VALUES (38, 'In che città si mangia meglio?', 'http://www.nextquotidiano.it/wp-content/uploads/2015/02/export-italia.jpg', 'al90', '', true, true);
INSERT INTO domanda VALUES (39, 'Su che canale del digitale posso seguire il basket italiano?', 'http://www.nbapassion.com/wp-content/uploads/2015/07/Lega-Basket-A.jpg', 'al90', '', false, true);
INSERT INTO domanda VALUES (40, 'Dove scarico la beta di Firefox?', '', 'bender', '', false, true);
INSERT INTO domanda VALUES (41, 'Mi consigliate una marca per il pc nuovo?', '', 'bender', '', false, true);

INSERT INTO argomentodomanda VALUES (34, 4);
INSERT INTO argomentodomanda VALUES (35, 10);
INSERT INTO argomentodomanda VALUES (35, 11);
INSERT INTO argomentodomanda VALUES (36, 7);
INSERT INTO argomentodomanda VALUES (37, 6);
INSERT INTO argomentodomanda VALUES (38, 11);
INSERT INTO argomentodomanda VALUES (39, 9);
INSERT INTO argomentodomanda VALUES (39, 11);
INSERT INTO argomentodomanda VALUES (40, 5);
INSERT INTO argomentodomanda VALUES (41, 5);

INSERT INTO interesse VALUES ('nico', 4);
INSERT INTO interesse VALUES ('nico', 6);
INSERT INTO interesse VALUES ('nico', 8);
INSERT INTO interesse VALUES ('nico', 9);
INSERT INTO interesse VALUES ('nico', 10);
INSERT INTO interesse VALUES ('nico', 7);
INSERT INTO interesse VALUES ('nico', 11);
INSERT INTO interesse VALUES ('tizio', 4);
INSERT INTO interesse VALUES ('tizio', 5);
INSERT INTO interesse VALUES ('tizio', 7);
INSERT INTO interesse VALUES ('tizio', 11);
INSERT INTO interesse VALUES ('tizio', 6);
INSERT INTO interesse VALUES ('al90', 9);
INSERT INTO interesse VALUES ('al90', 11);
INSERT INTO interesse VALUES ('bender', 5);
INSERT INTO interesse VALUES ('bender', 9);
INSERT INTO interesse VALUES ('bender', 6);
INSERT INTO interesse VALUES ('rbono', 5);
INSERT INTO interesse VALUES ('rbono', 6);
INSERT INTO interesse VALUES ('rbono', 8);
INSERT INTO interesse VALUES ('rbono', 10);
INSERT INTO interesse VALUES ('rbono', 11);
INSERT INTO interesse VALUES ('rbono', 9);
INSERT INTO interesse VALUES ('rbono', 7);
INSERT INTO interesse VALUES ('nadia.c', 4);
INSERT INTO interesse VALUES ('nadia.c', 10);
INSERT INTO interesse VALUES ('nadia.c', 11);

INSERT INTO rispostadiretta VALUES (16, 'tizio', 34, 'Buu Caparezza!!!', '2015-08-13 00:33:47.170591');
INSERT INTO rispostadiretta VALUES (17, 'bender', 39, 'e che ne so io?', '2015-08-13 00:49:12.674792');
INSERT INTO rispostadiretta VALUES (18, 'nico', 39, 'prova a cercare su google!', '2015-08-13 00:51:55.456469');
INSERT INTO rispostadiretta VALUES (19, 'nico', 39, 'credo sulla tv satellitare', '2015-08-13 00:53:11.90812');
INSERT INTO rispostadiretta VALUES (20, 'nico', 36, 'C. Ronaldo e Messi ahahahaah', '2015-08-13 00:54:00.377946');
INSERT INTO rispostadiretta VALUES (21, 'nico', 34, 'Sarai Bannato per questo!', '2015-08-13 00:54:28.395353');
INSERT INTO rispostadiretta VALUES (22, 'nico', 36, 'vogliamo Gotze!', '2015-08-13 00:55:33.557935');
INSERT INTO rispostadiretta VALUES (23, 'nico', 39, 'meglio il calcio però', '2015-08-13 01:04:33.476691');
INSERT INTO rispostadiretta VALUES (25, 'nico', 40, 'sul sito di Mozilla', '2015-08-13 01:11:33.555096');
INSERT INTO rispostadiretta VALUES (26, 'nadia.c', 34, 'Nessunooooooo bleaaahhh', '2015-08-15 17:40:21.12211');

INSERT INTO rispostasondaggio VALUES (25, 35, 'Italia - Toscana');
INSERT INTO rispostasondaggio VALUES (26, 35, 'Caraibi');
INSERT INTO rispostasondaggio VALUES (27, 35, 'Grecia');
INSERT INTO rispostasondaggio VALUES (28, 35, 'Hawaii');
INSERT INTO rispostasondaggio VALUES (29, 37, 'FPS');
INSERT INTO rispostasondaggio VALUES (30, 37, 'RPG');
INSERT INTO rispostasondaggio VALUES (31, 37, 'MMORPG');
INSERT INTO rispostasondaggio VALUES (32, 37, 'Arcade');
INSERT INTO rispostasondaggio VALUES (33, 37, 'Retrò');
INSERT INTO rispostasondaggio VALUES (34, 38, 'Milano');
INSERT INTO rispostasondaggio VALUES (35, 38, 'Firenze');
INSERT INTO rispostasondaggio VALUES (36, 38, 'Roma');

INSERT INTO votorisposta VALUES ('al90', 18, 'nico', true);
INSERT INTO votorisposta VALUES ('bender', 21, 'nico', true);
INSERT INTO votorisposta VALUES ('tizio', 19, 'nico', true);
INSERT INTO votorisposta VALUES ('bender', 22, 'nico', false);
INSERT INTO votorisposta VALUES ('tizio', 20, 'nico', true);
INSERT INTO votorisposta VALUES ('bender', 18, 'nico', false);
INSERT INTO votorisposta VALUES ('tizio', 21, 'nico', true);
INSERT INTO votorisposta VALUES ('al90', 23, 'nico', true);
INSERT INTO votorisposta VALUES ('nico', 16, 'tizio', false);
INSERT INTO votorisposta VALUES ('nico', 17, 'bender', false);
INSERT INTO votorisposta VALUES ('nico', 26, 'nadia.c', false);

INSERT INTO votosondaggio VALUES ('nico', 25, false, 35);
INSERT INTO votosondaggio VALUES ('tizio', 27, true, 35);
INSERT INTO votosondaggio VALUES ('tizio', 30, false, 37);
INSERT INTO votosondaggio VALUES ('al90', 35, false, 38);
INSERT INTO votosondaggio VALUES ('al90', 25, false, 35);
INSERT INTO votosondaggio VALUES ('bender', 29, false, 37);
INSERT INTO votosondaggio VALUES ('nico', 35, false, 38);
INSERT INTO votosondaggio VALUES ('nico', 32, true, 37);
INSERT INTO votosondaggio VALUES ('rbono', 35, false, 38);
INSERT INTO votosondaggio VALUES ('rbono', 32, true, 37);
INSERT INTO votosondaggio VALUES ('nadia.c', 35, false, 38);
INSERT INTO votosondaggio VALUES ('nadia.c', 28, false, 35);

SELECT pg_catalog.setval('cat_id', 11, true);
SELECT pg_catalog.setval('dom_id', 41, true);
SELECT pg_catalog.setval('rdir_id', 26, true);
SELECT pg_catalog.setval('rson_id', 36, true);
