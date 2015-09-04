<?php
require "logic/connect.php";
  if(arevalid(array("sond_ans"), $_POST)){
    if(isset($_POST["anon"])){
      $query = "INSERT INTO votosondaggio(risposta, utente, anon) VALUES ({$_POST["sond_ans"]},'{$_SESSION["user"]}','true')";
    }else{
      $query = "INSERT INTO votosondaggio(risposta,utente) VALUES ({$_POST["sond_ans"]},'{$_SESSION["user"]}')";
    }
    $result = pg_query($conn, $query);
  }
?>
