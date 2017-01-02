// JavaScript Document Keyevent Listener  

$( "#tokens" ).on( "keydown", function( event ) {
  $( "#log" ).html( event.type + ": " +  event.which );
    Shiny.onInputChange("mydata2", event.which);
  
});

 $(document).on("keypress", function (e) {
   Shiny.onInputChange("mydata", e.which);
 });