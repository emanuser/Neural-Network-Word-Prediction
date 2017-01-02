// JavaScript Document Autocomplet

$( function() {
  Shiny.addCustomMessageHandler("for_autocomplet2",
         function(message) {
           
		
		function split( val ) {
			return val.split( /\s+/ );
		}
		function extractLast( term ) {
			return split( term ).pop();
		}
		
	
		

		$( '#tokens' )
			// don't navigate away from the field on tab when selecting an item
			.on( "keydown", function( event ) {
				if ( event.keyCode === $.ui.keyCode.TAB &&
						$( this ).autocomplete( "instance" ).menu.active ) {
					event.preventDefault();
				}
			})
			.autocomplete({
			  delay: 600,
			  minLength: 0,
				source: function( request, response ) {
					// delegate back to autocomplete, but extract the last term
					response( $.ui.autocomplete.filter(
						message, extractLast( request.term ) ) );
							
				},
				
				
				
				focus: function() {
					// prevent value inserted on focus
					return false;
				},
				select: function( event, ui ) {
					var terms = split( this.value );
					// remove the current input
					terms.pop();
					// add the selected item
					terms.push( ui.item.value );
					
					// add placeholder to get the space at the end
					terms.push( "" );
					this.value = terms.join( " " );
					return false;
					
				}
			});
	});
	
  
});