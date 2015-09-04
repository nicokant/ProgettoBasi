<?php
require "logic/connect.php";
  if(arevalid(array("qid"),$_GET) && arevalid(array("risp"), $_POST)){
    $query = "INSERT INTO rispostadiretta(testo, autore, domanda) VALUES ('{$_POST["risp"]}','{$_SESSION["user"]}',{$_GET["qid"]})";
    $result = pg_query($conn, $query);
  }

  if(arevalid(array("qid"),$_GET) && arevalid(array("vote"), $_POST)){
    $query = "INSERT INTO votorisposta(utente, risposta,punteggio) VALUES ('{$_SESSION["user"]}',{$_GET["qid"]},'{$_POST["vote"]}')";
    $result = pg_query($conn, $query);
  }
?>
