<?php
include "logic/registerform.php"; 
require "template/head.php";
  head("Registrati - Q&A");
?>
<body class="uk-height-1-1">
  <?php

    if(isset($_GET["error"])){
      register_window("ERROR: Utente già presente");
    }else if(isset($_GET["interests"])){
      interests_window();
    }else{
      register_window();
    }
  ?>
</body>
<?php include "template/foot.php"; ?>
