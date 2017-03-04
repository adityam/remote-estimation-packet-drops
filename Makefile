output: algorithms.jl simulations.jl acc-results.jl visualizations.jl
	mkdir -p output plots
	julia acc-results.jl

documentation.pdf: documentation.tex
	mkdir -p vimout
	context documentation.tex

documentation.tex: documentation.md template.tex
	pandoc --template=template.tex --to=context --output=documentation.tex \
	  documentation.md

documentation.md: algorithms.jl simulations.jl acc-results.jl
	sed -e 's/^/    /' algorithms.jl \
	  | sed -E 's/^    #[[:space:]]?//' \
	  > documentation.md
	echo -e "\\page\n" >> documentation.md
	sed -e 's/^/    /' simulations.jl \
	  | sed -E 's/^    #[[:space:]]?//' \
	  >> documentation.md
	echo -e "\\page\n" >> documentation.md
	sed -e 's/^/    /' visualizations.jl \
	  | sed -E 's/^    #[[:space:]]?//' \
	  >> documentation.md
	echo -e "\\page\n" >> documentation.md
	sed -e 's/^/    /' acc-results.jl \
	  | sed -E 's/^    #[[:space:]]?//' \
	  >> documentation.md
