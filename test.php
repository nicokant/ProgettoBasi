<?php
  $conn = pg_connect ("user=nicokant password=foo dbname=qea");
  if (!$conn):
	var_dump($conn);
  ?>
    <H1>Failed connecting to postgres database</H1> <?php
    exit;
endif;
?>
<html>
<head>
</head>
<body>
  <?php $result = pg_query($conn, "SELECT cast((SELECT count(categoriapadre) FROM sottocategoria WHERE 0=categoriafiglio) AS integer);");
  var_dump($result);
  while ($row = pg_fetch_array($result)) {
    //var_dump($row);
    echo "$row[0]<br>";
  }
   ?>
</body>
</html>
