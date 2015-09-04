$(document).ready(function(){
  $.datepicker.setDefaults($.datepicker.regional['it']);
	$("#date-input").datepicker();

  $("#sondaggio").hide();
  $("#sondaggio_add").click(function(e){
    e.preventDefault();
    e.stopPropagation();
    $("#sondaggio_list").append("<div class='uk-form-row'><input type='text' class='uk-width-1-1 uk-form-large' placeholder='Risposta sondaggio...' name='risps[]'></div>");
  });

  $(".vote").click(function(){
    var node = $(this).parent().parent().parent().get(0);
    node.submit();
  })

  $("#logout").click(function(){
    location.href="/logout.php";
  })

  $("#send").click(function(e){
    valid = false;
      $risps = $('input[name="risps[]"]');
      [].forEach.call($risps, function(elem, i, arr){
        if(elem.value !== ""){
          valid = true;
        }
      });

      if( $("[name='topic[]']:checked").length < 1 || ($("[name='sond']:checked")>0 && !valid) || $("input[name=text]").val() === ""){
        alert("Inserisci una domanda e scegli almeno una categoria. Se è un sondaggio inserisci almeno una risposta");
        e.preventDefault();
        e.stopPropagation();
      }
  });

  $('#is_sondaggio:checkbox').change(
    function(){
        if ($(this).is(':checked')) {
            $("#sondaggio").toggle("slow");
        }else{
            $("#sondaggio").toggle("slow");
        }
    });

    $(document).on('keydown',function(e){
      if($("input[name=text]").val() === ""){
        notvalid($("input[name=text]"));
      }else{
        valid($("input[name=text]"));
      }
    });

    function notvalid($node){
      $node.addClass("uk-form-danger");
      $node.removeClass("uk-form-success");
    }

    function valid($node){
      $node.removeClass("uk-form-danger");
      $node.addClass("uk-form-success");
    };
});
