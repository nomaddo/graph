module Html = Dom_html
module G = Graphics_js

(* utility functions *)
let fmt = Printf.sprintf
let js = Js.string
let doc = Html.document
let log (s:string) = Firebug.console##log(js s)

let len_x = 640 * 2
let len_y = 480 * 2

type cube = {mutable px: float; mutable py: float;
             mutable vx: float; mutable vy: float;
             mutable ax: float; mutable ay: float}

let print_cube {px; py} = fmt "cube: %f %f" px py |> log

let mouse_x, mouse_y = ref 0, ref 0

let update arr =
  let float = float_of_int in
  Array.iter (fun cube ->
      print_cube cube;
      let diff_x, diff_y = float !mouse_x -. cube.px, float !mouse_y -. cube.py in
      let diff_x, diff_y =  (diff_x /. 1000.),  (diff_y /. 1000.) in
      cube.ax <- cube.ax +. diff_x;
      cube.ay <- cube.ay +. diff_y;
      cube.vx <- cube.vx +. cube.ax;
      cube.vy <- cube.vy +. cube.ay;
      cube.px <- cube.px +. cube.vx;
      cube.py <- cube.py +. cube.vy;
      if cube.px > float len_x then begin
        cube.px <- float len_x;
        cube.ax <- -. cube.ax;
        cube.vx <- -. cube.vx;
      end;
      if cube.px < 0. then begin
        cube.px <- 0.;
        cube.ax <- -. cube.ax;
        cube.vx <- -. cube.vx;
      end;
      if cube.py > float len_y then begin
        cube.px <- float len_y;
        cube.ay <- -. cube.ay;
        cube.vy <- -. cube.vy;
      end;
      if cube.py < 0. then begin
        cube.py <- 0.;
        cube.ay <- -. cube.ay;
        cube.vy <- -. cube.vy;
      end
    ) arr

let draw arr (canvas: Html.canvasElement Js.t) =
  let c = canvas##getContext(Html._2d_) in
  let clear_graph c =
    c##strokeStyle <- js "0,0,0";
    c##fillRect (0., 0., (float_of_int len_x), (float_of_int len_y));
    c##strokeStyle <- js "0,255,255";
    c##strokeRect (0., 0., (float_of_int len_x), (float_of_int len_y)) in
  let draw_cubes c arr =
    c##strokeStyle <- js "0,0,255";
    Array.iter (fun item ->
        print_cube item;
        c##arc (item.px, item.py, 5., (10. *. 3.14 /. 180.), (80. *. 3.14 /. 180.), Js._false); ())
      arr in
  clear_graph c; draw_cubes c arr

let (>>=) = Lwt.bind

let array_init () =
  let cube = {px = 0.; py = 0.; vx = 2.0; vy = 2.0; ax = 0.0; ay = 0.0} in
  Random.self_init ();
  let float = fun i -> Random.float (float_of_int i) in
  Array.init 10
    (fun _ -> {cube with px = float len_x; py = float len_y})

let arr = array_init ()

let rec loop canvas =
  Lwt_js.sleep 0.1 >>= fun () ->
  update arr;
  draw arr canvas;
  loop canvas

let handler element =
  Html.addEventListener Html.document Html.Event.mousemove
    begin Html.handler (fun ev ->
        mouse_x := ev##clientX;
        mouse_y := ev##clientY;
        Js._true
      ) end |> ignore;
  Js._true

let create_canvas () =
  let c = Html.createCanvas doc in
  c##width <- len_x;
  c##height <- len_y;
  c

let start _ =
  let canvas = create_canvas () in
  G.open_canvas canvas;
  Dom.appendChild doc##body canvas;
  handler canvas |> ignore;
  loop canvas |> ignore;
  Js._false

let _ =
  Html.window##onload <- Html.handler start
