using Distributed

# For all processes
@everywhere begin
    import Pkg
    Pkg.activate(@__DIR__)

    using Literate
    config = Dict("mdstrings" => true)
end

folder = joinpath(@__DIR__, "docs")

nbs = (
    "hw-01.jl",
    "intro-01-first-steps.jl",
    "intro-02-plotting.jl",
    "intro-03-diffeq.jl",
    "intro-04-gillespie.jl",
    "mmsb-1.jl",
    "mmsb-2.jl",
    "mmsb-3.jl",
    "mmsb-4.jl",
    "mmsb-5.jl",
)

ts = pmap(nbs; on_error=identity) do nb
    @elapsed Literate.notebook(joinpath(folder, nb), folder; config)
end

for (nb, t) in zip(nbs, ts)
    println(nb, " elapsed/error: ", t)
end

# using Literate

# Literate.notebook("docs/hw-01.jl", "docs/"; config)
# Literate.notebook("docs/intro-01-first-steps.jl", "docs/"; config)
# Literate.notebook("docs/intro-02-plotting.jl", "docs/"; config)
# Literate.notebook("docs/intro-03-diffeq.jl", "docs/"; config)
# Literate.notebook("docs/intro-04-gillespie.jl", "docs/"; config)
# Literate.notebook("docs/mmsb-1.jl", "docs/"; config)
# Literate.notebook("docs/mmsb-2.jl", "docs/"; config)
# Literate.notebook("docs/mmsb-3.jl", "docs/"; config)
# Literate.notebook("docs/mmsb-4.jl", "docs/"; config)
# Literate.notebook("docs/mmsb-5.jl", "docs/"; config)
