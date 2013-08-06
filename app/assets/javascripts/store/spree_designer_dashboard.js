function saveProductToBoard(board_id, product_id, x, y, z, w, h){
	var url = '/board_products'
	var posting = $.post( url, {board_product: {product_id: product_id, board_id: board_id, top_left_x: x, top_left_y: y, z_index: z, width: w, height: h}} );

	  /* Put the results in a div */
	  posting.done(function( data ) {
	    var content = $( data ).find( '#content' );
	    $( "#result" ).empty().append( content );
	  });
}

function getSavedProducts(board_id){
	var url = '/boards/'+board_id+'/board_products'
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
	    },
	    stop: function(event, ui) {
	        isDraggingMedia = false;
	        // blah
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
			saveProductToBoard($('#board-canvas').data('boardId'),el.data('productId'), el.position().left, el.position().top, el.css('z-index'), el.width(), el.height());
		}
	});
}
function handleSelectable(el){		
	el.mousedown(function() {
		selectItem(el);
	});
}

function handleRemoveFromCanvas(el){		
	el.find('a.button-remove-product').click(function() {
		el.hide();
		var product_id = el.data('productId')
		var board_id = $('#board-canvas').data('boardId')
		var url = '/boards/'+board_id+'/board_products/'+product_id
		$.post(url, {_method:'delete'}, null, "script");
	});
}
function selectItem(el){
	$('.board-lightbox-product-cloned').find('img').removeClass('board-product-selected');
	$('.board-lightbox-product-cloned').find('a.button-remove-product').hide();
	el.find('img').addClass('board-product-selected')
	el.find('a.button-remove-product').show();
}


function handleDropEvent(event, ui) {
	//var offsetXPos = parseInt(ui.offset.left);
	var offsetYPos = parseInt(ui.offset.top);
	$(this).find('#board-canvas').remove();
	if (ui.helper.hasClass('board-lightbox-product')){
		cloned = $(ui.helper).clone();
		$(this).append(cloned.removeClass('board-lightbox-product').addClass('board-lightbox-product-cloned'));
	}
	else{
		cloned = $(ui.helper)
		$(this).append(cloned.removeClass('board-lightbox-product').addClass('board-lightbox-product-cloned'));
	}		
	
	selectItem(cloned);
	
	handleDragAfterDrop(cloned);
	handleResizable(cloned);
	handleSelectable(cloned);
	handleRemoveFromCanvas(cloned);
	saveProductToBoard($('#board-canvas').data('boardId'),cloned.data('productId'), cloned.position().left, cloned.position().top, cloned.css('z-index'), cloned.width(), cloned.height());		
  }