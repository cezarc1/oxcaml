(* TEST
 setup-ocamlc.byte-build-env;
 script = "sh ${test_source_directory}/debug_ikinds_examples.sh ${ocamlc_byte}";
 output = "debug_ikinds.output";
 script;
 check-program-output;
*)

(* The test body lives in [debug_ikinds_examples.sh] so each bad bound can be
   compiled independently. *)
