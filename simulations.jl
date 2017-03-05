# ---
# name: simulations.jl
# author: Jhelum Chakravorty, Jayakumar Subramanian, Aditya Mahajan
# date: 1 Feb, 2017
# license: BSD 3 clause
# ---
#

@everywhere begin
    include("algorithms.jl")
end

# Traces from multiple runs
# =========================
#
# To visualize how well the stochastic approximation algorithms (implemented
# in `algorithms.jl`) work, we run them multiple times for any particular
# choice of parameters. Since this task is an embarrassingly parallel one, we run
# each trace on a separate core and then combine all the traces.
# This is implemented in the `generateTraces` function below. The inputs to this
# function are:
#
# * `alt` : the key corresponding to stochastic approximation algorithm to be
#   run. The function `saAlt = sa[alt]` must have the signature:
#   
#     `saAlt(param, discount, dropProb; iterations=iterations)`
#
#     `param` corresponds to `cost` for costly communication
#     and `rate` for constrained communication.
# * `param` : A parameter used by the `sa[alt]` function, corresponding to
#   communication cost or rate.
# * `discount`: The discount factor
# * `dropProb`: The packet drop probability.
# * `iterations`: Number of iterations
# 
# It also accepts the following optional argument
# 
# * `numRuns` : The number of runs.
#
# The output is a 2D array of size `iterations * numRuns`, where column
# corresponds to a different traces.

function generateTraces(alt, param, discount, dropProb, iterations; numRuns = 100)
    saAlt  = sa[alt]
    tuples = pmap(_ -> saAlt(param, discount, dropProb; iterations=iterations), 1:numRuns)
    traces = zeros(iterations, numRuns)

    for run in 1:numRuns
        traces[:, run] = tuples[run]
    end

    return traces
end

# Generating and saving results
# =============================
#
# The function `generateOutput` takes the same parameters as `generateTraces`
# plus an additional optional parameter: `saveRawData`, which defaults to
# `false`. It returns a data frame with three columns: mean
# value, mean + 2(standard deviation), mean - 2(standard deviation). These are
# shown in the plots included in the paper. This data is saved to a tab
# separated file (in the `output/` directory). The filename includes the name
# of stochastic approximation algorithm, and values of parameter, discount,
# and dropProb.
#
# When `saveRawData` is set to `true`, the traces are saved to a
# `.jld` file. 

using JLD, DataFrames

function generateOutput(alt, param, discount, dropProb, iterations;
    numRuns  = 100, saveSummaryData = true, saveRawData = false)

    traces = generateTraces(alt, param, discount, dropProb, iterations; numRuns = 100)
    meanValue, std = mean_and_std(traces, 2)

    meanValue = vec(meanValue)
    std       = vec(std)

    # Generate summary statistics.
    stats = DataFrame(mean=meanValue, 
                      upper=meanValue + 2std, lower=meanValue - 2std)

    filename = string("output/", alt,            "__parameter_", param, 
                      "__discount_" , discount,  "__dropProb_" , dropProb)

    if saveSummaryData
      writetable("$filename.tsv", stats, separator='\t', header = true)
    end

    if saveRawData
        save("$filename.jld",         "param", param, 
            "discount", discount,     "dropProb", dropProb,
            "iterations", iterations, "numRuns",  numRuns, 
            "traces", traces,         "meanValue", meanValue,
            "std", std)
    end

    return stats
end
