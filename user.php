<?php
  include "logic/connect.php";

  if(arevalid(array("date"),$_POST)){
    $query = "UPDATE utente SET datanascita = '{$_POST["date"]}' WHERE username='{$_SESSION["user"]}'";
    $result = pg_query($conn,$query);
  }
  if(arevalid(array("res"),$_POST)){
    $query = "UPDATE utente SET residenza = '{$_POST["res"]}' WHERE username='{$_SESSION["user"]}'";
    $result = pg_query($conn,$query);
  }

  if(isset($_GET["user"]) && $_GET["user"] !== $_SESSION["user"]){
    $query = "SELECT * FROM utente WHERE username='{$_GET["user"]}'";
    $myself=pg_fetch_array(pg_query($conn,$query),0);
    echo "<div class=\"uk-vertical-align uk-text-center uk-height-1-1\">
      <div class=\"uk-vertical-align-middle\" style=\"width: 600px;\">
      <div class='uk-panel uk-panel-space'>
      <h2>{$myself["username"]}</h2>
      <p>email: {$myself["email"]}</p>
      <p>punteggio: {$myself["punteggio"]}</p>";
      if($myself["vip"] === 't'){
        echo "<p>E' un utente VIP!</p>";
      }
      if(isset($myself["residenza"])){
        echo "<p>Residente a {$myself["residenza"]}</p>";
      }else{
        echo "<p>Residente a Sconosciuto</p>";
      }
      if(isset($myself["datanascita"])){
        echo "<p>Nato il {$myself["datanascita"]}</p>";
      }else{
        echo "<p>Nato il Sconosciuto</p>";
      }
      echo "<a class='uk-button uk-button-primary uk-button-large' href='index.php?user={$_SESSION["user"]}'>Mio profilo</a></div></div></div>";
  }else{
    $query = "SELECT * FROM utente WHERE username='{$_SESSION["user"]}'";
    $myself=pg_fetch_array(pg_query($conn,$query),0);
    echo "<div class=\"uk-vertical-align uk-text-center uk-height-1-1\">
      <div class=\"uk-vertical-align-middle\" style=\"width: 600px;\">
      <div class='uk-panel uk-panel-space'>
      <h2>{$myself["username"]}</h2>
      <p>email: {$myself["email"]}</p>
      <p>punteggio: {$myself["punteggio"]}</p>";
      if($myself["vip"] === 't'){
        echo "<p>E' un utente VIP!</p>";
      }
      if(isset($myself["residenza"])){
        echo "<p>Residente a {$myself["residenza"]}</p>";
      }else{
        echo "<form class='uk-form uk-form-large' action='index.php' method='post'>
          <div class='uk-panel uk-panel-space'>
          <div class='uk-form-row'><input type='text' name='res' placeholder='residenza'><button class='uk-button uk-button-primary uk-form-large'>Salva</button></div>
        </div></form>";
      }
      if(isset($myself["datanascita"])){
        echo "<p>Nato il {$myself["datanascita"]}</p>";
      }else{
        echo "<form class='uk-form uk-form-large' action='index.php' method='post'>
        <div class='uk-panel uk-panel-space'>
          <div class='uk-form-row'><input id='date-input' type='text' name='date' placeholder='Data di nascita'><button class='uk-button uk-button-primary uk-form-large'>Salva</button></div>
        </div></form>";
      }
      echo "</div></div></div>";
  }
?>
)
