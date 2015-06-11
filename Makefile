OCAMLC=ocamlfind ocamlc
OCAMLOPT=ocamlfind ocamlopt
OCAMLDEP=ocamlfind ocamldep
OCAMLYACC=ocamlyacc
OCAMLLEX=ocamllex

COMPFLAGS=-package js_of_ocaml.syntax,js_of_ocaml.graphics -syntax camlp4o
DEPFLAGS=$(COMPFLAGS)

OBJS=graph.cmo

graph.js: graph
	js_of_ocaml +graphics.js $^ --pretty
graph: $(OBJS)
	$(OCAMLC) $(COMPFLAGS) -linkall -linkpkg -o graph $<

#####

clean::
	find . -regex ".*\\.\(cm[oix]\|o\)" | xargs rm -f

%.cmx: %.ml
	$(OCAMLOPT) $(OPTCOMPFLAGS) $(COMPFLAGS) -c $<

%.cmi: %.mli
	$(OCAMLC) $(COMPFLAGS) -c $<

%.cmo: %.ml
	$(OCAMLC) $(COMPFLAGS) -c $<

%.ml: %.mly
	$(OCAMLYACC) $<

%.mli: %.mly
	$(OCAMLYACC) $<

%.ml: %.mll
	$(OCAMLLEX) $<

# %.js: %
# 	js_of_ocaml $^ --pretty
