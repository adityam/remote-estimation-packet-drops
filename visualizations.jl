# ---
# name: visaulizations.jl
# author: Jhelum Chakravorty, Jayakumar Subramanian, Aditya Mahajan
# date: 1 Feb, 2017
# license: BSD 3 clause
# ---

# We use Plots package with GR backend to plot the results.

using Plots
gr()

# A helper function to display labels

function labeltext(s, param)
    text(string('$', s, "=", param, '$'), 8, :bottom, :right)
end

label_costly(param)      = labeltext("\\lambda", param)
label_constrained(param) = labeltext("\\alpha", param)

label = Dict{Symbol, Function}()
label[:costly] = label_costly
label[:constrained] = label_constrained

# Helper for y-limits

ylims = Dict{Symbol, Tuple{Float64, Float64}}()
ylims[:costly]      = (0.0, 11.0)
ylims[:constrained] = (0.0, 3.5)

# The function below plots time series for different values of the parameters.
# `alt` is the key corresponding to the stochastic approximation algorithm.
# The `timeSeries` is an array of data frames, where each data frame has three
# columns: `mean`, `upper`, and `lower`. The optional argument `labeltext`
# formats the label of each plot and `ylim` adjusts the y limits.

function plotTimeSeries(filename, paramValues, timeSeries;
                        labeltext=label_costly, ylim=:auto)

    plt = plot(xlabel="Iterations", ylabel="Threshold", ylim=ylim)

    for i in 1:length(paramValues)
        param = paramValues[i]
        df    = timeSeries[i]

        plot!(plt, df[:upper], linecolor=:lightblue, label="")
        plot!(plt, df[:lower], linecolor=:lightblue, label="",
             fillrange=df[:upper], fillcolor=:lightgray, fillalpha=0.8)
        plot!(plt, df[:mean],  linecolor=:black, linewidth=2, label="")

        iterations = size(df,1)

        x = div(3iterations,4)
        y = df[:upper][x]
        label = labeltext(param)

        plot!(plt,annotations=(x,y,label))
    end

    savefig("$filename.pdf")
end
