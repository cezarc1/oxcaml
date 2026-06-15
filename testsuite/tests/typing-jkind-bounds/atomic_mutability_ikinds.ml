(* TEST
   expect;
*)

(**** atomic vs non-atomic mutable fields ****)

(* Records: all atomic fields are sync_data. *)
type t : sync_data =
  { mutable x : int [@atomic]; mutable y : int [@atomic] }
[%%expect {|
type t = { mutable x : int [@atomic]; mutable y : int [@atomic]; }
|}]

(* Records: any non-atomic mutable field is not sync_data. *)
type t : sync_data = { mutable x : int }
[%%expect {|
Line 1, characters 0-40:
1 | type t : sync_data = { mutable x : int }
    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Error: The mode crossing of type "t" is not allowed here.
       The inferred ikind is not below the required ikind along: contention
|}]

type t : sync_data =
  { mutable x : int; mutable y : int [@atomic] }
[%%expect {|
Lines 1-2, characters 0-48:
1 | type t : sync_data =
2 |   { mutable x : int; mutable y : int [@atomic] }
Error: The mode crossing of type "t" is not allowed here.
       The inferred ikind is not below the required ikind along: contention
|}]

(* Variants: atomic record payloads are sync_data. *)
type t : sync_data = A of { mutable x : int [@atomic] } | B
[%%expect {|
type t = A of { mutable x : int [@atomic]; } | B
|}]

(* Variants: any non-atomic mutable field is not sync_data. *)
type t : sync_data = A of { mutable x : int } | B
[%%expect {|
Line 1, characters 0-49:
1 | type t : sync_data = A of { mutable x : int } | B
    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Error: The mode crossing of type "t" is not allowed here.
       The inferred ikind is not below the required ikind along: contention
|}]

type t : sync_data =
  A of { mutable x : int; mutable y : int [@atomic] }
[%%expect {|
Lines 1-2, characters 0-53:
1 | type t : sync_data =
2 |   A of { mutable x : int; mutable y : int [@atomic] }
Error: The mode crossing of type "t" is not allowed here.
       The inferred ikind is not below the required ikind along: contention
|}]
