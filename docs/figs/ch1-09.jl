#===

# Fig 1.09
Hodgkin-Huxley model

===#
using OrdinaryDiffEq
using ModelingToolkit
using Plots
Plots.default(linewidth=2)

# Convenience functions
hil(x, k) = x / (x + k)
hil(x, k, n) = hil(x^n, k^n)
exprel(x) = x / expm1(x)

# HH Neuron model
function build_hh(;name)
    @parameters begin
        E_N = 55.0       ## Reversal potential of Na (mV)
        E_K = -72.0      ## Reversal potential of K (mV)
        E_LEAK = -49.0   ## Reversal potential of leaky channels (mV)
        G_N_BAR = 120.0  ## Max. Na channel conductance (mS/cm^2)
        G_K_BAR = 36.0   ## Max. K channel conductance (mS/cm^2)
        G_LEAK = 0.30    ## Max. leak channel conductance (mS/cm^2)
        C_M = 1.0        ## membrane capacitance (uF/cm^2))
    end

    @independent_variables t

    @variables begin
        mα(t)
        mβ(t)
        hα(t)
        hβ(t)
        nα(t)
        nβ(t)
        iNa(t)
        iK(t)
        iLeak(t)
        iStim(t)
        v(t) = -59.8977
        m(t) = 0.0536
        h(t) = 0.5925
        n(t) = 0.3192
    end

    D = Differential(t)

    eqs = [
        mα ~ exprel(-0.10 * (v + 35)),
        mβ ~ 4.0 * exp(-(v + 60) / 18.0),
        hα ~ 0.07 * exp(- ( v + 60) / 20),
        hβ ~ 1 / (exp(-(v+30)/10) + 1),
        nα ~ 0.1 * exprel(-0.1 * (v+50)),
        nβ ~ 0.125 * exp( -(v+60) / 80),
        iNa ~ G_N_BAR * (v - E_N) * (m^3) * h,
        iK  ~ G_K_BAR * (v - E_K) * (n^4),
        iLeak ~ G_LEAK * (v - E_LEAK),
        iStim ~ -6.6 * (20 < t) * (t < 21) + (-6.9) * (60 < t) * (t < 61),
        D(v) ~ -(iNa + iK + iLeak + iStim) / C_M,
        D(m) ~ -(mα + mβ) * m + mα,
        D(h) ~ -(hα + hβ) * h + hα,
        D(n) ~ -(nα + nβ) * n + nα,
    ]

    return ODESystem(eqs, t; name)
end

#---
tend = 100.0
@mtkbuild sys = build_hh()
prob = ODEProblem(sys, [], tend, [])

#---
sol = solve(prob, tstops=[20., 60.])

#---
@unpack v, m, h, n, iStim = sys
p1 = plot(sol, idxs=[v], ylabel="Membrane potential (mV)", xlabel="", legend=false, title="Fig 1.9")
p2 = plot(sol, idxs = [m, h, n], xlabel="")
p3 = plot(sol, idxs = [iStim], xlabel="Time (ms)", ylabel="Current", labels="Stimulation current")
plot(p1, p2, p3, layout=(3, 1), size=(600, 900), leftmargin=5*Plots.mm)
