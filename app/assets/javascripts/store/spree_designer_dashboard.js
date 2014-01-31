function saveProductToBoard(board_id, product_id, x, y, z, w, h, r){
	var url = '/board_products'
	var posting = $.post( url, {board_product: {product_id: product_id, board_id: board_id, top_left_x: x, top_left_y: y, z_index: z, width: w, height: h, rotation_offset: r}} );
	  posting.done(function( data ) {
			//getSavedProducts(board_id);
	  });
}

function showProductAddedState(){
	$('#product-preview-details').addClass('hidden');
	$('#product-preview-added').removeClass('hidden');
}

function getSavedProducts(board_id){
	var url = '/rooms/'+board_id+'/board_products'
	var request = $.get( url );

	  /* Put the results in a div */
	  request.done(function( data ) {
	    //var content = $( data ).find( '#content' );
	    //$( "#result" ).empty().append( content );
	  });	
}

function getProductDetails(product_id){
	var url = '/products/'+product_id
	var request = $.get( url );

	  /* Put the results in a div */
	  request.done(function( data ) {
	    //var content = $( data ).find( '#content' );
	    //$( "#result" ).empty().append( content );
	  });	
}



function handleDragAfterDrop(el) {
	//alert('dude this is it')
      el.draggable({
        containment: '#board-canvas',
        cursor: 'move',
		snap: 'true',
        helper: 'original',
        revert: 'invalid',
		start: function(event, ui) {
	        isDraggingMedia = true;
					$('.board-lightbox-product-cloned').popover('hide');
	    },
	    stop: function(event, ui) {
					$('.board-lightbox-product-cloned').popover('hide');
	        isDraggingMedia = false;
	    }
        //snap: '#droppable'
    });
  }

function handleResizable(el){
	el.resizable({ 
		aspectRatio: el.width() / el.height(),
		helper: "original",			
		stop: function( event, ui ) {
			el.find('img').css('width', el.width())
			selectItem(el);
			saveProductToBoard($('#board-canvas').data('boardId'),el.data('productId'), el.position().left, el.position().top, el.css('z-index'), el.width(), el.height(),el.data('rotationOffset'));
			$('.board-lightbox-product-cloned').popover('hide');
		}
	});
}

function handleProductHoverable(el){
	$(el).hover(
	  function() {
	    el.find('a.button-remove-product').show();
	  }, function() {
	    el.find('a.button-remove-product').hide();
	  }
	);
}

function handleSelectable(el){		
	el.mouseup(function() {
		selectItem(el);
	});
}

function handleStackable(){		
	el = $('.board-product-selected').first().parent();
	id = el.parent().data('boardProductId')
	arr = getBoardProductsArray();
	$("#bp-move-forward").click(function() {
		
	});
	$("#bp-move-backward").click(function() {
		
	});
	$("#bp-move-front").click(function() {
		
	});
	$("#bp-move-back").click(function() {
		$.map( arr, function( value, index ) {
		   if (value.id == id){
			
		}
		
		});
		
	});
}



function handleRotatable(){		
	$("#bp-rotate-left").click(function() {
		el = $('.board-product-selected').first();
		var offset_val = el.parent().data('rotationOffset');
		var new_offset_val = (el.parent().data('rotationOffset') + 90);
		var saved_offset_val = new_offset_val % 360;
		var rotate_command = 'rotate('+new_offset_val+'deg)'
		
		//have to get the position of the enclosing div because that is what is absolutely positioned within the canvas
		orig_x = el.parent().position().left
		orig_y = el.parent().position().top
		
		orig_width = el.width()
		orig_height = el.height()
		
		//get the center
		center_x = orig_x + orig_width/2
		center_y = orig_y + orig_height/2
		
		//swap the height and width for every 90 degree turn
		var saved_width = orig_height
		var saved_height = orig_width
		
		new_x = center_x - saved_width/2
		new_y = center_y - saved_height/2
		
		//alert('\ncenter: ' + center_x + '/' + center_y + '\norig_position: ' + orig_x + '/' + orig_y + '\norig_dimensions: ' + orig_width + '/' + orig_height + '\nsaved_dimensions: ' + saved_width + '/' + saved_height + '\nnew_position: ' + new_x + '/' + new_y )
		
		//rotate it
		el.css('transform', rotate_command);
				
		saveProductToBoard($('#board-canvas').data('boardId'),el.parent().data('productId'), new_x, new_y, el.css('z-index'), orig_width, orig_height, saved_offset_val);	
		//$(this).find('img').css('width', $(this).data('productWidth'))
		//$(this).find('img').css('height', $(this).data('productHeight'))

		el.parent().css('width', orig_height)
		el.parent().css('height', orig_width)
		
		
		//el.rotate({ animateTo:new_offset_val,callback: function(){   
		//	//alert(1);
		//	//alert(new_offset_val)
		//	//alert(new_offset_val % 360)
		//	//alert('left: '+ el.offset().left + ' top: ' +el.offset().top)
		//	//saveProductToBoard($('#board-canvas').data('boardId'),el.parent().data('productId'), el.offset().left, el.offset().top, el.css('z-index'), saved_width, saved_height, saved_offset_val);
		//}});
		
		//set the height and width of the enclosing div
		el.parent().width(saved_width)
		el.parent().height(saved_height)
		//save the new offset
		el.parent().data('rotationOffset',new_offset_val);
	
	});
}


function handleRemoveFromCanvas(el){		
	el.find('a.button-remove-product').click(function() {
		el.hide();
		var product_id = el.data('productId')
		var board_id = $('#board-canvas').data('boardId')
		var url = '/rooms/'+board_id+'/board_products/'+product_id
		$.post(url, {_method:'delete'}, null, "script");
		$('.board-lightbox-product-cloned').popover('hide');
	});
	
}

function handleProductPopover(el){		
	
	$('.board-lightbox-product-cloned').popover({ 
	    html : true,
			trigger: 'manual',
	    content: function() {
				//$('.board-lightbox-product-cloned').popover('hide');
	      return $('#'+$(this).data('popoverContainer')).html();
	    }
	});
	
	//$('a.button-product-info').popover({ 
	//    html : true,
	//    content: function() {
	//			$('.button-product-info').popover('hide');
	//      return $('#'+$(this).data('popoverContainer')).html();
	//    }
	//});
		
		

}

function showRemoveButton(el){
	//$('.board-lightbox-product-cloned').find('img').removeClass('board-product-selected');
	//$('.board-lightbox-product-cloned').find('a.button-remove-product').hide();
	//$('.board-lightbox-product-cloned').find('a.button-product-info').hide();
	//el.find('img').addClass('board-product-selected')
	//el.find('a.button-remove-product').show();
	//el.find('a.button-product-info').show();
}



function selectItem(el){

	// hide all the other popovers except for the one chosen.
	// there was a race condition if you just hid all of them without excluding the current one
	  //$('.board-lightbox-product-cloned').each(function(i, obj) {
	  //		if ($(obj).data('popoverContainer') != $(el).data('popoverContainer')){
	  //			$(obj).popover('hide');
	  //		}
	  //});
	  //$(el).popover('show')
	
	$('.board-lightbox-product-cloned').find('img').removeClass('board-product-selected');
	//$('.board-lightbox-product-cloned').find('a.button-remove-product').hide();
	//$('.board-lightbox-product-cloned').find('a.button-product-info').hide();
	el.find('img').addClass('board-product-selected')
	//el.find('a.button-remove-product').show();
	//el.find('a.button-product-info').show();
}


function handleDropEvent(event, ui) {
	//var offsetXPos = parseInt(ui.offset.left);
	var offsetYPos = parseInt(ui.offset.top);
	$(this).find('#board-canvas').remove();

	// this handles drops both from search results being dragged onto the board and from products already on the board
	
	// if it is being dragged from the search results
	if (ui.helper.hasClass('board-lightbox-product')){
		cloned = $(ui.helper).clone();
		$(this).append(cloned.removeClass('board-lightbox-product').addClass('board-lightbox-product-cloned'));
		selector = '#board-product-' + cloned.data('productId')
		$(selector).hide();
		zindex = $('.board-lightbox-product-cloned').size() + 1
		alert('search z: ' + zindex)
	}
	else{
		cloned = $(ui.helper)
		$(this).append(cloned.removeClass('board-lightbox-product').addClass('board-lightbox-product-cloned'));
		zindex = cloned.css('z-index')
		alert('existing z: ' + zindex)
	}		
	
	selectItem(cloned);
	handleDragAfterDrop(cloned);
	handleResizable(cloned);
	handleSelectable(cloned);
	handleRemoveFromCanvas(cloned);	
	saveProductToBoard($('#board-canvas').data('boardId'),cloned.data('productId'), cloned.position().left, cloned.position().top, zindex, cloned.width(), cloned.height(), cloned.data('rotationOffset'));
	
}

function getImageWidth(url){
	var img = new Image();
	img.onload = function() {
	  //return "w"
	}
	img.src = url
	return img.width
}

function getImageHeight(url){
	var img = new Image();
	img.onload = function() {
	  //return "h"
	}
	img.src = url
	return img.height
}

function handleCloneAndAddEvent(item) {
	var offsetXPos = 20;
	var offsetYPos = 20;
	
	cloned = item.clone(true);
	//alert(cloned.data('imgUrl'))
	
	cloned.appendTo( "#board-canvas" );
	if (cloned.hasClass('board-lightbox-product')){
		cloned.removeClass('board-lightbox-product').addClass('board-lightbox-product-cloned')
	}
	else{
		cloned.removeClass('board-lightbox-product').addClass('board-lightbox-product-cloned')
	}		
	
	cloned.width(getImageWidth(cloned.data('imgUrl')));
	cloned.height(getImageHeight(cloned.data('imgUrl')));
	cloned.children('img.board-lightbox-product-img').css('width', getImageWidth(cloned.data('imgUrl')))
	cloned.children('img.board-lightbox-product-img').css('height', getImageHeight(cloned.data('imgUrl')))
	cloned.css('width', getImageWidth(cloned.data('imgUrl')))
	cloned.css('height', getImageHeight(cloned.data('imgUrl')))
	//cloned.offset({ top: 20, left: 20})
	
	selectItem(cloned);
	
	//handleDragAfterDrop(cloned);
	//handleResizable(cloned);
	//handleSelectable(cloned);
	//handleRemoveFromCanvas(cloned);
	//handleProductPopover(cloned);
	//
	saveProductToBoard($('#board-canvas').data('boardId'),cloned.data('productId'), cloned.position().left, cloned.position().top, cloned.css('z-index'), cloned.width(), cloned.height(), cloned.data('rotationOffset'));		
	
}

function showProductDetails(item){
	$('#product-details-pane').html('Loading product details...')
	getProductDetails(item.data('productPermalink'))
}
function setHeight(){
	var modalHeight =  $('#product-modal').height();
	$('.select-products-box').height(modalHeight-200);
	$('.product-preview-box').height(modalHeight-200);
	
}

function getBoardProductsArray(){
	var arr = []
	$('.board-lightbox-product-cloned').each(function() {
		arr.push({id: $(this).data('boardProductId'), zindex: $(this).data('productZindex')})
	});
	return arr;
}

function layerProducts(){
	arr = getBoardProductsArray();
	
	// sort the boards according to the zindex
	arr.sort(function (a, b) {
	    if (a.zindex > b.zindex)
	      return 1;
	    if (a.zindex < b.zindex)
	      return -1;
	    // a must be equal to b
	    return 0;
	});
	
	// set the css zindex of each product on the board
	$.map( arr, function( value, index ) {
	    //alert(value.id);
			selector = "#bp"+value.id
			$(selector).css('z-index',value.zindex)
	});
	
	return arr;
}
