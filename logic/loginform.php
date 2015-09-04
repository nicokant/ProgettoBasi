<?php require "logic/connect.php"; session_start();
  function paramvalid($array, $method){
    $valid = true;
    foreach($array as $value){
      $valid = $valid && isset($method[$value]) && !empty($method[$value]);
    }
    return $valid;
  }

  if(paramvalid(array("user","pass"), $_POST)){
    $user=$_POST["user"];
    $pass=$_POST["pass"];
    $query = "SELECT username FROM utente WHERE username='$user' and password='$pass'";
    $result = pg_query($conn, $query);
    //var_dump($result, pg_fetch_array($result, 0));
    if($result && pg_fetch_array($result, 0)){
      $_SESSION["user"]=$user;
      header("Location: index.php");
    }else{
      header("Location: login.php?error=true");
    }
  }
?>
