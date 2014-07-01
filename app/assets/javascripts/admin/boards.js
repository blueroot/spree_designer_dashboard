
$(function() {

  $('#state').val("Submitted for Publication");
  

  $('.modal').appendTo("body");

  $(".delete-board").click(function(e){ 
    board_id = parseInt($(this).attr("class").split(" ")[1])

    $.ajax({
      type: "PUT",
      url: "/admin/boards/"+board_id+".json",
      contentType: "application/json",
      data: JSON.stringify({ 
        id: board_id, 
        state: "deleted"
      })
    }).done(function(data){
      console.log(data);
    });
  });

  $(".revise-board").click(function(e){ 
    board_id = parseInt($(this).attr("class").split(" ")[1])

    $.ajax({
      type: "PUT",
      url: "/admin/boards/"+board_id+".json",
      contentType: "application/json",
      data: JSON.stringify({ 
        id: board_id, 
        state: "request_revision"
      })
    }).done(function(data){
      console.log(data);
    });
  });

  $(".published").css("background-color", "#D9EDF7");
  $(".published").css("color", "#5498DA");

  $(".publish-board").click(function(e){ 
    board_id = parseInt($(this).attr("class").split(" ")[1])

    $.ajax({
      type: "PUT",
      url: "/admin/boards/"+board_id+".json",
      contentType: "application/json",
      data: JSON.stringify({ 
        id: board_id, 
        state: "publish"
      })
    }).done(function(data){
      console.log(data);
    });

    $(".board-"+board_id).css("background-color", "#D9EDF7");
    $(".board-"+board_id).css("color", "#5498DA");
    
  });



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

  $('#state').change();
});
