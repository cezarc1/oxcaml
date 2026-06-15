(* TEST
    flags = "-extension layouts_alpha";
    expect;
*)

module M : sig
  type 'a t : immediate constraint 'a = int
end = struct
  type 'a t = 'a constraint 'a = int
end
[%%expect {|
module M : sig type 'a t : immediate constraint 'a = int end
|}]

module M : sig
  type 'a t : immutable_data constraint 'a = int
end = struct
  type 'a t = Foo of 'a constraint 'a = int
end
[%%expect{|
module M : sig type 'a t : immutable_data constraint 'a = int end
|}]

module M : sig
  type 'a t : immediate constraint 'a = int
end = struct
  type 'a t = Foo of 'a constraint 'a = int
end
[%%expect{|
Lines 3-5, characters 6-3:
3 | ......struct
4 |   type 'a t = Foo of 'a constraint 'a = int
5 | end
Error: Signature mismatch:
       Modules do not match:
         sig type 'a t = Foo of 'a constraint 'a = int end
       is not included in
         sig type 'a t : immediate constraint 'a = int end
       Type declarations do not match:
         type 'a t = Foo of 'a constraint 'a = int
       is not included in
         type 'a t : immediate constraint 'a = int
       The layout of the first is value non_float
         because of the definition of t at line 4, characters 2-43.
       But the layout of the first must be a sublayout of value non_pointer
         because of the definition of t at line 2, characters 2-43.
       Note: The layout of immediate is value non_pointer.
       Note: The kinds mutable_data, immutable_data, and sync_data have
       the layout value non_float.
|}]

module M : sig
  type ('a, 'b) t : immutable_data with 'b * 'b constraint 'a = 'b * 'b
end = struct
  type ('a, 'b) t = Foo of 'a constraint 'a = 'b * 'b
end
[%%expect{|
module M :
  sig type ('a, 'b) t : immutable_data with 'b constraint 'a = 'b * 'b end
|}]

module M : sig
  type ('a, 'b) t : immutable_data with 'a constraint 'a = 'b * 'b
end = struct
  type ('a, 'b) t = Foo of 'a constraint 'a = 'b * 'b
end
[%%expect{|
module M :
  sig type ('a, 'b) t : immutable_data with 'b constraint 'a = 'b * 'b end
|}]

module M : sig
  type ('a : value mod portable, 'b : value mod contended) t : value mod portable contended constraint 'a = 'b
end = struct
  type ('a : value mod portable, 'b : value mod contended) t = 'a constraint 'a = 'b
end
[%%expect{|
module M :
  sig
    type ('b : value mod portable contended, 'a) t
      : value mod portable contended constraint 'a = 'b
  end
|}]

module M : sig
  type ('a : value mod portable, 'b : value mod contended) t : value mod many constraint 'a = 'b
end = struct
  type ('a : value mod portable, 'b : value mod contended) t = 'a constraint 'a = 'b
end
[%%expect{|
Lines 3-5, characters 6-3:
3 | ......struct
4 |   type ('a : value mod portable, 'b : value mod contended) t = 'a constraint 'a = 'b
5 | end
Error: Signature mismatch:
       Modules do not match:
         sig
           type ('b : value mod portable contended, 'a) t = 'b
             constraint 'a = 'b
         end
       is not included in
         sig
           type ('b : value mod portable contended, 'a) t : value mod many
             constraint 'a = 'b
         end
       Type declarations do not match:
         type ('b : value mod portable contended, 'a) t = 'b
           constraint 'a = 'b
       is not included in
         type ('b : value mod portable contended, 'a) t : value mod many
           constraint 'a = 'b
       The mode crossing of the first is not allowed here.
       The inferred ikind is not below the required ikind along: linearity
|}]

module M : sig
  type 'a t : immutable_data with 'b constraint 'a = 'b option
end = struct
  type 'a t = Foo of 'a constraint 'a = 'b option
end
[%%expect {|
module M :
  sig type 'a t : immutable_data with 'b constraint 'a = 'b option end
|}]

module M : sig
  type 'a t : immutable_data with 'b constraint 'a = 'b ref
end = struct
  type 'a t = Foo of 'a constraint 'a = 'b ref
end
[%%expect {|
Lines 3-5, characters 6-3:
3 | ......struct
4 |   type 'a t = Foo of 'a constraint 'a = 'b ref
5 | end
Error: Signature mismatch:
       Modules do not match:
         sig type 'a t = Foo of 'a constraint 'a = 'b ref end
       is not included in
         sig type 'a t : immutable_data with 'b constraint 'a = 'b ref end
       Type declarations do not match:
         type 'a t = Foo of 'a constraint 'a = 'b ref
       is not included in
         type 'a t : immutable_data with 'b constraint 'a = 'b ref
       The mode crossing of the first is not allowed here.
       The inferred ikind is not below the required ikind along: contention, visibility
|}]

module M : sig
  type 'a t : mutable_data with 'b constraint 'a = 'b ref
end = struct
  type 'a t = Foo of 'a constraint 'a = 'b ref
end
[%%expect {|
module M : sig type 'a t : mutable_data with 'b constraint 'a = 'b ref end
|}]

module M : sig
  type 'a t : immutable_data constraint 'a = ('b : immutable_data) list
end = struct
  type 'a t = Foo of 'a constraint 'a = ('b : immutable_data) list
end
[%%expect {|
module M : sig type 'a t : immutable_data constraint 'a = 'b list end
|}]

module M : sig
  type 'a t : immutable_data with 'a constraint 'a = 'b option
end = struct
  type 'a t = Foo of 'a constraint 'a = 'b option
end
[%%expect {|
module M :
  sig type 'a t : immutable_data with 'b constraint 'a = 'b option end
|}]

module M : sig
  type 'a t : immutable_data constraint 'a = ('b : mutable_data) list
end = struct
  type 'a t = Foo of 'a constraint 'a = ('b : mutable_data) list
end
[%%expect {|
Lines 3-5, characters 6-3:
3 | ......struct
4 |   type 'a t = Foo of 'a constraint 'a = ('b : mutable_data) list
5 | end
Error: Signature mismatch:
       Modules do not match:
         sig type 'a t = Foo of 'a constraint 'a = 'b list end
       is not included in
         sig type 'a t : immutable_data constraint 'a = 'b list end
       Type declarations do not match:
         type 'a t = Foo of 'a constraint 'a = 'b list
       is not included in
         type 'a t : immutable_data constraint 'a = 'b list
       The mode crossing of the first is not allowed here.
       The inferred ikind is not below the required ikind along: contention, visibility
|}]
