
$(function() {

  $("select#state").change(function(e){
    state = $(this).val();

    if( state == "All boards"){
      $(".board-tile").show();
    }
    else{
      $(".board-tile").each( function( index, element ){
        if( $(this).hasClass( state.toLowerCase().split(' ').join('_') ) ){
          $(this).show();
        }
        else{
          $(this).hide();
        }
      });
    }
  });

  $("select#designers").change(function(e){
    designer = $(this).val();
    if( designer == "All designers"){
      $(".board-tile").show();
    }
    else{
      $(".board-tile").each( function( index, element ){
        if($(this).hasClass(designer.toLowerCase().split(' ').join('_'))){
          $(this).show();
        }
        else{
          $(this).hide();
        }

      });
    }
  });
});
