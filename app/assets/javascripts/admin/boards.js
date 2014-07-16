
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

  function calculate_board_stats(board_id){
      //var new_stats = 
      var approved_count = $(".board-product-tile.approved[data-board-id="+board_id+"]").length;
      var rejected_count = $(".board-product-tile.rejected[data-board-id="+board_id+"]").length;
      var deleted_count = $(".board-product-tile.marked_for_deletion[data-board-id="+board_id+"]").length;

      var pending_count  = $(".board-product-tile.pending[data-board-id="+board_id+"]").length;
      var active_count   = $(".board-product-tile.active[data-board-id="+board_id+"]").length
      var total_count    = $(".board-product-tile[data-board-id="+board_id+"]").length;
      rejected_count += deleted_count;
      pending_count += active_count;

      $(".board-"+board_id+"-stats").html("contains "+total_count+" products: "+approved_count+" approved, "+rejected_count+" removed "+pending_count+" pending");
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

    $(".board-tile[data-board-id="+board_id+"]").remove();
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

    $(".board-product-tile.marked_for_deletion[data-board-id="+board_id+"]").remove();
    $(".board-product-tile.rejected[data-board-id="+board_id+"]").remove();
    calculate_board_stats(board_id);

  });

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

    $(".board-product-tile.marked_for_deletion[data-board-id="+board_id+"]").remove();
    $(".board-product-tile.rejected[data-board-id="+board_id+"]").remove();
    calculate_board_stats(board_id);
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
