// reporting that this extension is active
console.log("ViziQuer extension active");

const VQ_HOST_URL = "https://viziquer.app"
// const VQ_HOST_URL = "http://localhost:3000"

// isVisualizationNeeded
const VQ_VISUALIZATION = true


// ViziQuer debug button
function vq_click_fn() {
    console.log("Debug info:")
    console.log("- endpoint:", sparklis.endpoint());
    console.log("- query:", sparklis.currentPlace().query());
    console.log("- delta: ", sparklis.currentPlace().delta());
    console.log("- permalink:", sparklis.currentPlace().permalink());
    console.log("- SPARQL query:");
    console.log(sparklis.currentPlace().sparql());
}

// ViziQuer loading button
function vq_load_fn() {

    const json_data = JSON.stringify({
        "query": sparklis.currentPlace().sparql(),
        "endpoint": sparklis.endpoint(),
        "schema": "DBpedia",
        "isVisualizationNeeded": VQ_VISUALIZATION
    })

    $.ajax(
        {
            "url": VQ_HOST_URL + "/api/public-diagram",
            "method": "POST",
            "dataType": "json",
            "contentType": "application/json",
            "data": json_data
        }
    ).done( function(json_in) {
        console.log(json_in);

        let vq_url = VQ_HOST_URL + json_in.url;
        console.log(vq_url);
        $("#iframe-viziquer").attr("src", vq_url);
    });

}

// ViziQuer open in new tab (button)
function vq_new_fn() {

    const json_data = JSON.stringify({
        "query": sparklis.currentPlace().sparql(),
        "endpoint": sparklis.endpoint(),
        "schema": "DBpedia",
        "isVisualizationNeeded": VQ_VISUALIZATION
    });

    $.ajax(
        {
            "url": VQ_HOST_URL + "/api/public-diagram",
            "method": "POST",
            "dataType": "json",
            "contentType": "application/json",
            "data": json_data
        }
    ).done( function(json_in) {
        console.log(json_in);

        let vq_url = VQ_HOST_URL + json_in.url;
        console.log(vq_url);
        window.open(vq_url);
    });
}


$(window).on("load", function() {
    $("#button-viziquer").click(vq_click_fn);
    $("#button-viziquer-load").click(vq_load_fn);
    $("#button-viziquer-new").click(vq_new_fn);
    $("#iframe-viziquer").attr("src", "");
} );

// SPARQL hook: displaying the query in the ViziQuer tab
sparklis_extension.hookSparql =
    function(sparql) {

        let vq_div = $("#sparql-query-viziquer");
        let vq_escaped = vq_div.text(sparql).html();
        vq_div.html(`<pre>${vq_escaped}</pre>`);

	return sparql
	//console.log("Here a dummy PREFIX is added.");
	//return "PREFIX foo: <http://foo.com/>\n" + sparql
    };
