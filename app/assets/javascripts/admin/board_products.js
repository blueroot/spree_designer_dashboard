

$(function() {


/*
/
/  PAGE SETUP
/
*/
  $(".ok").tooltip();
  $(".remove-button").tooltip();
  $(".save").tooltip();

  $(".btn").popover();

  $(".sixteen").removeClass("sixteen");
/*
/
/  APPROVE AND REJECT BUTTONS
/
*/
  $(".rejected").css("background-color", "#F2DEDE");
  $(".rejected").css("color", "#E82C0C");

  $(".marked_for_deletion").css("background-color", "#F2DEDE");
  $(".marked_for_deletion").css("color", "#E82C0C");

  $(".approved").css("background-color", "#D9EDF7");
  $(".approved").css("color", "#5498DA");

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

  $(".glyphicon-ok").click(function(e){

    board_product_id = $(this).attr("data-board-product-id");
    product_id = $(this).attr("data-product-id");

    $(".board-product-tile[data-board-product-id="+board_product_id+"]").removeClass("pending");
    $(".board-product-tile[data-board-product-id="+board_product_id+"]").removeClass("rejected");
    $(".board-product-tile[data-board-product-id="+board_product_id+"]").removeClass("active");
    $(".board-product-tile[data-board-product-id="+board_product_id+"]").removeClass("marked_for_deletion");

    $(".board-product-tile[data-board-product-id="+board_product_id+"]").addClass("approved");

    $(".approved").css("background-color", "#D9EDF7");
    $(".approved").css("color", "#5498DA");

    $(this).css("color", "#5498da");
    $(this).css("background-color", "#D9EDF7");

    $(".rejected.glyphicon-ban-circle[data-board-product-id="+board_product_id+"]").removeClass("rejected");

    $(".glyphicon-ban-circle[data-board-product-id="+board_product_id+"]").css("color","black");
    $(".glyphicon-ban-circle[data-board-product-id="+board_product_id+"]").css("background-color","#D9EDF7");

    $(".glyphicon-remove[data-board-product-id="+board_product_id+"]").css("color","black");
    $(".glyphicon-remove[data-board-product-id="+board_product_id+"]").css("background-color","#D9EDF7");

    $("#board_product_"+board_product_id+"_status").val("approved");

    $(".glyphicon-floppy-disk[data-board-product-id="+board_product_id+"]").click();

    if(document.URL.split('/')[4].split('#')[0] === "boards"){

      board_id = $(this).attr("data-board-id");

      console.log(board_id);
      calculate_board_stats(board_id);
      $("li.publication[data-product-id="+product_id+"]").remove();
      $("li.revision[data-product-id="+product_id+"]").remove();

    }

  });

  $(".glyphicon-ban-circle").click(function(e){

    board_product_id = $(this).attr("data-board-product-id");
    console.log("removing board_product with id == " + board_product_id);

    $(".board-product-tile[data-board-product-id="+board_product_id+"]").addClass("rejected");
    $(".board-product-tile[data-board-product-id="+board_product_id+"]").removeClass("pending");
    $(".board-product-tile[data-board-product-id="+board_product_id+"]").removeClass("approved");
    $(".board-product-tile[data-board-product-id="+board_product_id+"]").removeClass("active");
    $(".board-product-tile[data-board-product-id="+board_product_id+"]").removeClass("marked_for_deletion");

    $(".rejected").css("background-color", "#F2DEDE");
    $(".rejected").css("color", "#E82C0C");

    $(this).css("color", "#E82C0C");
    $(this).css("background-color", "#F2DEDE");

    $(".approved.glyphicon-ok[data-board-product-id="+board_product_id+"]").removeClass("approved");

    $(".glyphicon-ok[data-board-product-id="+board_product_id+"]").css("color","black");
    $(".glyphicon-ok[data-board-product-id="+board_product_id+"]").css("background-color","#F2DEDE");

    $(".glyphicon-remove[data-board-product-id="+board_product_id+"]").css("color","black");
    $(".glyphicon-remove[data-board-product-id="+board_product_id+"]").css("background-color","#F2DEDE");

    $("#board_product_"+board_product_id+"_status").val("rejected");
    
    $(".glyphicon-floppy-disk[data-board-product-id="+board_product_id+"]").click();
    
    if(document.URL.split('/')[4].split('#')[0] === "boards"){

      var board_id = $(this).attr("data-board-id");

      console.log(board_id);
      calculate_board_stats(board_id);

      // add the product to the list of removed products for publication and revision
      //figure out the product tname
      var name = $(".product-name[data-board-product-id="+board_product_id+"]").val();

      $("ul.removed-on-publication[data-board-id="+board_id+"]").append("<li class = 'list-group-item publication' data-product-id='"+product_id+"'>"+name+"</li>")
      $("ul.removed-on-revision[data-board-id="+board_id+"]").append("<li class = 'list-group-item revision' data-product-id='"+product_id+"'>"+name+"</li>")
    }

  });

  $(".glyphicon-remove").click(function(e){
    board_product_id = $(this).attr("data-board-product-id");
    console.log("Completely deleting product associated with board product" + board_product_id);

    board_product_id = $(this).attr("data-board-product-id");

    $(".board-product-tile[data-board-product-id="+board_product_id+"]").addClass("marked_for_deletion");
    $(".board-product-tile[data-board-product-id="+board_product_id+"]").removeClass("rejected");
    $(".board-product-tile[data-board-product-id="+board_product_id+"]").removeClass("pending");
    $(".board-product-tile[data-board-product-id="+board_product_id+"]").removeClass("approved");
    $(".board-product-tile[data-board-product-id="+board_product_id+"]").removeClass("active");

    $(".marked_for_deletion").css("background-color", "#F2DEDE");
    $(".marked_for_deletion").css("color", "#E82C0C");

    $(this).css("color", "#E82C0C");
    $(this).css("background-color", "#F2DEDE");

    $(".glyphicon-ok[data-board-product-id="+board_product_id+"]").css("background-color","#F2DEDE");
    $(".glyphicon-ok[data-board-product-id="+board_product_id+"]").css("color","black");

    $(".glyphicon-ban-circle[data-board-product-id="+board_product_id+"]").css("background-color","#F2DEDE");
    $(".glyphicon-ban-circle[data-board-product-id="+board_product_id+"]").css("color","black");

    $("#board_product_"+board_product_id+"_status").val("marked_for_deletion");
    
    $(".glyphicon-floppy-disk[data-board-product-id="+board_product_id+"]").click();
    
    if(document.URL.split('/')[4].split('#')[0] === "boards"){

      board_id = $(this).attr("data-board-id");

      console.log(board_id);
      calculate_board_stats(board_id);
    }

  });

  $(".glyphicon-floppy-disk").click(function(e){
    board_product_id =  $(this).attr("data-board-product-id");
    product_id       =  $(this).attr("data-product-id");
    board_id         =  $(this).attr("data-board-id");
    variant_id       =  $(this).attr("data-variant-id");
    stock_item_id    =  $(this).attr("data-stock-item-id");

    // create the necessary json objects
    var back_orderable = $("#variant_"+variant_id+"_backorderable").is(':checked')

    stock_item = {
      count_on_hand: $("#variant_"+variant_id+"_inventory").val(),
      supplier_count_on_hand: $("#variant_"+variant_id+"_supplier_inventory").val(),
      backorderable: back_orderable
    }

    variant = {
      map_price:       $("#variant_"+variant_id+"_map_price").val(),
      msrp_price:      $("#variant_"+variant_id+"_msrp_price").val(),
      shipping_height: $("#variant_"+variant_id+"_shipping_height_actual").val(),
      shipping_width:  $("#variant_"+variant_id+"_shipping_width_actual").val(),
      shipping_depth:  $("#variant_"+variant_id+"_shipping_depth_actual").val(),
      height: $("#variant_"+variant_id+"_product_height_actual").val(),
      width: $("#variant_"+variant_id+"_product_width_actual").val(),
      depth: $("#variant_"+variant_id+"_product_depth_actual").val(),
      days_to_ship: $("#variant_"+variant_id+"_days_to_ship").val()
    };

    product =  {
      name:       $("#product_"+product_id+"_name").val(),
      sku:        $("#product_"+product_id+"_sku").val(),
      price:      $("#product_"+product_id+"_price").val(),
      cost_price: $("#product_"+product_id+"_cost_price").val(),
    };
    
    board_product = {
      status: $("#board_product_"+board_product_id+"_status").val(),
    };

    console.log(board_product);
    console.log(stock_item);
    console.log(variant);
    console.log(product);

    $.ajax({
      type: "PUT",
      url: "/admin/board_products.json",
      contentType: "application/json",
      data: JSON.stringify({ 
        id: board_product_id, 
        product_id: product_id, 
        variant_id: variant_id,
        stock_item_id: stock_item_id,
        board_product: board_product,
        product: product,
        variant: variant,
        stock_item: stock_item
      })
    })
    .done(function(data){
      console.log(data);
    });

  });


/*
/
/  FILTERS
/
*/

  $("select#status").change(function(e){
    status = $(this).val();
    if( status == "All products"){
      $(".board-product-tile").show();
    }
    else{
      $(".board-product-tile").each( function( index, element ){
        if($(this).hasClass(status.toLowerCase())){
          $(this).show();
        }
        else{
          $(this).hide();
        }

      });
    }
  });

  $("select#suppliers").change(function(e){
    supplier_id = $(this).val();
		if (supplier_id == "0"){
			window.location.href = "/admin/board_products"
		}
		else{
			window.location.href = "/admin/board_products?supplier_id="+supplier_id;
		}
    

  });
/*
/
/  SHIPPING DIMENSIONS
/
*/
  $(".shipping-dimension-button").click(function(){
    variant_id = $(this).attr("class").split(" ")[4];

    console.log(variant_id);

    $("#variant_"+variant_id+"_shipping_height").val( $("#variant_"+variant_id+"_shipping_height_actual").val() );
    $("#variant_"+variant_id+"_shipping_width").val( $("#variant_"+variant_id+"_shipping_width_actual").val() );
    $("#variant_"+variant_id+"_shipping_depth").val( $("#variant_"+variant_id+"_shipping_depth_actual").val() );

    $('#variant_'+variant_id+'_shipping_height').on('input',function(e){
      old_dimensions = $("#variant_"+variant_id+"_shipping_dimensions").html().split(" x ");
      console.log("old dimensions: " + old_dimensions);

      old_dimensions[0] = $(this).val();
      new_dimensions = old_dimensions.join(" x ");

      $("#variant_"+variant_id+"_shipping_dimensions").html(new_dimensions);

      $("#variant_"+variant_id+"_shipping_height_actual").val($(this).val());
    });

    $('#variant_'+variant_id+'_shipping_width').on('input',function(e){
      old_dimensions = $("#variant_"+variant_id+"_shipping_dimensions").html().split(" x ");
      old_dimensions[1] = $(this).val();
      new_dimensions = old_dimensions.join(" x ");
      $("#variant_"+variant_id+"_shipping_dimensions").html(new_dimensions);

      $("#variant_"+variant_id+"_shipping_width_actual").val($(this).val());
    });

    $('#variant_'+variant_id+'_shipping_depth').on('input',function(e){
      old_dimensions = $("#variant_"+variant_id+"_shipping_dimensions").html().split(" x ");
      old_dimensions[2] = $(this).val();
      new_dimensions = old_dimensions.join(" x ");
      $("#variant_"+variant_id+"_shipping_dimensions").html(new_dimensions);

      $("#variant_"+variant_id+"_shipping_depth_actual").val($(this).val());
    });
  });


  $(".product-dimension-button").click(function(){
    variant_id = $(this).attr("class").split(" ")[4];

    console.log(variant_id);

    $("#variant_"+variant_id+"_product_height").val( $("#variant_"+variant_id+"_product_height_actual").val() );
    $("#variant_"+variant_id+"_product_width").val( $("#variant_"+variant_id+"_product_width_actual").val() );
    $("#variant_"+variant_id+"_product_depth").val( $("#variant_"+variant_id+"_product_depth_actual").val() );

    $('#variant_'+variant_id+'_product_height').on('input',function(e){
      old_dimensions = $("#variant_"+variant_id+"_product_dimensions").html().split(" x ");
      console.log("old dimensions: " + old_dimensions);

      old_dimensions[0] = $(this).val();
      new_dimensions = old_dimensions.join(" x ");

      $("#variant_"+variant_id+"_product_dimensions").html(new_dimensions);

      $("#variant_"+variant_id+"_product_height_actual").val($(this).val());
    });

    $('#variant_'+variant_id+'_product_width').on('input',function(e){
      old_dimensions = $("#variant_"+variant_id+"_product_dimensions").html().split(" x ");
      old_dimensions[1] = $(this).val();
      new_dimensions = old_dimensions.join(" x ");
      $("#variant_"+variant_id+"_product_dimensions").html(new_dimensions);

      $("#variant_"+variant_id+"_product_width_actual").val($(this).val());
    });

    $('#variant_'+variant_id+'_product_depth').on('input',function(e){
      old_dimensions = $("#variant_"+variant_id+"_product_dimensions").html().split(" x ");
      old_dimensions[2] = $(this).val();
      new_dimensions = old_dimensions.join(" x ");
      $("#variant_"+variant_id+"_product_dimensions").html(new_dimensions);

      $("#variant_"+variant_id+"_product_depth_actual").val($(this).val());
    });
  });
});
