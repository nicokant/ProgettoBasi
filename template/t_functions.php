<?php
function login_window($error){
  echo "<div class=\"uk-vertical-align uk-text-center uk-height-1-1\">
  <div class=\"uk-vertical-align-middle\" style=\"width: 250px;\">
      <img class=\"uk-margin-bottom\" width=\"140\" height=\"120\" src=\"icon/qa1.png\" alt=\"\">
      <form class=\"uk-panel uk-panel-box uk-form\" action=\"login.php\" method=\"post\">
          <div class=\"uk-form-row\">
              <input name=\"user\" class=\"uk-width-1-1 uk-form-large\" type=\"text\" placeholder=\"Username\">
          </div>
          <div class=\"uk-form-row\">
              <input name=\"pass\" class=\"uk-width-1-1 uk-form-large\" type=\"password\" placeholder=\"Password\">
          </div>
          <div class=\"uk-form-row\">
              <button type=\"submit\" class=\"uk-width-1-1 uk-button uk-button-primary uk-button-large\" href=\"#\">Login</button>
          </div>
          <div class=\"uk-form-row\">
              <a class=\"uk-width-1-1\" href=\"register.php\">Registrati</a>
          </div>
      </form>";
      if($error){
        echo "<div style='color:red'>$error</div>";
      }
      echo "</div></div>";
}

function register_window($error){
  echo "<div class=\"uk-vertical-align uk-text-center uk-height-1-1\">
  <div class=\"uk-vertical-align-middle\" style=\"width: 250px;\">
      <img class=\"uk-margin-bottom\" width=\"140\" height=\"120\" src=\"icon/qa1.png\" alt=\"\">
      <form class=\"uk-panel uk-panel-box uk-form\" action=\"register.php\" method=\"post\">
          <div class=\"uk-form-row\">
              <input name=\"user\" class=\"uk-width-1-1 uk-form-large\" type=\"text\" placeholder=\"Username\">
          </div>
          <div class=\"uk-form-row\">
              <input name=\"email\" class=\"uk-width-1-1 uk-form-large\" type=\"email\" placeholder=\"Email\">
          </div>
          <div class=\"uk-form-row\">
              <input name=\"pass\" class=\"uk-width-1-1 uk-form-large\" type=\"password\" placeholder=\"Password\">
          </div>
          <div class=\"uk-form-row\">
              <button type=\"submit\" class=\"uk-width-1-1 uk-button uk-button-primary uk-button-large\" href=\"#\">Registrati</button>
          </div>
          <div class=\"uk-form-row\">
              <a class=\"uk-width-1-1\" href=\"login.php\">Login</a>
          </div>
      </form>";
      if($error){
        echo "<div style='color:red'>$error</div>";
      }
      echo "</div></div>";
}

function interests_window($error){
  require "logic/connect.php";
  echo "<div class=\"uk-vertical-align uk-text-center uk-height-1-1\">
  <div class=\"uk-vertical-align-middle\" style=\"width: 250px;\">
      <img class=\"uk-margin-bottom\" width=\"140\" height=\"120\" src=\"icon/qa1.png\" alt=\"\">
      <h1>Scegli i tuoi interessi</h1>
      <form class=\"uk-panel uk-panel-box uk-form\" action=\"index.php\" method=\"post\">";
        $query = "SELECT * FROM categoria";
        $res = pg_query($conn, $query);
        while($cat = pg_fetch_assoc($res)){
         echo "<div class=\"uk-form-row\"><div class=\"uk-width-1-1 uk-form-large\"><input type='checkbox' name='interessi[]' value='{$cat["id"]}' checked> <label>{$cat["titolo"]}</label></div></div>";
        }

        echo "
          <div class=\"uk-form-row\">
              <button type=\"submit\" class=\"uk-width-1-1 uk-button uk-button-primary uk-button-large\" href=\"#\">Continua</button>
          </div>
      </form>";
      if($error){
        echo "<div style='color:red'>$error</div>";
      }
      echo "</div></div>";
}

function modal($text, $script){
  echo "<div class=\"uk-width-medium-1-1\">
      <div class=\"uk-vertical-align uk-text-center\" style=\"background:height:300px\">
          <div class=\"uk-vertical-align-middle uk-width-1-2\">
              <p class=\"uk-text-large\">$text</p>
          </div>
      </div>
  </div>
  <script>$script</script>";
}

function new_question_form(){
  require "logic/connect.php";
  echo "<div class=\"uk-text-center uk-height-1-5 uk-panel uk-panel-space uk-panel-divider uk-width-1-1\">
  <div class=\"uk-vertical-align-middle\" style=\"width: 400px;\">
      <form class=\"uk-panel uk-panel-box uk-form uk-panel-space\" action=\"index.php\" method=\"post\">
      <div class=\"uk-form-row\"><input class=\"uk-width-1-1 uk-form-large\" name='text' type='text' placeholder='Inserisci la domanda'></div>
      <div class=\"uk-form-row\"><input class=\"uk-width-1-1 uk-form-large\" name='image' type='url' placeholder=\"Link a un'immagine\"></div>
      <div class=\"uk-form-row\"><input class=\"uk-width-1-1 uk-form-large\" name='desc' type='text' placeholder='Descrizione immagine'></div>";
        $query = "SELECT * FROM categoria JOIN interesse ON id=categoria WHERE utente='{$_SESSION["user"]}'";
        $res = pg_query($conn, $query);
        while($cat = pg_fetch_assoc($res)){
         echo "<div class=\"uk-form-row\"><div class=\"uk-width-1-1 uk-form-large\"><input type='checkbox' name='topic[]' value='{$cat["id"]}' checked> <label>{$cat["titolo"]}</label></div></div>";
        }
        echo "
        <div class=\"uk-form-row uk-panel uk-panel-space uk-text-left\"><div class=\"uk-width-1-1 uk-form-large\"><input id='is_sondaggio'type='checkbox' name='sond'><label>Sondaggio</label></div></div>
        <div id='sondaggio' class='uk-form-row'>
        <div id='sondaggio_list'>
          <div class=\"uk-form-row\">
            <input type='text' class='uk-width-1-1 uk-form-large' placeholder='Risposta sondaggio...' name='risps[]'>
          </div>
        </div>
        <div class=\"uk-form-row uk-panel uk-panel-space uk-text-left\">
          <button id='sondaggio_add' class='uk-button uk-button-primary'>aggiungi</button>
        </div>
        </div>
          <div class=\"uk-form-row\">
              <button id='send' type=\"submit\" class=\"uk-width-1-1 uk-button uk-button-primary uk-button-large\" href=\"#\">Continua</button>
          </div>
      </form></div></div>";
}

function get_questions(){
  require "logic/connect.php";
  $query = "SELECT * FROM domanda WHERE id IN (SELECT DISTINCT domanda FROM argomentodomanda WHERE categoria IN (select categoria from interesse where utente='{$_SESSION["user"]}')) AND sondaggio='f' ORDER BY id DESC";
  $res = pg_query($conn, $query);
  while($dom = pg_fetch_assoc($res)){
    echo "<div class=\"uk-text-center uk-height-1-5 uk-panel uk-panel-divider uk-width-1-1\">
    <div class=\"uk-vertical-align-middle\" style=\"width: 400px;\">
    <div data-id='{$dom["id"]}' class=\"uk-panel uk-panel-box uk-panel-box-primary\">";
    if(isset($dom["link"])){
      echo "<div class='uk-panel-teaser'><img src='{$dom["link"]}' alt='{$dom["descrizione"]}'></div>";
    }
    if($dom["autore"] === $_SESSION["user"] && $dom["open"] === 't'){
      echo "<div class='uk-grid'><p class='uk-width-3-4'>{$dom["testo"]} <br><em>by <a class='user' href='#'>{$dom["autore"]}</a></em></p>
      <form class='uk-form uk-width-1-4' action='index.php' method='post'>
      <input checked hidden value='{$dom["id"]}' name='close' type='radio'>
      <button class='uk-button uk-button-primary'>Chiudi</button>
      </form></div></div>";
    }else{
      echo "<p>{$dom["testo"]} <br><em>by {$dom["autore"]}</em></p></div>";
    }
    get_answers_to($dom["id"]);
    if($dom["open"] === 't'){
        new_answer_form($dom["id"]);
    }
    echo "</div>";
    echo "</div>";
  }
}

function get_polls(){
  require "logic/connect.php";
  $query = "SELECT * FROM domanda WHERE id IN (SELECT DISTINCT domanda FROM argomentodomanda WHERE categoria IN (select categoria from interesse where utente='{$_SESSION["user"]}')) AND sondaggio='t' ORDER BY id DESC";
  $res = pg_query($conn, $query);
  while($dom = pg_fetch_assoc($res)){
    echo "<div class=\"uk-text-center uk-height-1-5 uk-panel uk-panel-divider uk-width-1-1\">
    <div class=\"uk-vertical-align-middle\" style=\"width: 400px;\">
    <div data-id='{$dom["id"]}' class=\"uk-panel uk-panel-box uk-panel-box-primary\">";
    if(isset($dom["link"])){
      echo "<div class='uk-panel-teaser'><img src='{$dom["link"]}' alt='{$dom["descrizione"]}'></div>";
    }
    if($dom["autore"] === $_SESSION["user"] && $dom["open"] === 't'){
      echo "<div class='uk-grid'><p class='uk-width-3-4'>{$dom["testo"]} <br><em>by <a href='index.php?user={$dom["autore"]}'>{$dom["autore"]}</a></em></p>
      <form class='uk-form uk-width-1-4' action='index.php' method='post'>
      <input checked hidden value='{$dom["id"]}' name='close' type='radio'>
      <button class='uk-button uk-button-primary'>Chiudi</button>
      </form></div></div>";
    }else{
      echo "<p>{$dom["testo"]} <br><em>by {$dom["autore"]}</em></p></div>";
    }
    get_pollanswers_to($dom["id"],$dom["open"]);
    echo "</div>";
    echo "</div>";
  }
}

function get_all(){
  require "logic/connect.php";
  $query = "SELECT * FROM domanda WHERE id IN (SELECT DISTINCT domanda FROM argomentodomanda WHERE categoria IN (select categoria from interesse where utente='{$_SESSION["user"]}')) ORDER BY id DESC";
  $res = pg_query($conn, $query);
  while($dom = pg_fetch_assoc($res)){
    echo "<div class=\"uk-text-center uk-height-1-5 uk-panel uk-panel-divider uk-width-1-1\">
    <div class=\"uk-vertical-align-middle\" style=\"width: 400px;\">
    <div data-id='{$dom["id"]}' class=\"uk-panel uk-panel-box uk-panel-box-primary\">";
    if(isset($dom["link"])){
      echo "<div class='uk-panel-teaser'><img src='{$dom["link"]}' alt='{$dom["descrizione"]}'></div>";
    }
    if($dom["autore"] === $_SESSION["user"] && $dom["open"] === 't'){
      echo "<div class='uk-grid'><p class='uk-width-3-4'>{$dom["testo"]} <br><em>by <a href='index.php?user={$dom["autore"]}'>{$dom["autore"]}</a></em></p>
      <form class='uk-form uk-width-1-4' action='index.php' method='post'>
      <input checked hidden value='{$dom["id"]}' name='close' type='radio'>
      <button class='uk-button uk-button-primary'>Chiudi</button>
      </form></div></div>";
    }else{
      echo "<p>{$dom["testo"]} <br><em>by <a href='index.php?user={$dom["autore"]}'>{$dom["autore"]}</a></em></p></div>";
    }
    if($dom["sondaggio"] === 't'){
      get_pollanswers_to($dom["id"], $dom["open"]);
    }else{
      get_answers_to($dom["id"]);
      if($dom["open"] === 't'){
          new_answer_form($dom["id"]);
      }
    }
    echo "</div>";
    echo "</div>";
  }
}

function get_answers_to($id){
  require "logic/connect.php";
  $query = "SELECT vip FROM utente WHERE username='{$_SESSION["user"]}'";
  $vip=pg_fetch_array(pg_query($conn,$query),0)[0] === 't';

  $query = "SELECT * FROM rispostadiretta WHERE domanda=$id ORDER BY data ASC";
  $res = pg_query($conn, $query);
  if($res && pg_fetch_array($res,0)){
    echo '<div class="uk-panel uk-panel-space"><div class="uk-grid"><div class="uk-width-1-5"></div><ul class="uk-width-4-5 uk-comment-list">';
    while($ris = pg_fetch_assoc($res)){
      echo "<li><article class=\"uk-comment\">
      <header class='uk-comment-header uk-panel uk-panel-box'>
          <div class='uk-comment-meta'>{$ris["data"]} - <em>by <a class='user' href='index.php?user={$ris["autore"]}'>{$ris["autore"]}</a></em></div>
      </header>
      <div class='uk-comment-body'>";
      $query= "SELECT count(*) FROM votorisposta WHERE utente='{$_SESSION["user"]}' AND risposta={$ris["id"]}";
      $voted=pg_fetch_array(pg_query($conn, $query),0)[0] > 0;
      if($ris["autore"] !== $_SESSION["user"] && ! $voted && $vip){
        echo "<div class='uk-grid'>
          <div class='uk-width-2-7'>{$ris["testo"]}</div>
          <form class='uk-width-2-7' action='index.php?qid={$ris["id"]}' method='post'>
            <div class='uk-grid'>
            <div class='uk-width-1-2'><input class='vote' name='vote' type='radio' value='false'><span class='uk-icon-small uk-icon-thumbs-down'></span></div>
            <div class='uk-width-1-2'><input class='vote' name='vote' type='radio' value='true'><span class='uk-icon-small uk-icon-thumbs-up'></span></div>
          </div></form>
        </div></article></li>";
      }else if($voted){
        $query= "SELECT punteggio FROM votorisposta WHERE utente='{$_SESSION["user"]}' AND risposta={$ris["id"]}";
        $check=pg_fetch_array(pg_query($conn, $query),0)[0] === 't';
        echo "<div class='uk-grid'>
          <div class='uk-width-2-7'>{$ris["testo"]}</div>
          <form class='uk-width-2-7'>
            <div class='uk-grid'>
            <div class='uk-width-1-2'><input name='vote' type='radio' value='false'";
            if($check){echo "disabled";}else{echo "checked";}
            echo "><span class='uk-icon-small uk-icon-thumbs-down'></span></div>
            <div class='uk-width-1-2'><input name='vote' type='radio' value='true'";
            if($check){echo "checked";}else{echo "disabled";}
            echo "><span class='uk-icon-small uk-icon-thumbs-up'></span></div>
          </div></form>
        </div></article></li>";
      }else{
        echo "{$ris["testo"]}</div></article></li>";
      }
    }
    echo '</ul></div></div>';
  }
}

function get_pollanswers_to($id, $bool){
  require "logic/connect.php";
  $query = "SELECT * FROM rispostasondaggio as r JOIN voti_sondaggio as v ON r.id=v.id WHERE domanda=$id ORDER BY voti DESC";
  $res = pg_query($conn, $query);

  $query = "SELECT count(*) FROM (SELECT DISTINCT utente FROM votosondaggio AS v JOIN rispostasondaggio AS r ON v.risposta=r.id WHERE r.domanda=$id) AS p WHERE utente = '{$_SESSION["user"]}'";
  $userVoted = pg_fetch_array(pg_query($conn, $query),0)[0] > 0;

  if($res && pg_fetch_array($res,0)){
    echo '<div class="uk-panel uk-panel-space"><div class="uk-grid"><div class="uk-width-1-5"></div><form class="uk-width-4-5 uk-comment-list" action="index.php" method="post">';
    while($ris = pg_fetch_assoc($res)){
      $query2 = "SELECT utente, anon FROM votosondaggio WHERE sondaggio=$id AND risposta={$ris["id"]}";
      $votes =  pg_query($conn, $query2);
      echo "<div class=\"uk-form-row\">
        <div class=\"uk-width-1-1 uk-form-large\">";
        $anon = 0;
        $userVotedThis = false;
        $votedBy="";
        $first = true;
        if(pg_num_rows($votes) > 0){
          while ($user = pg_fetch_array($votes)) {
            if($_SESSION["user"] === $user["utente"]){
              $userVotedThis = true;
            }
            if($user["anon"] === 't'){
              $anon += 1;
            }else{
              if(!$first){
                $votedBy .= ", ";
              }
               $votedBy .= "<a href='index.php?user={$user["utente"]}'>{$user["utente"]}</a>";
            }
            if($first){
              $first = false;
            }
          }
        $votedBy .= " e $anon anonimi</em></div></div>";
      }else{
        $votedBy .= " nessuno</em></div></div>";
      }

      echo "<input type='radio' name='sond_ans' value='{$ris["id"]}'";
      if($userVotedThis){
        echo "checked";
      }else
      if($userVoted){
        echo "disabled";
      }
      echo "> <label>{$ris["testo"]}</label></div>
    <div class='uk-width-1-1 uk-panel-uk-box uk-panel-secondary'><em>Votato da: $votedBy";
    }

    if($bool === 't' && !$userVoted){
      echo "<div class=\"uk-form-row\">
      <div class='uk-grid'>
        <button class=\"uk-button uk-width-3-4 uk-button-large uk-button-primary\">Vota</button>
        <div class='uk-width-1-4'><input name='anon' type='checkbox'><label>Anonimo</label></div>
      </div>
      </div>";
    }
    echo '</form></div></div>';
  }
}

function new_answer_form($id){
  echo "<form class=\"uk-panel uk-panel-box uk-form uk-panel-space\" action=\"index.php?qid=$id\" method=\"post\">
  <div class=\"uk-form-row\">
    <input class=\"uk-width-3-5 uk-form-large\" name='risp' placeholder='Rispondi...'>
    <button type=\"submit\" class=\"uk-width-1-5 uk-button uk-button-primary uk-button-large\" href=\"#\">INVIA</button>
  </div></form>";
}
?>
