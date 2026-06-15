(* TEST
 flags = "-extension small_numbers";
 expect;
*)

type ('a : value_or_null) aliased_t : value_or_null mod aliased =
  { aliased : 'a }
[@@unboxed]

[%%expect{|
Lines 1-3, characters 0-11:
1 | type ('a : value_or_null) aliased_t : value_or_null mod aliased =
2 |   { aliased : 'a }
3 | [@@unboxed]
Error: The mode crossing of type "aliased_t" is not allowed here.
       The inferred ikind is not below the required ikind along: uniqueness
|}]
