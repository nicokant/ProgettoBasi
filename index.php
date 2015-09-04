<?php
 require "template/head.php";
  head("Q&A");
?>
<body class="uk-height-1-1">
  <div class="uk-grid">
  <?php
    include "logic/interests.php";
    include "logic/question.php";
    include "logic/answer.php";
    include "logic/pollvote.php";
    if(isset($_SESSION["user"])){
      //modal("WELCOME {$_SESSION['user']}!!");
      ?>
      <!--div class="uk-width-1-4"></div-->

      <div class="uk-width-1-1">
      <ul class="uk-tab" data-uk-tab data-uk-switcher="{connect:'#qa-tab-content'}">
      <li class="uk-disabled"><a>Benvenuto, <?php echo $_SESSION["user"];?></a></li>
      <li <?php if(!isset($_GET["user"])){ echo "class='uk-active' ";} ?>><a href="#all">Tutto</a></li>
      <li><a href="#">Nuova Domanda</a></li>
      <li><a href="#">Domande</a></li>
      <li><a href="#">Sondaggi</a></li>
      <li <?php if(isset($_GET["user"])){ echo "class='uk-active' ";} ?>><a  href="#">Account</a></li>
      <li><a id='logout' href="#">Logout</a></li>
      </ul>
      <ul id="qa-tab-content" class="uk-switcher">
        <li></li>
        <li class="uk-active"><div class="uk-grid"><?php get_all(); ?></div></li>
        <li><div class="uk-grid"><?php new_question_form(); ?></div></li>
        <li><div class="uk-grid"><?php get_questions(); ?></div></li>
        <li><div class="uk-grid"><?php get_polls(); ?></div></li>
        <li><?php include "user.php" ?></li>
        <li></li>
      </ul>
    </div><!--div class="uk-width-1-4"></div-->
      <?php
    }else{
      modal("","setTimeout(function(){window.location = '/login.php'},0);");
    }
  ?>
</div>
</body>
<?php include "template/foot.php"; ?>
