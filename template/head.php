<?php session_start();
 require "logic/utils.php";
 require "template/t_functions.php";

function head($title){
 echo '<!DOCTYPE html>
<html lang="en-gb" dir="ltr" class="uk-height-1-1">

    <head>
        <meta charset="utf-8">
        <title>'.$title.'</title>
        <link rel="stylesheet" href="css/uikit.css">
        <link rel="stylesheet" href="css/style.css">
        <link rel="stylesheet" href="css/jquery-ui.min.css">
        <script src="js/jquery.min.js"></script>
        <script src="js/uikit.min.js"></script>
        <script src="js/jquery-ui.min.js"></script>
        <script src="js/script.js"></script>
    </head>';
  }
?>
