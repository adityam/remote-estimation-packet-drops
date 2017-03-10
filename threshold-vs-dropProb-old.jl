addprocs(Sys.CPU_CORES)
@everywhere begin
    include("algorithms.jl")
end

using Plots
# gr()
pyplot()

function generateTraces(sa, paramValues, discount, dropProbValues;
                        iterations=1000, savePlot=false)

    @inline function computeThreshold(param, dropProb) 
        last(sa(param, discount, dropProb; iterations = iterations))
    end

    thresholds = zeros(Float64, (length(dropProbValues), length(paramValues)))

    for i in 1:length(paramValues)
        param = paramValues[i]
        thresholds[:,i] = pmap(dropProb -> computeThreshold(param, dropProb), dropProbValues)
    end

    if savePlot
        plt = plot(xlabel="Packet Drop Probability", ylabel="Threshold")

        plot!(plt, dropProbValues, thresholds)

        filename = "plots/thresholds-vs-dropProb"

        savefig("$filename.pdf")

    end
end

# generateTraces(sa_costly, linspace(100, 500, 3), 0.9, linspace(0.0, 0.5, 6);
#                 iterations=10_000, savePlot=true)

generateTraces(sa_constrained, linspace(0.1, 0.5, 3), 0.9, linspace(0.0, 0.5, 6);
                iterations=1000, savePlot=true)

