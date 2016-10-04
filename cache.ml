
class virtual ['a,'b] cache =
object
  method virtual info : 'a -> 'b
  method virtual enqueue : 'a -> unit
  method virtual sync : (unit -> unit) -> unit
end

class ['a,'b] pure_cache ~(get : 'a -> 'b) =
object
  inherit ['a,'b] cache
  method info key = get key
  method enqueue key = ()
  method sync k = k ()
end

class ['a,'b] tabled_cache ~(default : 'a -> 'b) ~(bind : 'a list -> (('a * 'b option) list -> unit) -> unit) =
object (self)
  val h : ('a,'b option) Hashtbl.t = Hashtbl.create 1001
  method info (key : 'a) : 'b =
    try Common.unsome (Hashtbl.find h key)
    with _ -> self#enqueue key; default key

  val mutable todo : ('a,unit) Hashtbl.t = Hashtbl.create 101
  method enqueue (key : 'a) : unit =
    if not (Hashtbl.mem todo key || Hashtbl.mem h key)
    then Hashtbl.add todo key ()
  method sync (k : unit -> unit) : unit =
    if Hashtbl.length todo = 0
    then k ()
    else begin
      let l_key = Hashtbl.fold (fun key () res -> key::res) todo [] in
      bind l_key
	(fun l_key_info_opt ->
	  List.iter
	    (fun (key,info_opt) -> Hashtbl.add h key info_opt)
	    l_key_info_opt;
	  Hashtbl.clear todo;
	  k ())
    end
end
