
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
