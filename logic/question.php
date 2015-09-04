<?php
require "logic/connect.php";
  if(arevalid(array("text","topic"),$_POST)){
    $id= NULL;
    if($_POST["sond"] !== NULL){
      $query = "INSERT INTO domanda(testo, autore, link, descrizione,sondaggio) VALUES ('{$_POST["text"]}','{$_SESSION["user"]}','{$_POST["image"]}','{$_POST["desc"]}','true') RETURNING id";
      $result = pg_query($conn, $query);
      $id=pg_fetch_array($result, 0)[0];

      $query = "INSERT INTO rispostasondaggio(domanda, testo) VALUES ";
      foreach ($_POST["risps"] as $risps) {
        if($risps !== ""){
          $query .= "($id,'$risps'),";
        }
      }
      $result = pg_query($conn, substr($query, 0, -1));

    }else{
      $query = "INSERT INTO domanda(testo, autore, link, descrizione) VALUES ('{$_POST["text"]}','{$_SESSION["user"]}','{$_POST["image"]}','{$_POST["desc"]}') RETURNING id";
      $result = pg_query($conn, $query);
      $id=pg_fetch_array($result, 0)[0];
    }

    $query = "INSERT INTO argomentodomanda VALUES ";
    foreach ($_POST["topic"] as $catid) {
      $query .= "($id,$catid),";
    }
    $result = pg_query($conn, substr($query, 0, -1));
  }

  if(arevalid(array("close"), $_POST)){
    $query = "UPDATE domanda SET open=false WHERE id={$_POST["close"]}";
    pg_query($conn, $query);
  }
?>
