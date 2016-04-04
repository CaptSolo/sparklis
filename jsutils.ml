
open Js
open XmlHttpRequest

let alert msg = Dom_html.window##alert(string msg)

let prompt msg text = Dom_html.window##prompt(string msg, string text)

let firebug msg = Firebug.console##log(string msg)

let jquery_from (root : #Dom_html.nodeSelector Js.t) s k =
  Opt.iter (root##querySelector(string s)) (fun elt ->
    k elt)
let jquery s k = jquery_from Dom_html.document s k

let jquery_input_from (root : #Dom_html.nodeSelector Js.t) s k =
  Opt.iter (root##querySelector(string s)) (fun elt ->
    Opt.iter (Dom_html.CoerceTo.input elt) (fun input ->
      k input))
let jquery_input s k = jquery_input_from Dom_html.document s k

let jquery_select_from (root : #Dom_html.nodeSelector Js.t) s k =
  Opt.iter (root##querySelector(string s)) (fun elt ->
    Opt.iter (Dom_html.CoerceTo.select elt) (fun select ->
      k select))
let jquery_select s k = jquery_select_from Dom_html.document s k

let jquery_all_from (root : #Dom_html.nodeSelector Js.t) s k =
  let nodelist = root##querySelectorAll(string s) in
  let n = nodelist##length in
  for i=0 to n-1 do
    Opt.iter nodelist##item(i) k
  done
let jquery_all s k = jquery_all_from Dom_html.document s k

let jquery_set_innerHTML sel html =
  jquery sel (fun elt -> elt##innerHTML <- string html)
let jquery_toggle_innerHTML sel (s1 : string) (s2 : string) : string =
  let new_s = ref "" in
  jquery sel (fun elt ->
    new_s := (if to_string elt##innerHTML = s1 then s2 else s1);
    elt##innerHTML <- string !new_s);
  !new_s

let jquery_show sel = jquery sel (fun elt -> elt##style##display <- string "block")
let jquery_hide sel = jquery sel (fun elt -> elt##style##display <- string "none")
let jquery_toggle sel = jquery sel (fun elt ->
  if to_string elt##style##display = "none"
  then elt##style##display <- string "block"
  else elt##style##display <- string "none")    

let jquery_click sel = jquery_input sel (fun input -> input##click())

let onclick k elt =
  elt##onclick <- Dom.handler (fun ev -> k elt ev; bool true)

let ondblclick k elt =
  elt##ondblclick <- Dom.handler (fun ev -> k elt ev; bool true)

let onhover k elt =
  elt##onmouseover <- Dom.handler (fun ev -> k elt ev; bool true)

let oninput k elt =
  elt##oninput <- Dom.handler (fun ev -> k elt ev; bool true)

let onchange k elt =
  elt##onchange <- Dom.handler (fun ev -> k elt ev; bool true)

let onkeypress k elt =
  elt##onkeypress <- Dom.handler (fun ev -> k elt ev; bool true)
let onkeydown k elt =
  elt##onkeydown <- Dom.handler (fun ev -> k elt ev; bool true)

let onenter k elt =
  onkeypress
    (fun elt ev -> if ev##keyCode = 13 then begin k elt ev; bool true end else bool false)
    elt

let stop_propagation_from elt sel =
  jquery_all_from elt sel
    (onclick (fun elt ev -> Dom_html.stopPropagation ev))
let stop_links_propagation_from elt = stop_propagation_from elt "a"

(* prepare a string for safe insertion in HTML code *)
let escapeHTML (str : string) : string =
  let div = Dom_html.createDiv Dom_html.document in
  ignore (div##appendChild((Dom_html.document##createTextNode(string str) :> Dom.node t)));
  to_string (div##innerHTML)

let integer_of_input ?(min = min_int) ?(max = max_int) input : int option =
  try
    let n = int_of_string (to_string input##value) in
    if n < min then None
    else if n > max then None
    else Some n
  with _ -> None

(* DOM utilities *)

let getElementsByTagNameNS (elt : Dom.element t) (ns : js_string t) (name : js_string t) : Dom.element Dom.nodeList t =
(*elt##getElementsByTagName(name)*)
  Unsafe.coerce (Unsafe.meth_call elt "getElementsByTagNameNS" [|Unsafe.inject ns; Unsafe.inject name|])

let lookupPrefix (elt : Dom.element t) (ns : js_string t) : js_string t opt =
  (* not working in Internet Explorer *)
  some (Unsafe.coerce (Unsafe.meth_call elt "lookupPrefix" [|Unsafe.inject ns|]))

(* YASGUI bindings *)

let yasgui =
object (self)
  val mutable this_opt = None

  method init =
    try this_opt <- Some (jsnew (Unsafe.global##_YASGUI) (Dom_html.getElementById "sparklis-yasgui"))
    with exn -> alert ("Warning: YASGUI could not be initialized for some reason. SPARQL queries will be displayed as mere text at the bottom of the page.")

  method set_corsProxy (url_opt : string option) : unit =
    match this_opt with
    | None -> ()
    | Some yasgui -> yasgui##options##api##corsProxy <- (match url_opt with None -> null | Some url -> some (string url))

  method private yasqe yasgui = yasgui##current()##yasqe
  method private yasr yasgui = yasgui##current()##yasr

  method set_endpoint (endpoint : string) : unit =
    match this_opt with
    | None -> ()
    | Some yasgui ->
      let yasqe = self#yasqe yasgui in
      yasqe##options##sparql##endpoint <- string endpoint;
      jquery_set_innerHTML ".yasgui .endpointText .item" endpoint

  method set_requestMethod (meth : [`GET | `POST]) : unit =
    match this_opt with
    | None -> ()
    | Some yasgui ->
      let yasqe = self#yasqe yasgui in
      yasqe##options##sparql##requestMethod <- string (match meth with `GET -> "GET" | `POST -> "POST")

  method set_query (sparql : string) : unit =
    match this_opt with
    | None ->
      let html = "<xmp>" ^ sparql ^ "</xmp>" in
      jquery_set_innerHTML "#sparql-query" html
    | Some yasgui ->
      let yasqe = self#yasqe yasgui in
      yasqe##setValue(string sparql)

  method set_response (resp : string) : unit =
    match this_opt with
    | None -> ()
    | Some yasgui ->
      let yasr = self#yasr yasgui in
      yasr##setResponse(string resp)

  method refresh : unit =
    match this_opt with
    | None -> ()
    | Some yasgui ->
      let yasqe = self#yasqe yasgui in
      let yasr = self#yasr yasgui in
      yasqe##setValue(yasqe##getValue());
      yasr##draw()
end
