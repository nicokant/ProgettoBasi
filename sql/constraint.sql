
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
