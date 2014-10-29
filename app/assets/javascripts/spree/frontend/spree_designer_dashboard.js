function initializeProductSearchForm(){
	/* attach a submit handler to the form */
	$("#product_search_form").submit(function(event) {
		/* stop form from submitting normally */
		event.preventDefault();
		
		$('#products-preloader').removeClass('hidden')
		$('#select-products-box').html('')
		/* get some values from elements on the page: */
		var $form = $( this ),
		term = $form.find( 'input[name="product_keywords"]' ).val(),
		supplier_id = $form.find( 'select[name="supplier_id"]' ).val(),
		department_taxon = $form.find( 'select[name="department_taxon"]' ).val(),
		url = $form.attr( 'action' );
		bid = $('#canvas').data('boardId')
		
		//alert(taxon);
		/* Send the data using post */
		var posting = $.post( url, { keywords: term, department_taxon_id: department_taxon, supplier_id: supplier_id, per_page: 100, board_id: bid } );

		/* Put the results in a div */
		posting.done(function( data ) {
			
			//var content = $( data ).find( '#content' );
			//$( "#result" ).empty().append( content );
		});
	});
}

function rotateObject(angleOffset) {
    var obj = canvas.getActiveObject(),
        resetOrigin = false;

    if (!obj) return;

    var angle = obj.getAngle() + angleOffset;

    if ((obj.originX !== 'center' || obj.originY !== 'center') && obj.centeredRotation) {
        obj.setOriginToCenter && obj.setOriginToCenter();
        resetOrigin = true;
    }

    angle = angle > 360 ? 90 : angle < 0 ? 270 : angle;

    obj.setAngle(angle).setCoords();

    if (resetOrigin) {
        obj.setCenterToOrigin && obj.setCenterToOrigin();
    }

    canvas.renderAll();
}

function showProductAddedState(){
	$('#product-preview-details').addClass('hidden');
	$('#product-preview-added').removeClass('hidden');
}

function updateBoardProduct(id, product_options){
	var url = '/board_products/'+id+'.json'
	
	$.ajax({
		url: url, 
		type: "POST",
		dataType: "json", 
		data: {_method:'PATCH', board_product: product_options},
	     beforeSend : function(xhr){
	       xhr.setRequestHeader("Accept", "application/json")
	     },
	     success : function(data){
				
	     },
	     error: function(objAJAXRequest, strError, errorThrown){
	       alert("ERROR: " + strError);
	     }
	  }
	);
}


fabric.Object.prototype.setOriginToCenter = function () {
    this._originalOriginX = this.originX;
    this._originalOriginY = this.originY;

    var center = this.getCenterPoint();

    this.set({
        originX: 'center',
        originY: 'center',
        left: center.x,
        top: center.y
    });
};

fabric.Object.prototype.setCenterToOrigin = function () {
    var originPoint = this.translateToOriginPoint(
    this.getCenterPoint(),
    this._originalOriginX,
    this._originalOriginY);

    this.set({
        originX: this._originalOriginX,
        originY: this._originalOriginY,
        left: originPoint.x,
        top: originPoint.y
    });
};



function buildImageLayer(canvas, bp){
	if(parseInt(bp.rotation_offset) == 90){
		real_left =  bp.height + bp.top_left_x
		real_top = bp.top_left_y
		//alert(real_left + " " + real_top)
	}else	if(parseInt(bp.rotation_offset) == 270){
		real_left = bp.top_left_x
		real_top =  bp.top_left_y + bp.width
		//alert(real_left + " " + real_top)
	}else{
		real_left = bp.top_left_x
		real_top = bp.top_left_y
	}
	
	fabric.Image.fromURL(bp.product.image_url, function(oImg) {
		oImg.scale(1).set({
		      left: bp.top_left_x,
		      top: bp.top_left_y,
		      width : bp.width,
			    height : bp.height,
					lockUniScaling: true,
					hasRotatingPoint: false
		    });
		oImg.set('id', bp.id)
		//console.log('build image: '+ bp.id)
		oImg.set('product_permalink', bp.product.slug)
		oImg.set('current_x', bp.top_left_x)
		oImg.set('current_y', bp.top_left_y)
		canvas.add(oImg);
		canvas.setActiveObject(oImg);
		rotateObject(bp.rotation_offset);
		//oImg.set('current_x', bp.top_left_x)
		//oImg.set('current_y', bp.top_left_y)
		//canvas.add(oImg);
		if(parseInt(bp.rotation_offset) == 90 || parseInt(bp.rotation_offset) == 270){
		oImg.set({
			left: real_left,
    	top: real_top})
		}
		canvas.discardActiveObject();
	});
}

function build_variants_list(variants){
	var list = document.createElement('ul');
	var json = { items: ['item 1', 'item 2', 'item 3'] };
	$(variants).each(function(index, item) {
	    list.append(
	        $(document.createElement('li')).text(item)
	    );
	});
	return list
}

function addProductToBoard(event, ui){
	// add the image to the board through jquery drag and drop in order to get its position
	cloned = $(ui.helper).clone();
	$(this).append(cloned.removeClass('board-lightbox-product').addClass('board-lightbox-product-cloned'));
	
	//hide the image of the product in the search results to indicate that it is no longer available to others.
	selector = '#board-product-select-' + cloned.data('productId')
	$(selector).hide();
	
	//alert(cloned.position().left + ':' + cloned.position().top)
	//saveProductToBoard($('#board-canvas').data('boardId'),cloned.data('productId'), cloned.position().left, cloned.position().top, 0, cloned.width(), cloned.height(), cloned.data('rotationOffset'));
	
	// persist it to the board
	var url = '/board_products.json'
	$.ajax({
		url: url, 
		type: "POST",
		dataType: "json", 
		data: {board_product: {board_id: $('#canvas').data('boardId'), product_id: cloned.data('productId'), top_left_x: cloned.position().left, top_left_y: cloned.position().top, width: cloned.width(), height: cloned.height()}},
	     beforeSend : function(xhr){
				xhr.setRequestHeader("Accept", "application/json")
	     },
	     success : function(board_product){
				//console.log(board_product.product.slug)
		
				buildImageLayer(canvas, board_product);
				//alert(board_product.product.id)
				
				//var variant_count = $.map(board_product.product.variants, function(n, i) { return i; }).length;
				//if (variant_count > 1){
				//	//alert(variant_count);
				//	$('#variant_options_modal').modal('show')
				//	$('#board_options_preloader').removeClass('hidden')
				//	$('#room_variant_options_container').addClass('hidden')
				//	
				//	var url = '/products/'+board_product.product.slug+'/product_with_variants'
				//	
				//	
				//	
				//	
				//	$.ajax({
				//		url: url, 
				//		type: "GET",
				//		//dataType: "text/javascript", 
				//		data: {},
				//	     beforeSend : function(xhr){
				//				xhr.setRequestHeader("Accept", "text/javascript")
				//	     },
				//	     success : function(product){
				//	     },
				//	     error: function(objAJAXRequest, strError, errorThrown){ //alert("ERROR: " + strError);
 				//				}
				//	  }
				//	);
				//	
				//	
				//	
				//	
				//	
				//}
				
				// remove the jquery drag/drop place holder that had been there.
				// this is a bit of a hack - without the timer, then the graphic disappears for a second...this generally keeps it up until the fabricjs version is added
				setTimeout(function() {
				      cloned.hide();
				}, 1000);
				
	     },
	     error: function(objAJAXRequest, strError, errorThrown){
				alert("ERROR: " + strError);
	     }
	  }
	);
}

function moveLayer(layer, direction){
	switch (direction) {
		case "top":
			canvas.bringToFront(layer)
			break;
		case "forward":
			canvas.bringForward(layer)
			break;
		case "bottom":
			canvas.sendToBack(layer)
			break;
		case "backward":
			canvas.sendBackwards(layer)
			break;
	}
	//it's possible all z indices have changed.  update them all	
	canvas.forEachObject(function(obj){
			updateBoardProduct(obj.get('id'), {id: obj.get('id'), z_index:canvas.getObjects().indexOf(obj)})
		
	    //console.log(canvas.getObjects().indexOf(obj))
	});

}


function getSavedProducts(board_id){
	var url = '/rooms/'+board_id+'/board_products.json'
	//var request = $.getJSON( url );
	
	$.ajax({
	   url: url, dataType: "json",
	     beforeSend : function(xhr){
	       xhr.setRequestHeader("Accept", "application/json")
	     },
	     success : function(data){
				
				// add the products to the board
				$.each(data, function(index, board_product) {
					buildImageLayer(canvas, board_product);					
				});
				
				// detect which product has focus
				canvas.on('mouse:down', function(options) {
				  if (options.target) {
						selectedImage = options.target;
						
						// pass the product id and board_id (optional) and BoardProduct id (optional)
						getProductDetails(selectedImage.get('product_permalink'), board_id, selectedImage.get('id'))
						//console.log(selectedImage.get('product_permalink'))
						}
					else{
						selectedImage = null;
						$('#board-product-preview').html('')
						}
				});
				
				canvas.on({
			    'object:modified': function(e) {
					      activeObject = e.target
								updateBoardProduct(activeObject.get('id'), {id: activeObject.get('id'), top_left_x: getCurrentLeft(activeObject), top_left_y: getCurrentTop(activeObject), width: activeObject.getWidth(), height: activeObject.getHeight(), rotation_offset: activeObject.getAngle(0)})
					    	console.log('modified!!!')
							}
			  });
				
				// listen for toolbar functions 
				document.getElementById('bp-move-front').addEventListener('click', function() {
					moveLayer(selectedImage, "top")
				}, false);
				document.getElementById('bp-move-forward').addEventListener('click', function() {
					moveLayer(selectedImage, "forward")
				}, false);
				document.getElementById('bp-move-back').addEventListener('click', function() {
					moveLayer(selectedImage, "bottom")
				}, false);
				document.getElementById('bp-move-backward').addEventListener('click', function() {
					moveLayer(selectedImage, "backward")
				}, false);
				document.getElementById('bp-rotate-left').addEventListener('click', function() {
					activeObject = canvas.getActiveObject()
					//x = activeObject.get('current_x')
					//y = activeObject.get('current_y')
					x = getCurrentLeft(activeObject)
					y = getCurrentTop(activeObject)
					rotateObject(90);	
					
					updateBoardProduct(activeObject.get('id'), {id: activeObject.get('id'), top_left_x: x, top_left_y: y, width: activeObject.getWidth(), height: activeObject.getHeight(), rotation_offset: activeObject.getAngle(0)})
					
					console.log('getLeft: '+ activeObject.getLeft())
					console.log('getTop: '+ activeObject.getTop())
					console.log('getPointByOrigin: '+ activeObject.getPointByOrigin())
					console.log('getOriginX: '+ activeObject.getOriginX())
					console.log('getOriginY: '+ activeObject.getOriginY())
					console.log('getCurrentLeft: '+ getCurrentLeft(activeObject))
					console.log('getCurrentTop: '+ getCurrentTop(activeObject))
					console.log('getAngle: '+ activeObject.getAngle())
				}, false);
				
	     },
	     error: function(objAJAXRequest, strError, errorThrown){
	       alert("ERROR: " + strError);
	     }
	  }
	);
 
}

function getCurrentLeft(obj){

	// if the angle is 0 or 360, then the left should be as is.
	// if the angle is 270 then the original left is in the bottom left and should be left as is 	
	if (obj.getAngle() == 0 || obj.getAngle() == 270 || obj.getAngle() == 360){
		return Math.round(obj.getLeft());
	}
	
	// if the angle is 90, then the original left is in the top right.  
	// currentLeft = origLeftPos - height
	else if (obj.getAngle() == 90){
		return Math.round(obj.getLeft() - obj.getHeight());
	}
	
	//if the angle is 180 the the original left is in the bottom right.  
	// currentLeft = origLeftPos - width
	else if (obj.getAngle() == 180){
		return Math.round(obj.getLeft() - obj.getWidth());
	}
	
	
}
function getCurrentTop(obj){
	
	// if the angle is 0 or 360 then the top should be as is
	// if the angle is 90, then the original corner is in the top right and should be left as is
	if (obj.getAngle() == 0 || obj.getAngle() == 90 || obj.getAngle() == 360){
		return Math.round(obj.getTop());
	}
	
	// if the angle is 180 then the object is flipped vertically and original corner is in the bottom right
	// currentTop = origTop - height
	else if (obj.getAngle() == 180){
		return Math.round(obj.getTop() - obj.getHeight());
	}
	
	// if the angle is 270 then the object is rotated and flipped horizontally and original corner is on bottom left
	// currentTop = origTop - width
	else if (obj.getAngle() == 270){
		return Math.round(obj.getTop() - obj.getWidth());
	}
}

function getProductDetails(product_id, board_id, board_product_id){
	
	board_id = (typeof board_id === "undefined") ? "defaultValue" : board_id;
	board_product_id = (typeof board_product_id === "undefined") ? "defaultValue" : board_product_id;
	
		
	var qstring = "?q"
	if (board_id != null){
		qstring = qstring + '&board_id='+board_id
	}
	if (board_product_id != null){
		qstring = qstring + '&board_product_id='+board_product_id
	}
	
	
	var url = '/products/'+product_id + qstring
	var request = $.get( url );

	  /* Put the results in a div */
	  request.done(function( data ) {
	    //var content = $( data ).find( '#content' );
	    //$( "#result" ).empty().append( content );
	  });	
}


function addProductBookmark(product_id){
	var url = '/bookmarks.json?product_id='+product_id
	//$('.bookmark-link-'+product_id).parent().addClass('hidden')
	//$('.bookmark-link-'+product_id).parent().parent().children('.unbookmark-product-container').removeClass('hidden')
	$('.bookmark-link-'+product_id).each(function() {
		$(this).parent().addClass('hidden')
		$(this).parent().parent().children('.unbookmark-product-container').removeClass('hidden')
	});
	
	
	
	$.ajax({
		url: url, 
		type: "POST",
		dataType: "json", 
		data: {},
	     beforeSend : function(xhr){
				xhr.setRequestHeader("Accept", "application/json")
	     },
	     success : function(bookmark){
					//alert('u r the one')
	     },
	     error: function(objAJAXRequest, strError, errorThrown){
				//alert("ERROR: " + strError);
	     }
	  }
	);
}

function observeBookmarkChanges(){
	$('.bookmark-product').click(function() {
		addProductBookmark($(this).data('productId'))
	});
	$('.remove-bookmark-product').click(function() {
		removeProductBookmark($(this).data('productId'))
	});
	
}

function removeProductBookmark(product_id){
	$('.unbookmark-link-'+product_id).each(function() {
		$(this).parent().addClass('hidden')
		$(this).parent().parent().children('.bookmark-product-container').removeClass('hidden')
	});
	var url = '/bookmarks/remove?product_id='+product_id
	$.post(url, null, "script");
	
	
	
	//$('.unbookmark-link-'+product_id).parent().addClass('hidden')
	//$('.unbookmark-link-'+product_id).parent().parent().children('.bookmark-product-container').removeClass('hidden')
}

function getProductBookmarks(){
	$('#bookmark-preloader').removeClass('hidden')
	$('#bookmarks_container').html('')
	var url = '/bookmarks/'
	var request = $.get( url );
	  request.done(function( data ) {
	});
}


function initializeBoardManagement(){
	$("#submit_board_button").click(function() {

		if ($('#edit_board_form').parsley( 'isValid' )){
			$(this).html('Saving...')
			$("#edit_board_form").submit();
		}else{
			$('#edit_board_form').parsley( 'validate' )
		}

	});

	$("#submit_and_publish_board_button").click(function() {

		if ($('#edit_board_form').parsley( 'isValid' )){
			$('#publish-board-modal').modal()
		}else{
			$('#edit_board_form').parsley( 'validate' )
		}

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

//function showProductDetails(item){
//	$('#product-details-pane').html('Loading product details...')
//	getProductDetails(item.data('productPermalink'), $('#canvas').data('boardId'))
//}


function setHeight(){
	var modalHeight =  $('#product-modal').height();
	$('.select-products-box').height(modalHeight-200);
	$('.product-preview-box').height(modalHeight-200);
	
}
