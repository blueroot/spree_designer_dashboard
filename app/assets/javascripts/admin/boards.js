
$(function() {

  $('#state').val("Submitted for Publication");

  function hide_all_boards_except_submitted_for_publication(){
    $(".board-tile").each( function( index, element ){
      if( $(this).hasClass('submitted_for_publication' ) ){
        $(this).show();
      }
      else{
        $(this).hide();
      }
    });
  }

  hide_all_boards_except_submitted_for_publication();


  $('.modal').appendTo("body");

  $(".delete-board").click(function(e){ 

    board_id = $(this).attr("data-board-id");

    $(".help-block[data-board-id="+board_id+"]").html("Deleted");

    $.ajax({
      type: "PUT",
      url: "/admin/boards/"+board_id+".json",
      contentType: "application/json",
      data: JSON.stringify({ 
        id: board_id, 
        state: "deleted",
        email: {
          should_send: $(".deletion.notify-designer[data-board-id="+board_id+"]").prop("checked"),
          reason: $("textarea.deletion-reason[data-board-id="+board_id+"]").val()
        }
      })
    }).done(function(data){
      console.log(data);
    });
  });

  $(".revise-board").click(function(e){ 
    board_id = parseInt($(this).attr("class").split(" ")[1])

    $(".help-block[data-board-id="+board_id+"]").html("Needs Revision");

    $.ajax({
      type: "PUT",
      url: "/admin/boards/"+board_id+".json",
      contentType: "application/json",
      data: JSON.stringify({ 
        id: board_id, 
        state: "request_revision",
        email: {
          should_send: $(".revision.notify-designer[data-board-id="+board_id+"]").prop("checked"),
          reason: $("textarea.revision-reason[data-board-id="+board_id+"]").val()
        }
      })
    }).done(function(data){
      console.log(data);
    });
  });

  $(".published").css("background-color", "#D9EDF7");
  $(".published").css("color", "#5498DA");

  $(".publish-board").click(function(e){ 
    board_id = parseInt($(this).attr("class").split(" ")[1])

    $(".help-block[data-board-id="+board_id+"]").html("Published");

    $.ajax({
      type: "PUT",
      url: "/admin/boards/"+board_id+".json",
      contentType: "application/json",
      data: JSON.stringify({ 
        id: board_id, 
        state: "published",
        email: {
          should_send: $(".publication.notify-designer[data-board-id="+board_id+"]").prop("checked"),
          reason: $("textarea.publication-message[data-board-id="+board_id+"]").val()
        }
      })
    }).done(function(data){
      console.log(data);
    });
    
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

});
