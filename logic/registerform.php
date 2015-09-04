<?php require "logic/connect.php"; session_start();
  function paramvalid($array, $method){
    $valid = true;
    foreach($array as $value){
      $valid = $valid && isset($method[$value]) && !empty($method[$value]);
    }
    return $valid;
  }

  if(paramvalid(array("user","pass","email"), $_POST)){
    $user=$_POST["user"];
    $pass=$_POST["pass"];
    $email=$_POST["email"];
    $query = "INSERT INTO utente(username, password, email) VALUES ('$user','$pass','$email');";
    $result = pg_query($conn, $query);

    if($result){
      $_SESSION["user"]=$user;
      //modal_window("","setTimeout(function(){window.location = '/interests.php'},0);");
      header("Location: register.php?interests=true");
    }else{
      header("Location: register.php?error=true");
    }
  }
?>
