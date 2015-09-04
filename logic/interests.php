<?php require "logic/connect.php";
  if(arevalid(array("interessi"), $_POST)){
    $query = "INSERT INTO interesse VALUES ";
    foreach ($_POST["interessi"] as $catid) {
      $query .= "('{$_SESSION['user']}',$catid),";
    }
    $result = pg_query($conn, substr($query, 0, -1));
  }

  /* RECURSIVE -> KILL APACHE
     $query = "SELECT * FROM categoria EXCEPT SELECT id, titolo FROM categoria AS c JOIN sottocategoria AS s ON c.id = s.categoriafiglio";
    $result = pg_query($conn, $query);

    if($result && pg_fetch_array($result, 0)){
      $compose = "<ul>";
      while($cat = pg_fetch_array($result)){
        $compose .= printSubcategories($cat, $conn);
      }
      $compose.= "</ul>";
    }
    //register_window();
    echo $compose;
  //}

  function printSubcategories($cat, $db){
    $query = "SELECT DISTINCT id, titolo FROM categoria AS c JOIN sottocategoria AS s ON c.id = s.categoriafiglio and categoriapadre = {$cat["id"]}";
    $result = pg_query($db, $query);
    if($result){
      if(pg_fetch_array($result, 0)){
        $compose = "<li data-cat-id='{$cat["id"]}'>{$cat["titolo"]}<ul>";
        while($row = pg_fetch_array($result)){
          $compose .= printSubcategories($cat, $db);
        }
        return $compose."</ul></li>";
      }else{
        return "<li data-cat-id='{$cat["id"]}'>{$cat["titolo"]}</li>";
      }
    }
  }*/
?>
