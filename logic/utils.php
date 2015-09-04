<?php
  function arevalid($array, $method){
    $valid = true;
    foreach($array as $value){
      $valid = $valid && isset($method[$value]) && !empty($method[$value]);
    }
    return $valid;
  }
?>
