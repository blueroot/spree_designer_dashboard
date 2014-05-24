function board_product_controller($scope, $http, $location){

  $scope.variants = {};
  $scope.variants['12881'] = {};
  $scope.variants['12881']['shipping_height'] = "50";

  $scope.products = {};

  $scope.board_products = {};

  $scope.init = function(){

    //initialize hashes with ids as keys for lookup when trying to update all ajax style

  }

  $scope.deleteProductFromBoard = function(){

  }

  $scope.approve_product_for_board = function(product_id, board_id){
    alert( "Approving product " + product_id + " on board " + board_id);
  }

}