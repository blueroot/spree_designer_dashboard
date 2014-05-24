function board_product_controller($scope, $http, $location){

  $scope.user_errors = ""
  $scope.farmer_errors = ""

  $scope.user    = { "name":"", "email":"", "password":"", "password_confirmation":""};
  $scope.farmer  = {"favorite_quotes":"", "role_models":"", "personal_philosophy":""};

  $scope.deleteProductFromBoard = function(){

  }

  $scope.submitForms = function(){
    submitData("user");
  }

  submitData = function(model, id){
    var modelToSubmit = {"ajax":true};
    modelToSubmit[model] = $scope[model]
    var path = '/' + model + 's';
    if(model === "farmer"){
      modelToSubmit["user_id"] = id;
    }


    $http.post(path, modelToSubmit).
    success( function(response){
      if( response.id ){
        if(model === "user"){
          submitData("farmer", response.id)
        }
        else{
          window.location.href = "/farms/new";
        }
      }
      else{
        $scope.user_errors = JSON.stringify(response)
      }
    }).
    error( function(response){
      alert('bad mkay'); 
    }); 
  }

}