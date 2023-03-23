#===
# Chapter 4
## Figure 4.1, 4.2, and 4.3

Steady states and phase plots in an assymetric network.
===#

using DifferentialEquations
using LabelledArrays
using UnPack
using Plots
Plots.default(linewidth=2)

# Convenience functions
hil(x, k) = x / (x + k)
hil(x, k, n) = hil(x^n, k^n)

# Model and derivatives
function ∂A41(u, p, t)
    a, b = u
    @unpack k1, k2, k3, k4, k5, n = p
    return da = k1 * hil(1, b, n) - (k3 + k5) * a
end

function ∂B41(u, p, t)
    a, b = u
    @unpack k1, k2, k3, k4, k5, n = p
    return db = k2 + k5 * a - k4 * b
end

function model41!(D, u, p, t)
    D.a = ∂A41(u, p, t)
    D.b = ∂B41(u, p, t)
    return nothing
end

#---

ps1 = (k1=20., k2=5., k3=5., k4=5., k5=2., n=4.)
u0s = [
    LVector(a=0.0, b=0.0),
    LVector(a=0.5, b=0.6),
    LVector(a=0.17, b=1.1),
    LVector(a=0.25, b=1.9),
    LVector(a=1.85, b=1.7),
]

tend = 1.5

sols = map(u0s) do u0
    prob = ODEProblem(model41!, u0, tend, ps1)
    sol = solve(prob)
end

plot(sols[1], xlabel="Time", ylabel="Concentration", title="Fig. 4.2 A (Time series)", labels=["[A]" "[B]"])

#---
plot(sols[1], idxs=(:a, :b), xlabel="[A]", ylabel="[B]", aspect_ratio=:equal,
     title="Fig. 4.2 B (Phase plot)", ylims=(0.0, 2.0), xlims=(0.0, 2.0), legend=nothing)

#---
p43a = plot(title="Fig. 4.3A (Multiple time series)")

for sol in sols
    plot!(p43a, sol, linealpha=0.5, legend=nothing)
end

plot!(p43a, xlabel="Time", ylabel="Concentration")

#---
p43b = plot(title="Fig. 4.3 B (Phase plot)")

for sol in sols
    plot!(p43b, sol, idxs=(:a, :b), legend=nothing)
end

plot!(p43b, xlabel="[A]", ylabel="[B]", xlims=(0., 2.), ylims=(0., 2.), aspect_ratio=:equal)

#===
## Figure 4.4 and 4.5

Vector fields in phase plots.
===#

# In this form we can reuse function name
∂F44 = function (x, y; scale=20)
    da = ∂A41((x, y), ps1, 0.0)
    db = ∂B41((x, y), ps1, 0.0)
    s = sqrt(hypot(da, db)) * scale
    return (da / s, db / s)
end

∂A = function (x, y)
    ∂A41((x, y), ps1, 0.0)
end

∂B = function (x, y)
    ∂B41((x, y), ps1, 0.0)
end

# Grid points
rxy = range(0.0, 2.0, 11)
xx = [x for y in rxy, x in rxy]
yy = [y for y in rxy, x in rxy]

# Figure 4.4A
plot(title="Fig. 4.4 A (Phase plot with vector field)")

quiver!(xx, yy, quiver=∂F44, line=(:lightgrey), arrow=(:closed), aspect_ratio=:equal)

for sol in sols
    plot!(sol, idxs=(:a, :b), linealpha=0.7, legend=nothing)
end

plot!(size=(600, 600), xlims=(rxy[1], rxy[end]), ylims=(rxy[1], rxy[end]), xlabel="[A]", ylabel="[B]")

# Figure 4.5A
plot(title="Fig. 4.5 A (Phase plot with nullclines)")

## Phase plots
for sol in sols
    plot!(sol, idxs=(:a, :b), linealpha=0.7, lab=nothing)
end

## nullclines
contour!(0:0.01:2, 0:0.01:2, ∂A, levels=[0], cbar=false, line=(:black))
plot!(identity, 0, 0, line=(:black), label="A nullcline")  ## Adding a fake line for the legend of A nullcline
contour!(0:0.01:2, 0:0.01:2, ∂B, levels=[0], cbar=false, line=(:black, :dash))
plot!(identity, 0, 0, line=(:black, :dash), label="B nullcline") ## Adding a fake line for the legend of B nullcline
plot!(xlim=(0., 2.), ylim=(0., 2.), legend=:bottomright, size=(600, 600), xlabel="[A]", ylabel="[B]", aspect_ratio=:equal)

#---
plot(title="Fig. 4.5 B (Vector field with nullclines)")
quiver!(xx, yy, quiver=∂F44, line=(:lightgrey), arrow=(:closed), aspect_ratio=:equal)

contour!(0:0.01:2, 0:0.01:2, ∂A, levels=[0], cbar=false, line=(:black))
plot!(identity, 0, 0, line=(:black), label="A nullcline")  ## Adding a fake line for the legend of A nullcline
contour!(0:0.01:2, 0:0.01:2, ∂B, levels=[0], cbar=false, line=(:black, :dash))
plot!(identity, 0, 0, line=(:black, :dash), label="B nullcline") ## Adding a fake line for the legend of B nullcline
plot!(xlim=(0., 2.), ylim=(0., 2.), legend=:bottomright, size=(600, 600), xlabel="[A]", ylabel="[B]")

#===
## Figure 4.7, 4.8, 4.9, and 4.19A

Symmetric (bistable) biological networks.
===#

using DifferentialEquations
using LabelledArrays
using UnPack
using Plots
Plots.default(linewidth=2)

#---

function ∂A47(u, p, t)
    a, b = u
    @unpack k1, k2, k3, k4, n1, n2 = p
    return da = k1 * hil(1, b, n1) - k3 * a
end

function ∂B47(u, p, t)
    a, b = u
    @unpack k1, k2, k3, k4, n1, n2 = p
    return db = k2 * hil(1, a, n2) - k3 * b
end

function model47!(D, u, p, t)
    D.a = ∂A47(u, p, t)
    D.b = ∂B47(u, p, t)
    return nothing
end

#---

ps1 = (k1=20., k2=20., k3=5., k4=5., n1=4., n2=1.)
tend = 4.0

sol1 = solve(ODEProblem(model47!, LVector(a=3., b=1.), tend, ps1))
sol2 = solve(ODEProblem(model47!, LVector(a=1., b=3.), tend, ps1))

p47a1 = plot(sol1, xlabel="Time", ylabel="Concentration", legend=:right, title= "Fig 4.7A (1)")
p47a2 = plot(sol2, xlabel="Time", ylabel="Concentration", legend=:right, title= "Fig 4.7A (2)")
fig47a = plot(p47a1, p47a2, layout=(2, 1), size=(600, 600))

# In this form we can reuse function name
∂F47 = function (x, y; scale=20)
    da = ∂A47((x, y), ps1, 0.0)
    db = ∂B47((x, y), ps1, 0.0)
    s = sqrt(hypot(da, db)) * scale
    return (da / s, db / s)
end

∂A = function (x, y)
    ∂A47((x, y), ps1, 0.0)
end

∂B = function (x, y)
    ∂B47((x, y), ps1, 0.0)
end

# Grid points
r = range(0., 5., 21)
xx = [x for y in r, x in r]
yy = [y for y in r, x in r];

# Fig 4.7 B
plot(title="Fig 4.7 B (Vector field with nullclines)")
quiver!(xx, yy, quiver=∂F47, line=(:lightgrey), arrow=(:closed), aspect_ratio=:equal)

contour!(0:0.01:5, 0:0.01:5, ∂A, levels=[0], cbar=false, line=(:black))
plot!(identity, 0, 0, line=(:black), label="A nullcline")
contour!(0:0.01:5, 0:0.01:5, ∂B, levels=[0], cbar=false, line=(:black, :dash))
plot!(identity, 0, 0, line=(:black, :dash), label="B nullcline")
plot!(xlim=(0, 5), ylim=(0, 5), legend=:topright, size=(600, 600), xlabel="[A]", ylabel="[B]")

# Symmetrical parameter set
ps2 = LVector(k1=20., k2=20., k3=5., k4=5., n1=4., n2=4.)

tend = 4.0
sol1 = solve(ODEProblem(model47!, LVector(a=3., b=1.), tend, ps2))
sol2 = solve(ODEProblem(model47!, LVector(a=1., b=3.), tend, ps2))

pl48a1 = plot(sol1, xlabel="Time", ylabel="Concentration", legend=:right, title= "Fig 4.8A (1)")
pl48a2 = plot(sol2, xlabel="Time", ylabel="Concentration", legend=:right, title= "Fig 4.8A (2)")
fig48a = plot(pl48a1, pl48a2, layout=(2, 1), size=(600, 600))

# In this form we can reuse function name
∂F48 = function (x, y; scale=20)
    da = ∂A47((x, y), ps2, 0.0)
    db = ∂B47((x, y), ps2, 0.0)
    s = sqrt(hypot(da, db)) * scale
    return (da / s, db / s)
end

∂A = function (x, y)
    ∂A47((x, y), ps2, 0.0)
end

∂B = function (x, y)
    ∂B47((x, y), ps2, 0.0)
end

plot(title="Fig 4.8 B")
quiver!(xx, yy, quiver=∂F48, line=(:lightgrey), arrow=(:closed), aspect_ratio=:equal)

contour!(0:0.01:5, 0:0.01:5, ∂A, levels=[0], cbar=false, line=(:black))
plot!(identity, 0, 0, line=(:black), label="A nullcline")
contour!(0:0.01:5, 0:0.01:5, ∂B, levels=[0], cbar=false, line=(:black, :dash))
plot!(identity, 0, 0, line=(:black, :dash), label="B nullcline")
plot!(xlim=(0, 5), ylim=(0, 5), legend=:topright, size=(600, 600), xlabel="[A]", ylabel="[B]")

# Fig 4.8 B

r2 = range(1.0, 1.5, 16)
xx2 = [x for y in r2, x in r2]
yy2 = [y for y in r2, x in r2]

plot(title="Fig 4.8 B (close up)")

quiver!(xx2, yy2, quiver=(x, y)-> ∂F48(x, y; scale=60), line=(:lightgrey), arrow=(:closed), aspect_ratio=:equal)
contour!(1:0.01:1.5, 1:0.01:1.5, ∂A, levels=[0], cbar=false, line=(:black))
plot!(identity, 0, 0, line=(:black), label="A nullcline")
contour!(1:0.01:1.5, 1:0.01:1.5, ∂B, levels=[0], cbar=false, line=(:black, :dash))
plot!(identity, 0, 0, line=(:black, :dash), label="B nullcline")
plot!(xlim=(1, 1.5), ylim=(1, 1.5), legend=:topright, size=(600, 600), xlabel="[A]", ylabel="[B]")

# Another way to draw nullclines is to find the analytical solution when dA (or dB) is zero.

nca47(b, p) = p.k1 / p.k3 * hil(1, b, p.n1)
ncb47(a, p) = p.k2 / p.k4 * hil(1, a, p.n2)

pls = map((8.0, 16.0, 20.0, 35.0)) do k1
    ps = LVector(k1=k1, k2=20., k3=5., k4=5., n1=4., n2=4.)
    pl = plot(b -> nca47(b, ps), identity, 0., 7., label="Nullcline A")
    plot!(pl, identity, a -> ncb47(a, ps), 0., 7., label="Nullcline B")
    plot!(pl, title = "K1 = $k1", xlim=(0., 7.), ylim=(0., 7.), aspect_ratio = :equal, xlabel="[A]", ylabel="[B]")
    pl
end

plot(pls..., size = (800, 800))

# ## Figure 4.11
# Surface plots reference: [surface plots @ PlotsGallery.jl](https://goropikari.github.io/PlotsGallery.jl/src/surface.html)


using Plots
Plots.default(linewidth=2)

z1(x, y) = x^2 + 0.5y^2
z2(x, y) = (.2x^2-1)^2 + y^2
x1 = y1 = range(-1.0, 1.0, 41)
x2 = range(-2.75, 2.75, 41)
y2 = range(-0.75, 0.75, 41)
p1 = surface(x1, y1, z1, title="Single-well potential")
p2 = contourf(x1, y1, z1)
p3 = surface(x2, y2, z2, title="Double-well potential")
p4 = contourf(x2, y2, z2)

plot(p1, p2, p3, p4, size=(800, 600))

# ## Figure 4.15, 4.16, and 4.17
# Oscillatory networks.

using DifferentialEquations
using LabelledArrays
using UnPack
using Plots
Plots.default(linewidth=2)

#---

function dA415(u, p, t)
    a, b = u
    @unpack k0, k1, k2, n = p
    return dA = k0 - k1 * a * (1 + b^n)
end

function dB415(u, p, t)
    a, b = u
    @unpack k0, k1, k2, n = p
    return dB = k1 * a * (1 + b^n) - k2 * b
end

function model415!(D, u, p, t)
    D.a = dA415(u, p, t)
    D.b = dB415(u, p, t)
    return nothing
end

#---

ps1 = (k0 = 8., k1 = 1., k2 = 5., n = 2.)
u0s = (
    LVector(a=1.5, b=1.0),
    LVector(a=0.0, b=1.0),
    LVector(a=0.0, b=3.0),
    LVector(a=2.0, b=0.0),
)

tend = 8.
sols = map(u0s) do u0
    solve(ODEProblem(model415!, u0, tend, ps1))
end

plot(sols[1], xlabel="Time", ylabel="Concentration", title ="Fig 4.15 (A)", xlims=(0., 8.))

# In this form we can reuse function name
∂F415 = function (x, y; scale=20)
    da = dA415((x, y), ps1, 0.0)
    db = dB415((x, y), ps1, 0.0)
    s = sqrt(hypot(da, db)) * scale
    return (da / s, db / s)
end

∂A = function (x, y)
    dA415((x, y), ps1, 0.0)
end

∂B = function (x, y)
    dB415((x, y), ps1, 0.0)
end

# Grid points
r = range(0, 4, 21)
xx = [x for y in r, x in r]
yy = [y for y in r, x in r];

plot(title="Fig 4.15 B")
quiver!(xx, yy, quiver=∂F415, line=(:lightgrey), arrow=(:closed), aspect_ratio=:equal)
contour!(0:0.01:4, 0:0.01:4, ∂A, levels=[0], cbar=false, line=(:black))
plot!(identity, 0, 0, line=(:black), label="A nullcline")
contour!(0:0.01:4, 0:0.01:4, ∂B, levels=[0], cbar=false, line=(:black, :dash))
plot!(identity, 0, 0, line=(:black, :dash), label="B nullcline")
for sol in sols
    plot!(sol, idxs=(:a, :b), label=nothing)
end
plot!(xlim=(0, 4), ylim=(0, 4), legend=:topright, size=(600, 600), xlabel="[A]", ylabel="[B]")

# Oscillatory parameter set

ps2 = (k0 = 8., k1 = 1., k2 = 5., n = 2.5)
tend = 100.0
u0s = (
    LVector(a=1.5, b=1.0),
    LVector(a=0.0, b=1.0),
    LVector(a=0.0, b=3.0),
    LVector(a=2.0, b=0.0),
)

sols = map(u0s) do u0
    solve(ODEProblem(model415!, u0, tend, ps2))
end

plot(sols[1], xlabel="Time", ylabel="Concentration", title ="Fig 4.16(A)", xlims=(0., 8.))

# In this form we can reuse function name
∂F416 = function (x, y; scale=20)
    da = dA415((x, y), ps2, 0.0)
    db = dB415((x, y), ps2, 0.0)
    s = sqrt(hypot(da, db)) * scale
    return (da / s, db / s)
end

∂A = function (x, y)
    dA415((x, y), ps2, 0.0)
end

∂B = function (x, y)
    dB415((x, y), ps2, 0.0)
end

# Grid points
r = range(0, 4, 21)
xx = [x for y in r, x in r]
yy = [y for y in r, x in r];

# Fig 4.16
plot(title="Fig 4.16 B")
quiver!(xx, yy, quiver=∂F416, line=(:lightgrey), arrow=(:closed), aspect_ratio=:equal)
contour!(0:0.01:4, 0:0.01:4, ∂A, levels=[0], cbar=false, line=(:black))
plot!(identity, 0, 0, line=(:black), label="A nullcline")
contour!(0:0.01:4, 0:0.01:4, ∂B, levels=[0], cbar=false, line=(:black, :dash))
plot!(identity, 0, 0, line=(:black, :dash), label="B nullcline")
for sol in sols
    plot!(sol, idxs=(:a, :b), label=nothing)
end
plot!(xlim=(0, 4), ylim=(0, 4), legend=:topright, size=(600, 600), xlabel="[A]", ylabel="[B]")

# Fig 4.17
sol = solve(ODEProblem(model415!, LVector(a=2.0, b=1.5), 10.0, ps2))

plot(title="Fig 4.17")
plot!(sol, idxs=(:a, :b), label=nothing, arrow=:closed)
quiver!(xx, yy, quiver=∂F416, line=(:lightgrey), arrow=(:closed), aspect_ratio=:equal)
contour!(1:0.01:3, 1:0.01:3, ∂A, levels=[0], cbar=false, line=(:black))
plot!(identity, 0, 0, line=(:black), label="A nullcline")
contour!(1:0.01:3, 1:0.01:3, ∂B, levels=[0], cbar=false, line=(:black, :dash))
plot!(identity, 0, 0, line=(:black, :dash), label="B nullcline")
plot!(xlims=(1, 3), ylims=(1, 3), legend=:topright, size=(600, 600), xlabel="[A]", ylabel="[B]")

#===
## Figure 4.18 Continuation diagram

See also [BifurcationKit.jl](https://github.com/bifurcationkit/BifurcationKit.jl)
===#

using DifferentialEquations
using LabelledArrays
using Plots
Plots.default(linewidth=2)

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

# ## Figure 4.22 Tangent line

using Plots
Plots.default(linewidth=2)

plot(title="Fig 4.22 Tangent line")
plot!(t -> 3 / (t-2), 2.2, 8.0, lab="Curve")
plot!(t -> 1.5 - (t - 4) * 0.75, 2.7, 5.3, lab="Tangent line")
plot!(xlabel="Reaction rate", ylabel="Inhibitor concentration",
      xlims=(2., 8.), ylims=(0., 4.))

# ## Runtime information

import InteractiveUtils
InteractiveUtils.versioninfo()

#---

import Pkg
Pkg.status()
