#!/bin/sh

set -eu

compiler="$1"
tmpdir="${TMPDIR:-/tmp}/ikind-debug-examples.$$"
mkdir -p "$tmpdir"
trap 'rm -rf "$tmpdir"' EXIT

stdlib="${OCAMLSRCDIR:-}/stdlib"
if [ -n "${OCAMLSRCDIR:-}" ] && [ -d "$stdlib" ]; then
  stdlib_flags="-nostdlib -I $stdlib"
else
  stdlib_flags=""
fi

show_interesting_output () {
  awk '
    /Original inferred jkind:/ {
      print;
      getline; print;
      next;
    }
    /Original required jkind:/ {
      print;
      getline; print;
      next;
    }
    /Failing ikind residual:/,/Failing axes:/ {
      print;
      next;
    }
  '
}

run () {
  label="$1"
  file="$tmpdir/$label.ml"
  cat > "$file"
  echo "== $label =="
  if output=$($compiler $stdlib_flags -extension layouts_alpha -ikinds-debug -c "$file" 2>&1); then
    echo "accepted"
  else
    echo "$output" | show_interesting_output
  fi
}

run abstract_plain <<'ML'
module type S = sig
  type r
  type a
  type t : immutable_data with r = a ref
end
ML

run abstract_immediate <<'ML'
module type S = sig
  type r
  type a : immediate
  type t : immutable_data with r = a ref
end
ML

run abstract_immutable <<'ML'
module type S = sig
  type r
  type a : immutable_data
  type t : immutable_data with r = a ref
end
ML

run alias_ref <<'ML'
module type S = sig
  type r
  type a = int ref
  type t : immutable_data with r = a
end
ML

run alias_arrow <<'ML'
module type S = sig
  type r
  type a = int -> int
  type t : immutable_data with r = a
end
ML

run alias_tuple <<'ML'
module type S = sig
  type r
  type a = int ref * (int -> int)
  type t : immutable_data with r = a
end
ML

run parameterized_box <<'ML'
module type S = sig
  type r
  type 'a box : immutable_data with 'a
  type t : immutable_data with r = int ref box
end
ML

run polyvariant_with_abstract <<'ML'
module type S = sig
  type r
  type a
  type t : immutable_data with r = [`A of a ref | `B of int -> int]
end
ML

run object_method <<'ML'
module type S = sig
  type r
  type t : immutable_data with r = < m : int ref >
end
ML

run package_with_ref <<'ML'
module type S = sig
  type r
  module type T = sig type a = int ref end
  type t : immutable_data with r = (module T)
end
ML

run gadt_pack_ref <<'ML'
module type S = sig
  type r
  type t : immutable_data with r = Pack : int ref -> t
end
ML

run existential_pack_ref <<'ML'
module type S = sig
  type r
  type t : immutable_data with r = Pack : 'a ref -> t
end
ML

run universal_record_ref <<'ML'
module type S = sig
  type r
  type t : immutable_data with r = { f : 'a. 'a ref -> int }
end
ML
