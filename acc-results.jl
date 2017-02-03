# ---
# name: acc-results.jl
# author: Jhelum Chakravorty, Jayakumar Subramanian, Aditya Mahajan
# date: 1 Feb, 2017
# license: BSD 3 clause
# ---
#
# Results presented in ACC'17
# ===========================
# 
# We want to run the simulation code of `simulations.jl` on multiple cores.
# So, as the first step, we make sure we are running multi-core version of
# Julia.

addprocs(Sys.CPU_CORES)
include("simulations.jl")

# We use Plots package with GR backend to plot the results.

using Plots
gr()

# A helper function to display labels

function labeltext(s, param)
    text(string('$', s, "=", param, '$'), 8, :bottom, :right)
end

label_costly(param)      = labeltext("\\lambda", param)
label_constrained(param) = labeltext("\\alpha", param)

# The function below computes the results for a particular stochastic
# approximation algorithm for a range of `paramValues`, `discountValues`,
# and `packetDropValues` . If the optional argument `savePlot` is `true`, then the
# results every combination of `discount` and `packetDrop` are saved to a
# pdf file in the `plots/` directory. The optional values `iterations` and
# `numRuns` determine the number of iterations and runs. The optional argument
# `labeltext` formats the label of each plot and `ylim` adjusts the y limits.

function computeTimeSeries(sa, paramValues, discountValues, dropProbValues;
                           iterations=1000, numRuns=100, savePlot=false,
                           labeltext=label_costly, ylim=:auto)

    for discount in discountValues, dropProb in dropProbValues
        result = Array(DataFrame, length(paramValues))

        for i in 1:length(paramValues)
            param = paramValues[i]
            result[i] = generateOutput(sa, param, discount, dropProb, iterations; 
                                       numRuns=numRuns)
        end

        if savePlot
            plt = plot(xlabel="Iterations", ylabel="Threshold", 
                       aspect_ratio=1.75, ylim=ylim)

            for i in 1:length(paramValues)
                param = paramValues[i]
                df = result[i]
                plot!(plt, df[:upper], linecolor=:lightblue, label="")
                plot!(plt, df[:lower], linecolor=:lightblue, label="",
                     fillrange=df[:upper], fillcolor=:gray, fillalpha=0.8)
                plot!(plt, df[:mean],  linecolor=:black, linewidth=2, label="")

                x=div(3iterations,4)
                y=df[:upper][x] 
                label=labeltext(param)

                plot!(plt,annotations=(x,y,label))
            end

            filename = string("plots/", sa,             "__parameter_", paramValues, 
                              "__discount_" , discount,  "__dropProb_" , dropProb)

            savefig("$filename.pdf")
        end
    end
end

# First we compute the results for packet drop probability $p_d = 0$ (and
# separately verify these results from the values obtained from numerically
# solving Fredholm integral equations. 

computeTimeSeries(sa_costly, linspace(100,700,7), [0.9,1.0], 0.0; 
                  iterations=10_000, numRuns=100, savePlot=false)
computeTimeSeries(sa_constrained, linspace(0.1,0.8,8), [0.9,1.0], 0.0; 
                  iterations=10_000, numRuns=100, savePlot=false)

# Next, we compute the results for packet drop probability $p_d = 0.3$.

computeTimeSeries(sa_costly, linspace(100,500,3), [0.9,1.0], 0.3; 
                  iterations=10_000, numRuns=100, 
                  savePlot=true, labeltext=label_costly, ylim=(0,11))
computeTimeSeries(sa_constrained, linspace(0.1,0.5,3), [0.9,1.0], 0.0; 
                  iterations=1000, numRuns=10,
                  savePlot=true, labeltext=label_costly, ylim=(0,3.5))
