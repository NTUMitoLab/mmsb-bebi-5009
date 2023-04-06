#===
# Figure 4.18

Continuation diagram

See also [BifurcationKit.jl](https://github.com/bifurcationkit/BifurcationKit.jl)
===#

import DisplayAs.PNG
using DifferentialEquations
using UnPack
using LabelledArrays
using Plots
Plots.default(linewidth=2)

# Convenience functions
hil(x, k) = x / (x + k)
hil(x, k, n) = hil(x^n, k^n)

#---

function model418!(D, u, p, t)
    @unpack a, b = u
    @unpack k1, k2, k3, k4, k5, n = p
    D.a = k1 * hil(1, b, n) - (k3 + k5) * a
    D.b = k2 + k5 * a - k4 * b
end

function ainf(k1)
    ps = LVector(k1 = k1, k2 = 5.0, k3 = 5.0, k4 = 5.0, k5 = 2.0, n = 4)
    u0 = LVector(a=0., b=0.)
    prob = SteadyStateProblem(model418!, u0, ps)
    sol = solve(prob)
    return sol.u.a
end

#---

plot(
    ainf, 0, 1000,
    title = "Fig 4.18 Continuation diagram",
    xlabel = "K1" , ylabel= "Steady state [A]",
    legend=nothing, ylim=(0, 4), xlim=(0, 1000)
)

# ## Runtime information

import InteractiveUtils
InteractiveUtils.versioninfo()

#---

import Pkg
Pkg.status()
