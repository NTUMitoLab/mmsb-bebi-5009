# # Problem 2.4.6

using DifferentialEquations
using Plots
Plots.default(linewidth=2)

# Using pipe operator |>
ODEProblem((u, p, t) -> p * (1. - u), 0., 10., 1.) |> solve |> plot |> PNG

# ## Runtime information

import InteractiveUtils
InteractiveUtils.versioninfo()

#---

import Pkg
Pkg.status()
