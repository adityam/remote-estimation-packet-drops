documentation.pdf: documentation.tex
	context documentation.tex

documentation.tex: documentation.md template.tex
	pandoc --template=template.tex --to=context --output=documentation.tex \
	  documentation.md

documentation.md: packet-drops.jl
	sed -e 's/^/    /' packet-drops.jl \
	  | sed -E 's/^    #[[:space:]]?//' \
	  > documentation.md
