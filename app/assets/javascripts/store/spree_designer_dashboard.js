

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



//kinetic JS Functions


function updateBoardProductPosition(id, x, y){
	var url = '/board_products/'+id+'.json'
	//var request = $.getJSON( url );
	
	$.ajax({
		url: url, 
		type: "POST",
		dataType: "json", 
		data: {_method:'PATCH', board_product: {id: id, top_left_x: x, top_left_y: y}},
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

function setPosition(object, x, y){
	object.setAttr('x_pos', x);
	object.setAttr('y_pos', y);
}



function update(group, activeHandle) {
	var topLeft = group.get(".topLeft")[0],
			topRight = group.get(".topRight")[0],
			bottomRight = group.get(".bottomRight")[0],
			bottomLeft = group.get(".bottomLeft")[0],
			image = group.get(".image")[0],
			activeHandleName = activeHandle.getName(),
			newWidth,
			newHeight,
			imageX,
			imageY;

	// Update the positions of handles during drag.
	// This needs to happen so the dimension calculation can use the
	// handle positions to determine the new width/height.
	switch (activeHandleName) {
		case "topLeft":
			topRight.setY(activeHandle.getY());
			bottomLeft.setX(activeHandle.getX());
			break;
		case "topRight":
			topLeft.setY(activeHandle.getY());
			bottomRight.setX(activeHandle.getX());
			break;
		case "bottomRight":
			bottomLeft.setY(activeHandle.getY());
			topRight.setX(activeHandle.getX());
			break;
		case "bottomLeft":
			bottomRight.setY(activeHandle.getY());
			topLeft.setX(activeHandle.getX());
			break;
	}

	// Calculate new dimensions. Height is simply the dy of the handles.
	// Width is increased/decreased by a factor of how much the height changed.
	newHeight = bottomLeft.getY() - topLeft.getY();
	newWidth = image.getWidth() * newHeight / image.getHeight();
	
	// Move the image to adjust for the new dimensions.
	// The position calculation changes depending on where it is anchored.
	// ie. When dragging on the right, it is anchored to the top left,
	//    when dragging on the left, it is anchored to the top right.

  if(activeHandleName === "topRight" || activeHandleName === "bottomRight") {
      image.setPosition(topLeft.getX(), topLeft.getY());
  } else if(activeHandleName === "topLeft" || activeHandleName === "bottomLeft") {
      image.setPosition(topRight.getX() - newWidth, topRight.getY());
  }  

  imageX = image.getX();
  imageY = image.getY();

	

  // Update handle positions to reflect new image dimensions
  topLeft.setPosition(imageX, imageY);
  topRight.setPosition(imageX + newWidth, imageY);
  bottomRight.setPosition(imageX + newWidth, imageY + newHeight);
  bottomLeft.setPosition(imageX, imageY + newHeight);

  // Set the image's size to the newly calculated dimensions
	if(newWidth && newHeight) {
		image.setSize(newWidth, newHeight);
	}
	
	
	//image.getParent().setX(topLeft.getX())
	//image.getParent().setY(topLeft.getY())
	console.log(image.getParent().getX() +':'+image.getParent().getY() + ' - ' + newWidth + ':' + newHeight)
	

}
function addAnchor(group, x, y, name) {
	
	var thisLayer = group.getLayer();
	var thisStage = thisLayer.getStage();
	var anchor = new Kinetic.Rect({
	  x: x,
	  y: y,
	  stroke: "#666",
	  fill: "#ddd",
	  strokeWidth: 1,
	  //radius: 8,
		width: 8,
		height: 8,
		offset:[4,4],
	  name: name,
		visible: false,
	  draggable: true
	});

	anchor.on("dragmove", function() {
	  update(group, this);
	  thisLayer.draw();
	});
	anchor.on("mousedown touchstart", function() {
	  group.setDraggable(false);
	  this.moveToTop();
	});
	anchor.on("dragend", function() {
		image = this.getParent().get(".image")[0]
		x = image.getX()
		y = image.getY()
		//updateBoardProduct(thisLayer.getId(), {id: thisLayer.getId(), top_left_x: x, top_left_y: y, width: image.getWidth(), height: image.getHeight()})
		group.setDraggable(true);
		
		
		console.log('anchor: ' 	+ this.getX() +':'+ this.getY() )
		console.log('topleft: ' 	+ this.getParent().get(".topLeft")[0].getX() +':'+ this.getParent().get(".topLeft")[0].getY() )
		console.log('group: ' 	+ this.getParent().getX() +':'+ this.getParent().getY() )
		console.log('group 2: ' 	+ group.getX() +':'+ group.getY() )
		console.log('group w/offset: ' 	+ this.getParent().getOffsetX() +':'+ this.getParent().getOffsetY() )
		console.log('image: ' 	+ image.getX() +':'+ image.getY() )
		console.log('layer: ' 	+ this.getParent().getParent().getX() +':'+ this.getParent().getParent().getX() )
		//this.getParent().getParent().draw();
	});
	
	// add hover styling
	anchor.on("mouseover", function() {
	  var sameLayer = this.getLayer();
	  document.body.style.cursor = "pointer";
	  this.setStrokeWidth(2);
	  sameLayer.draw();
	});
	anchor.on("mouseout", function() {
	  var sameLayer = this.getLayer();
	  document.body.style.cursor = "default";
	  this.setStrokeWidth(1);
	  sameLayer.draw();
	});
	
	group.add(anchor);
	
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



function buildImageGroup(stage, board_product){
	
	var layer = new Kinetic.Layer({
		name: "layer",
		id: board_product.id
	});

	var productGroup = new Kinetic.Group({
		
		// position the group with an offset.  this is necessary so that it rotates around the center point
		x: parseInt(board_product.top_left_x) + parseInt(board_product.width)/2,
		y: parseInt(board_product.top_left_y) + parseInt(board_product.height)/2,
		offset:[parseInt(board_product.width)/2, parseInt(board_product.height)/2],
		draggable: true, 
		name: "group"
	});
	
	
	var imageObj = new Image();
	imageObj.onload = function() {
		
		var productImg = new Kinetic.Image({
			x: 0,
			y: 0,
			image: imageObj,
			width: board_product.width,
			height: board_product.height,
			name: "image"
			//offset: {x: parseInt(board_product.width)/2, y: parseInt(board_product.height)/2}
		});

		productGroup.add(productImg);
		layer.add(productGroup);
		stage.add(layer);
		
		addAnchor(productGroup, 0, 0, "topLeft");
		addAnchor(productGroup, board_product.width, 0, "topRight");
		addAnchor(productGroup, board_product.width, board_product.height, "bottomRight");
		addAnchor(productGroup, 0, board_product.height, "bottomLeft");
				
		productGroup.on("dragstart", function() {
			//layer.moveToTop();
		});
		productGroup.on('dragend', function() {
			
			x = this.getX() - this.getOffsetX();
			y = this.getY() - this.getOffsetY();
			width = this.get('.image')[0].getWidth()
			height = this.get('.image')[0].getHeight()
			//x = this.getX()
			//y = this.getY()
			
			updateBoardProduct(layer.getId(), {id: layer.getId(), top_left_x: x, top_left_y: y, width: width, height: height})
			console.log('product dragend: ' + x + ':' + y)
			console.log('product w/h: '+width + ':' + height)
	  });
		
		productImg.on('click', function(evt) {
			//alert('hello')
			
			productImg.getStage().getChildren().each(function(l, n) {
				//alert(l.name)
				
				grp = l.get(".group")[0]
				//alert(grp.getName())
				grp.get(".topLeft")[0].hide();
				//alert(grp.get(".topLeft")[0].getName())
				grp.get(".topRight")[0].hide();
				grp.get(".bottomLeft")[0].hide();
				grp.get(".bottomRight")[0].hide();
				grp.get(".image")[0].setStroke('white')
				l.draw();
			});
			
			productImg.getParent().get(".topLeft")[0].setVisible(true);
			productImg.getParent().get(".topRight")[0].setVisible(true);
			productImg.getParent().get(".bottomLeft")[0].setVisible(true);
			productImg.getParent().get(".bottomRight")[0].setVisible(true);
			productImg.setStroke('gray')
			productImg.setStrokeWidth(2)
			productImg.getParent().getParent().draw();
			
		});
		
		
	
		console.log(parseInt(board_product.rotation_offset))
		productGroup.rotateDeg(parseInt(board_product.rotation_offset));
		
		layer.draw();
	}	
	
	imageObj.src = board_product.product.image_url;
	
}

function buildImageLayer(canvas, bp){
	fabric.Image.fromURL(bp.product.image_url, function(oImg) {
		oImg.scale(1).set({
		      left: bp.top_left_x,
		      top: bp.top_left_y,
		      width : bp.width,
			    height : bp.height,
					hasRotatingPoint: false
		    });
		oImg.set('id', bp.id)
		canvas.add(oImg);
		canvas.setActiveObject(oImg);
		rotateObject(bp.rotation_offset);
		canvas.discardActiveObject();
	});

	
}


function addProductToBoard(event, ui){
	// add the image to the board through jquery drag and drop in order to get its position
	cloned = $(ui.helper).clone();
	$(this).append(cloned.removeClass('board-lightbox-product').addClass('board-lightbox-product-cloned'));
	
	//hide the image of the product in the search results to indicate that it is no longer available to others.
	selector = '#board-product-' + cloned.data('productId')
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
				
				// add the kineticjs image layer to the board
				//buildImageLayer(stage, board_product);
				//buildImageGroup(stage, board_product);
				buildImageLayer(canvas, board_product);
				
				
				// remove the jquery drag/drop place holder that had been there.
				// this is a bit of a hack - without the timer, then the graphic disappears for a second...this generally keeps it up until the kineticjs version is added
				setTimeout(function() {
				      cloned.hide();
				}, 2000);
				
	     },
	     error: function(objAJAXRequest, strError, errorThrown){
				alert("ERROR: " + strError);
	     }
	  }
	);
	
	//buildImageLayer(stage, board_product);
	
	
	//save product to the database
	//buildImageLayer(stage, board_product);
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
	
	//layer.draw();

	//it's possible all z indices have changed.  update them all
	
	
	canvas.forEachObject(function(obj){
			updateBoardProduct(obj.get('id'), {id: obj.get('id'), z_index:canvas.getObjects().indexOf(obj)})
		
	    console.log(canvas.getObjects().indexOf(obj))
	});
	
	//layer.getParent().getChildren().each(function(l, n) {
	//  updateBoardProduct(l.getId(), {id: l.getId(), z_index: l.getZIndex()})
	//});
	
	
	
	//console.log(layer.getZIndex()); 
	
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
						selectedImage = options.target;}
					else{
						selectedImage = null;}
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
					rotateObject(90);	
					activeObject = canvas.getActiveObject()
					updateBoardProduct(activeObject.get('id'), {id: activeObject.get('id'), top_left_x: getCurrentLeft(activeObject), top_left_y: getCurrentTop(activeObject), width: activeObject.getWidth(), height: activeObject.getHeight(), rotation_offset: activeObject.getAngle(0)})
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

function getSelectedBoardProduct(){
	el = $('.board-product-selected').first().parent();
	id = el.data('boardProductId')
	
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
		//alert('search z: ' + zindex)
	}
	else{
		cloned = $(ui.helper)
		$(this).append(cloned.removeClass('board-lightbox-product').addClass('board-lightbox-product-cloned'));
		zindex = cloned.css('z-index')
		//alert('existing z: ' + zindex)
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

function getSortedBoardProductsArray(){
	var arr = []
	$('.board-lightbox-product-cloned').each(function() {
		hash = {id: $(this).data('boardProductId'), zindex: $(this).data('productZindex')}
		arr.push(hash)
		//arr.push($(this).data('boardProductId'))
	});
	// sort the products according to the zindex
	arr.sort(function (a, b) {
	    if (a.zindex > b.zindex)
	      return 1;
	    if (a.zindex < b.zindex)
	      return -1;
	    // a must be equal to b
	    return 0;
	});
	
//	//create a new array of just the ids
//	newarr = []
//	// set the css zindex of each product on the board
//	$.map( arr, function( value, index ) {
//	    newarr.push(value.id)
//	});
//	
//	return newarr;
	
	return arr;
}

function layerProducts(){
	arr = getSortedBoardProductsArray();

	// set the css zindex of each product on the board
	$.map( arr, function( value, index ) {
	    //alert(value.id);
			selector = "#bp"+value.id
			$(selector).css('z-index',value.zindex)
	});
	
	return arr;
}
