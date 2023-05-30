// reporting that this extension is active
console.log("ViziQuer extension active");

// ViziQuer button: on click event
function vq_click_fn() {
    console.log("Debug info:")
    console.log("- endpoint:", sparklis.endpoint());
    console.log("- query:", sparklis.currentPlace().query());
    console.log("- delta: ", sparklis.currentPlace().delta());
    console.log("- permalink:", sparklis.currentPlace().permalink());
    console.log("- SPARQL query:");
    console.log(sparklis.currentPlace().sparql());
}

$(window).on("load", function() {
    $("#button-viziquer").click(vq_click_fn);
} );

// SPARQL hook: displaying the query in the ViziQuer tab
sparklis_extension.hookSparql =
    function(sparql) {

        let vq_div = $("#sparql-query-viziquer");
        vq_div.html(`<pre>${sparql}</pre>`);

	return sparql
	//console.log("Here a dummy PREFIX is added.");
	//return "PREFIX foo: <http://foo.com/>\n" + sparql
    };
