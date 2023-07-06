// reporting that this extension is active
console.log("ViziQuer extension active");

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

    let data = {
        "query": sparklis.currentPlace().sparql(),
        "endpoint": sparklis.endpoint(),
        "schema": "DBpedia",
    }

    $.post("https://viziquer.app/api/public-diagram", data, function(json) {
        console.log(json);

        // if (json.statusCode == 200) {
        let vq_url = "https://viziquer.app" + json.url;
        console.log(vq_url);
        $("#iframe-viziquer").attr("src", vq_url);

    }, "json");

    // $("#iframe-viziquer").attr("src", "https://viziquer.app/public-diagram");
}

// ViziQuer open in new tab (button)
function vq_new_fn() {

    let data = {
        "query": sparklis.currentPlace().sparql(),
        "endpoint": sparklis.endpoint(),
        "schema": "DBpedia",
    }

    $.post("https://viziquer.app/api/public-diagram", data, function(json) {
        console.log(json);

        // if (json.statusCode == 200) {
        let vq_url = "https://viziquer.app" + json.url;
        console.log(vq_url);
        window.open(vq_url);

    }, "json");
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
