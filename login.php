<?php include "logic/loginform.php"; ?>
<?php require "template/head.php";
  head("Login - Q&A");
?>
<body class="uk-height-1-1">
  <?php
  if(isset($_GET["error"])){
    login_window("ERROR: password or username incorrect");
  }else{
    login_window();
  }
 ?>
</body>
<?php include "template/foot.php"; ?>
