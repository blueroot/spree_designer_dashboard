

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

  $(".approved").css("background-color", "#D9EDF7");
  $(".approved").css("color", "#5498DA");

  $(".glyphicon-ok").click(function(e){
    board_product_id = $(this).attr("class").split(" ")[2];
    console.log("approving board_product with id == " + board_product_id);

    $(".board_product_"+board_product_id).removeClass("pending");
    $(".board_product_"+board_product_id).removeClass("rejected");
    $(".board_product_"+board_product_id).addClass("approved");

    $(".approved").css("background-color", "#D9EDF7");
    $(".approved").css("color", "#5498DA");

    $(this).css("color", "#5498da");
    $(this).css("background-color", "#D9EDF7");


    $(".glyphicon-remove."+board_product_id).css("color","black");
    $(".glyphicon-remove."+board_product_id).css("background-color","#D9EDF7");


  });

  $(".glyphicon-remove").click(function(e){
    board_product_id = $(this).attr("class").split(" ")[2];
    console.log("removing board_product with id == " + board_product_id);

    $(".board_product_"+board_product_id).addClass("rejected");
    $(".board_product_"+board_product_id).removeClass("pending");
    $(".board_product_"+board_product_id).removeClass("approved");

    $(".rejected").css("background-color", "#F2DEDE");
    $(".rejected").css("color", "#E82C0C");

    $(this).css("color", "#E82C0C");
    $(this).css("background-color", "#F2DEDE");

    $(".glyphicon-ok."+board_product_id).css("color","black");
    $(".glyphicon-ok."+board_product_id).css("background-color","#F2DEDE");


  });

  $(".glyphicon-floppy-disk").click(function(e){
    classes = $(this).attr("class").split(" ");

    board_product_id = classes[2];
    product_id       = classes[3];
    board_id         = classes[4];
    variant_id       = classes[5];

    // create the necessary json objects
    product =  {
      name:       $("#product_"+product_id+"_name").val(),
      sku:        $("#product_"+product_id+"_sku").val(),
      price:      $("#product_"+product_id+"_price").val(),
      cost_price: $("#product_"+product_id+"_cost_price").val()
    };

    variant = {
      map_price:       $("#variant_"+variant_id+"_map_price").val(),
      msrp_price:      $("#variant_"+variant_id+"_msrp_price").val(),
      shipping_height: $("#variant_"+variant_id+"_shipping_height_actual").val(),
      shipping_width:  $("#variant_"+variant_id+"_shipping_width_actual").val(),
      shipping_depth:  $("#variant_"+variant_id+"_shipping_depth_actual").val()
    };


    // ajax them to the server
    console.log(JSON.stringify(product));
    console.log(JSON.stringify(variant));

    // display error or success messages
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
    supplier = $(this).val();
    if( supplier == "All suppliers"){
      $(".board-product-tile").show();
    }
    else{
      $(".board-product-tile").each( function( index, element ){
        if($(this).hasClass(supplier)){
          $(this).show();
        }
        else{
          $(this).hide();
        }

      });
    }
  });
/*
/
/  SHIPPING DIMENSIONS
/
*/
  $(".dimension-button").click(function(){
    variant_id = $(this).attr("class").split(" ")[4];

    console.log(variant_id);

    $("#variant_"+variant_id+"_shipping_height").val( $("#variant_"+variant_id+"_shipping_height_actual").val() );
    $("#variant_"+variant_id+"_shipping_width").val( $("#variant_"+variant_id+"_shipping_width_actual").val() );
    $("#variant_"+variant_id+"_shipping_depth").val( $("#variant_"+variant_id+"_shipping_depth_actual").val() );

    $('#variant_'+variant_id+'_shipping_height').on('input',function(e){
      old_dimensions = $("#variant_"+variant_id+"_dimensions").html().split(" x ");
      console.log("old dimensions: " + old_dimensions);

      old_dimensions[0] = $(this).val();
      new_dimensions = old_dimensions.join(" x ");

      $("#variant_"+variant_id+"_dimensions").html(new_dimensions);

      $("#variant_"+variant_id+"_shipping_height_actual").val($(this).val());
    });

    $('#variant_'+variant_id+'_shipping_width').on('input',function(e){
      old_dimensions = $("#variant_"+variant_id+"_dimensions").html().split(" x ");
      old_dimensions[1] = $(this).val();
      new_dimensions = old_dimensions.join(" x ");
      $("#variant_"+variant_id+"_dimensions").html(new_dimensions);

      $("#variant_"+variant_id+"_shipping_width_actual").val($(this).val());
    });

    $('#variant_'+variant_id+'_shipping_depth').on('input',function(e){
      old_dimensions = $("#variant_"+variant_id+"_dimensions").html().split(" x ");
      old_dimensions[2] = $(this).val();
      new_dimensions = old_dimensions.join(" x ");
      $("#variant_"+variant_id+"_dimensions").html(new_dimensions);

      $("#variant_"+variant_id+"_shipping_depth_actual").val($(this).val());
    });
  });


});
