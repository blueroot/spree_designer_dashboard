function saveProductToBoard(board_id, product_id, x, y, z, w, h){
	var url = '/board_products'
	var posting = $.post( url, {board_product: {product_id: product_id, board_id: board_id, top_left_x: x, top_left_y: y, z_index: z, width: w, height: h}} );

	  /* Put the results in a div */
	  posting.done(function( data ) {
		//alert('saved!')
		getSavedProducts(board_id);
	    //var content = $( data ).find( '#content' );
	    //$( "#result" ).empty().append( content );
	  });
}

function showProductAddedState(){
	$('#product-preview-details').addClass('hidden');
	$('#product-preview-added').removeClass('hidden');
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

function handleProductPopover(el){		
	
	$('a.button-product-info').popover({ 
	    html : true,
	    content: function() {
				$('.button-product-info').popover('hide');
	      return $('#'+$(this).data('popoverContainer')).html();
	    }
	  });
	//el.find('a.button-product-info').click(function() {
	//	//$(this).popover('show')
	//	$('.button-product-info').popover('hide');
	//	
	//	selector = '#'+$(this).data('popoverContainer')
	//	//alert($(selector).html())
	//	$(this).popover({ 
	//	    html : true,
	//	    content: function() {
	//		
	//	      return $(selector).html();
	//	    }
	//	  });
	//});
}

function selectItem(el){
	$('.board-lightbox-product-cloned').find('img').removeClass('board-product-selected');
	$('.board-lightbox-product-cloned').find('a.button-remove-product').hide();
	$('.board-lightbox-product-cloned').find('a.button-product-info').hide();
	el.find('img').addClass('board-product-selected')
	el.find('a.button-remove-product').show();
	el.find('a.button-product-info').show();
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
	saveProductToBoard($('#board-canvas').data('boardId'),cloned.data('productId'), cloned.position().left, cloned.position().top, cloned.css('z-index'), cloned.width(), cloned.height());		
	
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
