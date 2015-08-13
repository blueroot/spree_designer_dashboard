function initializeProductSearchForm() {
    /* attach a submit handler to the form */
    $("#product_search_form").submit(function (event) {
        /* stop form from submitting normally */
        event.preventDefault();

        $('#products-preloader').show()
        $('#select-products-box').html('')
        /* get some values from elements on the page: */
        var $form = $(this),
            term = $form.find('input[name="product_keywords"]').val(),
            supplier_id = $form.find('select[name="supplier_id"]').val(),
            department_taxon = $form.find('select[name="department_taxon"]').val(),
            url = $form.attr('action');
        bid = $('#canvas').data('boardId')

        //alert(taxon);
        /* Send the data using post */
        var posting = $.post(url, { keywords: term, department_taxon_id: department_taxon, supplier_id: supplier_id, per_page: 50, board_id: bid });

        /* Put the results in a div */
        posting.done(function (data) {
            $('#products-preloader').hide()
            url = $('.solr-filter-products').data('search-url');
            keywords = $('#product_keywords').val()
            $.ajax({
                dataType: 'html',
                method: 'POST',
                url: url,
                data: {keywords: keywords},
                success: function (response) {
                    $('.solr-filter-products').html(response);
                }
            });


        });
    });
}

$(document).on({
    click: function (e) {
        var obj, value;
        e.preventDefault();
        obj = canvas.getActiveObject();
        hash_id = obj.get('hash_id');
        canvas.remove(obj);
        value = $('.js-input-hash-product').val();
        if (value.length > 0) {
            hash = JSON.parse(value);
            delete hash[hash_id];
            $('.js-input-hash-product').val(JSON.stringify(hash));
        }
    }
}, '#js-remove-new-product-from-room');

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


    value = $('.js-input-hash-product').val();
//
    if (value.length > 0) {
        hash = JSON.parse(value)
    } else {
        hash = {}
    }

    ha_id = ""
    action = ""
    if (obj.get('action') == 'create') {
        ha_id = obj.get('hash_id');
        action = "create";
    } else {
        ha_id = obj.get('id')
        action = "update";

    }
    hash[ha_id] = {action_board: action, board_id: $('#canvas').data('boardId'), product_id: obj.get('id'), center_point_x: obj.getCenterPoint().x, center_point_y: obj.getCenterPoint().y, width: obj.getWidth(), height: obj.getHeight(), rotation_offset: obj.getAngle(0)}
    if (obj.z_index >= 0) {
        hash[ha_id]['z_index'] = obj.z_index;
    }
    $('.js-input-hash-product').val(JSON.stringify(hash));

    canvas.renderAll();
}

function showProductAddedState() {
    $('#product-preview-details').addClass('hidden');
    $('#product-preview-added').removeClass('hidden');
}

function updateBoardProduct(id, product_options) {

    var url = '/board_products/' + id + '.json'

    $.ajax({
            url: url,
            type: "POST",
            dataType: "json",
            data: {_method: 'PATCH', board_product: product_options},
            beforeSend: function (xhr) {
                xhr.setRequestHeader("Accept", "application/json")
            },
            success: function (data) {

            },
            error: function (objAJAXRequest, strError, errorThrown) {
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


function buildImageLayer(canvas, bp, url, slug, id, active, hash_id) {
    fabric.Image.fromURL(url, function (oImg) {
        oImg.scale(1).set({
            left: bp.center_point_x,
            top: bp.center_point_y,
            originX: 'center',
            originY: 'center',
            width: bp.width,
            height: bp.height,
            lockUniScaling: true,
            minScaleLimit: 0.25,
            hasRotatingPoint: false
        });
        oImg.set('id', id);
        oImg.set('action', active);
        oImg.set('product_permalink', slug);
        oImg.set('hash_id', hash_id);
        canvas.add(oImg);
        canvas.setActiveObject(oImg);
        if (bp.rotation_offset >= 0) {
            rotateObject(bp.rotation_offset);
            canvas.renderAll();
        }


    });
    value = $('.js-input-hash-product').val();
    if (value.length > 0) {
        hash = JSON.parse(value)
    } else {
        hash = {}
    }
    hash[hash_id] = { action_board: active, board_id: bp.board_id, product_id: id, center_point_x: bp.center_point_x, center_point_y: bp.center_point_y, width: bp.width, height: bp.height}

    if (bp.z_index >= 0) {
        hash[hash_id]['z_index'] = bp.z_index;

    }
    $('.js-input-hash-product').val(JSON.stringify(hash));

}


function getImageBase(url) {
    base_url = $('#board-container').data('url');
    $.ajax({
        dataType: 'html',
        method: 'POST',
        url: base_url,
        data: {image: url},
        success: function (resp) {
            activeObject = canvas.getActiveObject()
            element = activeObject.getElement();
            element.src = resp;
            canvas.discardActiveObject();

        }
    })

}

function getImageBaseRender(url, obj) {
    base_url = $('#board-container').data('url');
    $.ajax({
        dataType: 'html',
        method: 'POST',
        url: base_url,
        data: {image: url},
        success: function (resp) {
            activeObject = obj;
            element = activeObject.getElement();
            element.src = resp;

        }
    })

}


function build_variants_list(variants) {
    var list = document.createElement('ul');
    var json = { items: ['item 1', 'item 2', 'item 3'] };
    $(variants).each(function (index, item) {
        list.append(
            $(document.createElement('li')).text(item)
        );
    });
    return list
}

function addProductToBoard(event, ui) {

    // add the image to the board through jquery drag and drop in order to get its position
    cloned = $(ui.helper).clone();
    $(this).append(cloned.removeClass('board-lightbox-product').addClass('board-lightbox-product-cloned'));

    //calculate the origin based on the position and size
    center_x = cloned.position().left + parseFloat(cloned.width()) / 2.0
    center_y = cloned.position().top + parseFloat(cloned.height()) / 2.0

    //hide the image of the product in the search results to indicate that it is no longer available to others.
    //selector = '#board-product-select-' + cloned.data('productId')
    //$(selector).hide();

    //alert(cloned.position().left + ':' + cloned.position().top)
    //saveProductToBoard($('#board-canvas').data('boardId'),cloned.data('productId'), cloned.position().left, cloned.position().top, 0, cloned.width(), cloned.height(), cloned.data('rotationOffset'));
    random = Math.floor((Math.random() * 10) + 1);
//    base_url = $('#board-container').data('url');
    url = ui.helper.data('img-url');
    canvas_url = ui.helper.data('canvas-img-base');
    slug = ui.helper.data('product-slug');
    canvas_id = ui.helper.data('canvas-id');
    console.log(canvas_url)

    board_product = {board_id: $('#canvas').data('boardId'), product_id: cloned.data('productId'), center_point_x: center_x, center_point_y: center_y, width: cloned.width(), height: cloned.height()}
    buildImageLayer(canvas, board_product, url, slug, cloned.data('productId'), 'create', cloned.data('productId') + '-' + random);
    canvas.renderAll();
    cloned.hide();
    getImageBase(canvas_url);


}

function moveLayer(layer, direction) {
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
    canvas.forEachObject(function (obj) {
        console.log(canvas.getObjects().indexOf(obj));

        value = $('.js-input-hash-product').val();
//
        if (value.length > 0) {
            hash = JSON.parse(value)
        } else {
            hash = {}
        }

        ha_id = ""
        action = ""
        console.log(obj);
        if (obj.get('action') == 'create') {
            ha_id = obj.get('hash_id');
            action = "create";
        } else {
            ha_id = obj.get('id')
            action = "update";

        }
        obj.set('z_index', canvas.getObjects().indexOf(obj));
        hash[ha_id] = {action_board: action, board_id: $('#canvas').data('boardId'), product_id: obj.get('id'), center_point_x: obj.getCenterPoint().x, center_point_y: obj.getCenterPoint().y, width: obj.getWidth(), height: obj.getHeight(), rotation_offset: obj.getAngle(0), z_index: obj.get('z_index')}
        $('.js-input-hash-product').val(JSON.stringify(hash));

    });

}


function getSavedProducts(board_id) {
    var url = '/rooms/' + board_id + '/board_products.json'
    //var request = $.getJSON( url );

    $.ajax({
            url: url, dataType: "json",
            beforeSend: function (xhr) {
                xhr.setRequestHeader("Accept", "application/json")
            },
            success: function (data) {
                // add the products to the board
                $.each(data, function (index, board_product) {
                    buildImageLayer(canvas, board_product, board_product.product.image_url, board_product.product.slug, board_product.id, 'update', board_product.id);
                    canvas.renderAll();

                });
                canvas.discardActiveObject();

                // detect which product has focus
                canvas.on('mouse:down', function (options) {
                    if (options.target) {
                        selectedImage = options.target;
                        // pass the product id and board_id (optional) and BoardProduct id (optional)
                        getProductDetails(selectedImage.get('product_permalink'), board_id, selectedImage.get('id'))
                        //console.log(selectedImage.get('product_permalink'))
                    }
                    else {
                        selectedImage = null;
                        $('#board-product-preview').html('')
                    }
                });

                canvas.on({
                    'object:modified': function (e) {
                        if (canvas.getActiveGroup() === null) {
                            activeObject = e.target
                            value = $('.js-input-hash-product').val();
                            if (value.length > 0) {
                                hash = JSON.parse(value)
                            } else {
                                hash = {}
                            }

                            ha_id = ""
                            action = ""
                            if (activeObject.get('action') == 'create') {
                                ha_id = activeObject.get('hash_id');
                                action = "create";
                            } else {
                                ha_id = activeObject.get('id')
                                action = "update";

                            }
                            hash[ha_id] = {action_board: action, board_id: board_id, product_id: activeObject.get('id'), center_point_x: activeObject.getCenterPoint().x, center_point_y: activeObject.getCenterPoint().y, width: activeObject.getWidth(), height: activeObject.getHeight(), rotation_offset: activeObject.getAngle(0)}

                            if (activeObject.get('z_index') >= 0) {
                                hash[ha_id]['z_index'] = activeObject.get('z_index')

                            }
                            $('.js-input-hash-product').val(JSON.stringify(hash));

                            activeObject.getElement().load = function () {
                                var theImage = new fabric.Image(activeObject.getElement(), {top: activeObject.get('top'), left: activeObject.get('left')});
                                theImage.scaleX = activeObject.get('scaleX');
                                theImage.scaleY = activeObject.get('scaleY');
                                theImage.originX = 'center',
                                    theImage.originY = 'center',
                                    theImage.lockUniScaling = true,
                                    theImage.minScaleLimit = 0.25,
                                    theImage.hasRotatingPoint = false,
                                    theImage.set('width', activeObject.get('width'));
                                theImage.set('height', activeObject.get('height'));
                                theImage.set('id', activeObject.get('id'));
                                theImage.set('action', activeObject.get('active'));
                                theImage.set('product_permalink', activeObject.get('product_permalink'));
                                theImage.set('hash_id', activeObject.get('hash_id'));
                                canvas.add(theImage);
                                canvas.remove(activeObject);
                                canvas.renderAll();
                                var filter = new fabric.Image.filters.Convolute({
                                    matrix: [ 1 / 9, 1 / 9, 1 / 9,
                                        1 / 9, 1 / 9, 1 / 9,
                                        1 / 9, 1 / 9, 1 / 9 ]
                                });
                                theImage.filters.push(filter);
                                theImage.applyFilters(canvas.renderAll.bind(canvas));
                                canvas.setActiveObject(theImage);

                            };
                            activeObject.getElement().load();
                        }
//								updateBoardProduct(activeObject.get('id'), {id: activeObject.get('id'), center_point_x: activeObject.getCenterPoint().x, center_point_y: activeObject.getCenterPoint().y, width: activeObject.getWidth(), height: activeObject.getHeight(), rotation_offset: activeObject.getAngle(0)})
                    }
                });
                // listen for toolbar functions
                document.getElementById('bp-move-front').addEventListener('click', function () {
                    moveLayer(selectedImage, "top")
                }, false);
                document.getElementById('bp-move-forward').addEventListener('click', function () {
                    moveLayer(selectedImage, "forward")
                }, false);
                document.getElementById('bp-move-back').addEventListener('click', function () {
                    moveLayer(selectedImage, "bottom")
                }, false);
                document.getElementById('bp-move-backward').addEventListener('click', function () {
                    moveLayer(selectedImage, "backward")
                }, false);
                document.getElementById('bp-rotate-left').addEventListener('click', function () {
                    activeObject = canvas.getActiveObject()
                    rotateObject(90);
//					updateBoardProduct(activeObject.get('id'), {id: activeObject.get('id'), center_point_x: activeObject.getCenterPoint().x, center_point_y: activeObject.getCenterPoint().y, width: activeObject.getWidth(), height: activeObject.getHeight(), rotation_offset: activeObject.getAngle(0)})


                }, false);

            },
            error: function (objAJAXRequest, strError, errorThrown) {
                alert("ERROR: " + strError);
            }
        }
    );

}

function getCurrentLeft(obj) {

    // if the angle is 0 or 360, then the left should be as is.
    // if the angle is 270 then the original left is in the bottom left and should be left as is
    if (obj.getAngle() == 0 || obj.getAngle() == 270 || obj.getAngle() == 360) {
        return Math.round(obj.getLeft());
    }

    // if the angle is 90, then the original left is in the top right.
    // currentLeft = origLeftPos - height
    else if (obj.getAngle() == 90) {
        return Math.round(obj.getLeft() - obj.getHeight());
    }

    //if the angle is 180 the the original left is in the bottom right.
    // currentLeft = origLeftPos - width
    else if (obj.getAngle() == 180) {
        return Math.round(obj.getLeft() - obj.getWidth());
    }


}
function getCurrentTop(obj) {

    // if the angle is 0 or 360 then the top should be as is
    // if the angle is 90, then the original corner is in the top right and should be left as is
    if (obj.getAngle() == 0 || obj.getAngle() == 90 || obj.getAngle() == 360) {
        return Math.round(obj.getTop());
    }

    // if the angle is 180 then the object is flipped vertically and original corner is in the bottom right
    // currentTop = origTop - height
    else if (obj.getAngle() == 180) {
        return Math.round(obj.getTop() - obj.getHeight());
    }

    // if the angle is 270 then the object is rotated and flipped horizontally and original corner is on bottom left
    // currentTop = origTop - width
    else if (obj.getAngle() == 270) {
        return Math.round(obj.getTop() - obj.getWidth());
    }
}

function getProductDetails(product_id, board_id, board_product_id) {
    $('.board-product-preview-details').hide()
    $('.js_reload_info').show()
    board_id = (typeof board_id === "undefined") ? "defaultValue" : board_id;
    board_product_id = (typeof board_product_id === "undefined") ? "defaultValue" : board_product_id;


    var qstring = "?q"
    if (board_id != null) {
        qstring = qstring + '&board_id=' + board_id
    }
    if (board_product_id != null) {
        qstring = qstring + '&board_product_id=' + board_product_id
    }


    var url = '/products/' + product_id + qstring
    var request = $.get(url);

    /* Put the results in a div */
    request.done(function (data) {
        $('.js_reload_info').hide()
        $('.board-product-preview-details').show()
        //var content = $( data ).find( '#content' );
        //$( "#result" ).empty().append( content );
    });
}


function addProductBookmark(product_id) {
    var url = '/bookmarks.json?product_id=' + product_id
    //$('.bookmark-link-'+product_id).parent().addClass('hidden')
    //$('.bookmark-link-'+product_id).parent().parent().children('.unbookmark-product-container').removeClass('hidden')
    $('.bookmark-link-' + product_id).each(function () {
        $(this).parent().addClass('hidden')
        $(this).parent().parent().children('.unbookmark-product-container').removeClass('hidden')
    });


    $.ajax({
            url: url,
            type: "POST",
            dataType: "json",
            data: {},
            beforeSend: function (xhr) {
                xhr.setRequestHeader("Accept", "application/json")
            },
            success: function (bookmark) {
                //alert('u r the one')
            },
            error: function (objAJAXRequest, strError, errorThrown) {
                //alert("ERROR: " + strError);
            }
        }
    );
}

function observeBookmarkChanges() {
    $('.bookmark-product').click(function () {
        addProductBookmark($(this).data('productId'))
    });
    $('.remove-bookmark-product').click(function () {
        removeProductBookmark($(this).data('productId'))
    });

}

function removeProductBookmark(product_id) {
    $('.unbookmark-link-' + product_id).each(function () {
        $(this).parent().addClass('hidden')
        $(this).parent().parent().children('.bookmark-product-container').removeClass('hidden')
    });
    var url = '/bookmarks/remove?product_id=' + product_id
    $.post(url, null, "script");


    //$('.unbookmark-link-'+product_id).parent().addClass('hidden')
    //$('.unbookmark-link-'+product_id).parent().parent().children('.bookmark-product-container').removeClass('hidden')
}

function getProductBookmarks() {
    $('#bookmark-preloader').removeClass('hidden')
    $('#bookmarks_container').html('')
    var url = '/favorites/'
    var request = $.get(url);
    request.done(function (data) {
    });
}


function initializeBoardManagement() {
    $("#submit_board_button").click(function () {

        $('#board-canvas').block({
            message: null,
            overlayCSS: {
                backgroundColor: '#999',
                opacity: 0.6,
                cursor: 'wait'
            }
        });
        $('#product_lightbox').block({
            message: null,
            overlayCSS: {
                backgroundColor: '#999',
                opacity: 0.6,
                cursor: 'wait'
            }
        });

        if ($('#edit_board_form').parsley('isValid')) {
            $(this).html('Saving...')
            $("#edit_board_form").submit();
        } else {
            $('#edit_board_form').parsley('validate')
        }

    });

    $("#submit_and_publish_board_button").click(function () {

        if ($('#edit_board_form').parsley('isValid')) {
            $('#publish-board-modal').modal()
        } else {
            $('#edit_board_form').parsley('validate')
        }

    });


}


function handleRemoveFromCanvas(el) {
    el.find('a.button-remove-product').click(function () {
        el.hide();
        var product_id = el.data('productId')
        var board_id = $('#board-canvas').data('boardId')
        var url = '/rooms/' + board_id + '/board_products/' + product_id
        $.post(url, {_method: 'delete'}, null, "script");
        $('.board-lightbox-product-cloned').popover('hide');
    });

}

function handleProductPopover(el) {

    $('.board-lightbox-product-cloned').popover({
        html: true,
        trigger: 'manual',
        content: function () {
            //$('.board-lightbox-product-cloned').popover('hide');
            return $('#' + $(this).data('popoverContainer')).html();
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


function getImageWidth(url) {
    var img = new Image();
    img.onload = function () {
        //return "w"
    }
    img.src = url
    return img.width
}

function getImageHeight(url) {
    var img = new Image();
    img.onload = function () {
        //return "h"
    }
    img.src = url
    return img.height
}

//function showProductDetails(item){
//	$('#product-details-pane').html('Loading product details...')
//	getProductDetails(item.data('productPermalink'), $('#canvas').data('boardId'))
//}


function setHeight() {
    var modalHeight = $('#product-modal').height();
    $('.select-products-box').height(modalHeight - 200);
    $('.product-preview-box').height(modalHeight - 200);

}


function downScaleImage(img, scale) {
    var imgCV = document.createElement('canvas');
    imgCV.width = img.width;
    imgCV.height = img.height;
    var imgCtx = imgCV.getContext('2d');
    imgCtx.drawImage(img, 0, 0);
    return downScaleCanvas(imgCV, scale);
}

// scales the canvas by (float) scale < 1
// returns a new canvas containing the scaled image.
function downScaleCanvas(cv, scale) {
    if (!(scale < 1) || !(scale > 0)) throw ('scale must be a positive number <1 ');
    scale = normaliseScale(scale);
    var sqScale = scale * scale; // square scale =  area of a source pixel within target
    var sw = cv.width; // source image width
    var sh = cv.height; // source image height
    var tw = Math.floor(sw * scale); // target image width
    var th = Math.floor(sh * scale); // target image height
    var sx = 0, sy = 0, sIndex = 0; // source x,y, index within source array
    var tx = 0, ty = 0, yIndex = 0, tIndex = 0; // target x,y, x,y index within target array
    var tX = 0, tY = 0; // rounded tx, ty
    var w = 0, nw = 0, wx = 0, nwx = 0, wy = 0, nwy = 0; // weight / next weight x / y
    // weight is weight of current source point within target.
    // next weight is weight of current source point within next target's point.
    var crossX = false; // does scaled px cross its current px right border ?
    var crossY = false; // does scaled px cross its current px bottom border ?
    var sBuffer = cv.getContext('2d').
        getImageData(0, 0, sw, sh).data; // source buffer 8 bit rgba
    var tBuffer = new Float32Array(3 * tw * th); // target buffer Float32 rgb
    var sR = 0, sG = 0, sB = 0; // source's current point r,g,b

    for (sy = 0; sy < sh; sy++) {
        ty = sy * scale; // y src position within target
        tY = 0 | ty;     // rounded : target pixel's y
        yIndex = 3 * tY * tw;  // line index within target array
        crossY = (tY !== (0 | ( ty + scale )));
        if (crossY) { // if pixel is crossing botton target pixel
            wy = (tY + 1 - ty); // weight of point within target pixel
            nwy = (ty + scale - tY - 1); // ... within y+1 target pixel
        }
        for (sx = 0; sx < sw; sx++, sIndex += 4) {
            tx = sx * scale; // x src position within target
            tX = 0 | tx;    // rounded : target pixel's x
            tIndex = yIndex + tX * 3; // target pixel index within target array
            crossX = (tX !== (0 | (tx + scale)));
            if (crossX) { // if pixel is crossing target pixel's right
                wx = (tX + 1 - tx); // weight of point within target pixel
                nwx = (tx + scale - tX - 1); // ... within x+1 target pixel
            }
            sR = sBuffer[sIndex    ];   // retrieving r,g,b for curr src px.
            sG = sBuffer[sIndex + 1];
            sB = sBuffer[sIndex + 2];
            if (!crossX && !crossY) { // pixel does not cross
                // just add components weighted by squared scale.
                tBuffer[tIndex    ] += sR * sqScale;
                tBuffer[tIndex + 1] += sG * sqScale;
                tBuffer[tIndex + 2] += sB * sqScale;
            } else if (crossX && !crossY) { // cross on X only
                w = wx * scale;
                // add weighted component for current px
                tBuffer[tIndex    ] += sR * w;
                tBuffer[tIndex + 1] += sG * w;
                tBuffer[tIndex + 2] += sB * w;
                // add weighted component for next (tX+1) px
                nw = nwx * scale
                tBuffer[tIndex + 3] += sR * nw;
                tBuffer[tIndex + 4] += sG * nw;
                tBuffer[tIndex + 5] += sB * nw;
            } else if (!crossX && crossY) { // cross on Y only
                w = wy * scale;
                // add weighted component for current px
                tBuffer[tIndex    ] += sR * w;
                tBuffer[tIndex + 1] += sG * w;
                tBuffer[tIndex + 2] += sB * w;
                // add weighted component for next (tY+1) px
                nw = nwy * scale
                tBuffer[tIndex + 3 * tw    ] += sR * nw;
                tBuffer[tIndex + 3 * tw + 1] += sG * nw;
                tBuffer[tIndex + 3 * tw + 2] += sB * nw;
            } else { // crosses both x and y : four target points involved
                // add weighted component for current px
                w = wx * wy;
                tBuffer[tIndex    ] += sR * w;
                tBuffer[tIndex + 1] += sG * w;
                tBuffer[tIndex + 2] += sB * w;
                // for tX + 1; tY px
                nw = nwx * wy;
                tBuffer[tIndex + 3] += sR * nw;
                tBuffer[tIndex + 4] += sG * nw;
                tBuffer[tIndex + 5] += sB * nw;
                // for tX ; tY + 1 px
                nw = wx * nwy;
                tBuffer[tIndex + 3 * tw    ] += sR * nw;
                tBuffer[tIndex + 3 * tw + 1] += sG * nw;
                tBuffer[tIndex + 3 * tw + 2] += sB * nw;
                // for tX + 1 ; tY +1 px
                nw = nwx * nwy;
                tBuffer[tIndex + 3 * tw + 3] += sR * nw;
                tBuffer[tIndex + 3 * tw + 4] += sG * nw;
                tBuffer[tIndex + 3 * tw + 5] += sB * nw;
            }
        } // end for sx
    } // end for sy

    // create result canvas
    var resCV = document.createElement('canvas');
    resCV.width = tw;
    resCV.height = th;
    var resCtx = resCV.getContext('2d');
    var imgRes = resCtx.getImageData(0, 0, tw, th);
    var tByteBuffer = imgRes.data;
    // convert float32 array into a UInt8Clamped Array
    var pxIndex = 0; //
    for (sIndex = 0, tIndex = 0; pxIndex < tw * th; sIndex += 3, tIndex += 4, pxIndex++) {
        tByteBuffer[tIndex] = 0 | ( tBuffer[sIndex]);
        tByteBuffer[tIndex + 1] = 0 | (tBuffer[sIndex + 1]);
        tByteBuffer[tIndex + 2] = 0 | (tBuffer[sIndex + 2]);
        tByteBuffer[tIndex + 3] = 255;
    }
    // writing result to canvas.
    resCtx.putImageData(imgRes, 0, 0);
    return resCV;
}

function polyFillPerfNow() {
    window.performance = window.performance ? window.performance : {};
    window.performance.now = window.performance.now || window.performance.webkitNow || window.performance.msNow ||
        window.performance.mozNow || Date.now;
};

function log2(v) {
    // taken from http://graphics.stanford.edu/~seander/bithacks.html
    var b = [ 0x2, 0xC, 0xF0, 0xFF00, 0xFFFF0000 ];
    var S = [1, 2, 4, 8, 16];
    var i = 0, r = 0;

    for (i = 4; i >= 0; i--) {
        if (v & b[i]) {
            v >>= S[i];
            r |= S[i];
        }
    }
    return r;
}
// normalize a scale <1 to avoid some rounding issue with js numbers
function normaliseScale(s) {
    if (s > 1) throw('s must be <1');
    s = 0 | (1 / s);
    var l = log2(s);
    var mask = 1 << l;
    var accuracy = 4;
    while (accuracy && l) {
        l--;
        mask |= 1 << l;
        accuracy--;
    }
    return 1 / ( s & mask );
}

