This repository contains [Julia] code that reproduces the results presented
in the paper:

> J. Chakravorty, J. Subramanian, A. Mahajan, "Stochastic approximation based
> methods for computing the optimal thresholds in remote-state estimation
> with packet drops," in proceedings of the American Control Conference,
> Seattle, WA, 2017.

The code is released under BSD 3-clause license. 

The repository contains four main files:

- [`algorithms.jl`](algorithms.jl): which implements the stochastic
  approximation algorithms to compute the optimal thresholds.
- [`simulations.jl`](simulations.jl): which generates traces and summary
  statistics for the stochastic approximation algorithms.
- [`visualizations.jl`](visualizations.jl): which plots the output of the
  stochastic approximation algorithms.
- [`acc-results.jl`](acc-results.jl): which runs the algorithms for the
  parameters specified in the ACC`17 paper.

The file [documentation.pdf](documentation.pdf) is a typeset version of the
source code.

The [Makefile](Makefile) has two main targets: 

- `output`, which runs the code and stores the raw data in the `output`
  directory and plots in the `plots` directory. 
- `documentation.pdf`, which generates the documentation.

Thus, the simples way to generate the plots is:

    make output

or, if you want to do it manually,

    mkdir -p output plots
    julia acc-results.jl

## Dependencies 

The code has following dependencies:

- [JLD.jl]
- [DataFrames.jl]
- [Plots.jl]
- [GR.jl]

[JLD.jl]: https://github.com/JuliaIO/JLD.jl
[DataFrames.jl]: https://github.com/JuliaStats/DataFrames.jl
[Plots.jl]: https://github.com/JuliaPlots/Plots.jl
[GR.jl]: https://github.com/jheinen/GR.jl

Generating the documentation requires:

- [Pandoc]
- [sed]
- [ConTeXt]

[Pandoc]: http://pandoc.org
[sed]: https://www.gnu.org/software/sed/manual/sed.html
[ConTeXt]: http://wiki.contextgarden.net
[Julia]: http://julialang.org
