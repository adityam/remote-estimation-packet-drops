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
include("visualizations.jl")

# The function below computes the results for a particular stochastic
# approximation algorithm for a range of `paramValues`, `discountValues`,
# and `packetDropValues` . If the optional argument `saveRawData` is `true`,
# the traces of the multiple runs are saved in a `.jld` file; if `savePlot` is
# `true`, then the results every combination of `discount` and `packetDrop`
# are saved to a pdf file in the `plots/` directory. The optional values
# `iterations` and `numRuns` determine the number of iterations and runs. The
# optional argument `labeltext` formats the label of each plot and `ylim`
# adjusts the y limits.

function computeTimeSeries(sa, paramValues, discountValues, dropProbValues;
                           iterations=1000, numRuns=100, 
			               saveSummaryData=true, saveRawData = false, savePlot=false,
                           labeltext=label_costly, ylim=:auto)

    for discount in discountValues, dropProb in dropProbValues
        result = Array(DataFrame, length(paramValues))

        for i in 1:length(paramValues)
            param = paramValues[i]
            result[i] = generateOutput(sa, param, discount, dropProb, iterations; 
                                       numRuns=numRuns,
                                       saveSummaryData=saveSummaryData, saveRawData=saveRawData)
        end

        if savePlot
            filename = string("plots/", sa,             "__parameter_", paramValues, 
                              "__discount_", discount,  "__dropProb_" , dropProb)

            plotTimeSeries(filename, paramValues, result;
                           labeltext=labeltext, ylim=ylim)
        end
    end
end

# First we compute the results for packet drop probability $p_d = 0$ (and
# separately verify these results from the values obtained from numerically
# solving Fredholm integral equations. 

computeTimeSeries(sa_costly, linspace(100,700,7), [0.9,1.0], 0.0; 
                  iterations=10_000, numRuns=100, saveRawData = true, savePlot=false)
computeTimeSeries(sa_constrained, linspace(0.1,0.8,8), [0.9,1.0], 0.0; 
                  iterations=10_000, numRuns=100, saveRawData = true, savePlot=false)

# Next, we compute the results for packet drop probability $p_d = 0.3$.

computeTimeSeries(sa_costly, linspace(100,500,3), [0.9,1.0], 0.3; 
                  iterations=10_000, numRuns=100, saveRawData = true, 
                  savePlot=true, labeltext=label_costly, ylim=(0,11))
computeTimeSeries(sa_constrained, linspace(0.1,0.5,3), [0.9,1.0], 0.3; 
                  iterations=10_000, numRuns=100, saveRawData = true,
                  savePlot=true, labeltext=label_constrained, ylim=(0,3.5))
