module MCMCChains

using AxisArrays
const axes = Base.axes
using AbstractFFTs
import AbstractMCMC
import AbstractMCMC: chainscat
using Compat
using Distributions
using RecipesBase
using SpecialFunctions
using Formatting
import StatsBase: autocov, counts, sem, AbstractWeights,
    autocor, describe, quantile, sample, summarystats, cov
import MLJModelInterface
import NaturalSort
import PrettyTables
import Tables
import TableTraits
import IteratorInterfaceExtensions

using LinearAlgebra: diag, dot, BlasReal
import Random
import Serialization
import Statistics: std, cor, mean, var, mean!

using StatsModelComparisons

export Chains, chains, chainscat
export setrange, resetrange
export set_section, get_params, sections, sort_sections, setinfo
export replacenames, namesingroup, group
export autocor, describe, sample, summarystats, AbstractWeights, mean, quantile
export ChainDataFrame
export summarize

# Export diagnostics functions
export discretediag, gelmandiag, gewekediag, heideldiag, rafterydiag
export hpd, ess, dic

export rstar

export ESSMethod, FFTESSMethod, BDAESSMethod

"""
    Chains

Parameters:

- `value`: An `AxisArray` object with axes `iter` × `var` × `chains`
- `logevidence` : A field containing the logevidence.
- `name_map` : A `NamedTuple` mapping each variable to a section.
- `info` : A `NamedTuple` containing miscellaneous information relevant to the chain.
The `info` field can be set using `setinfo(c::Chains, n::NamedTuple)`.
"""
struct Chains{T,A<:AxisArray{T,3},L,K<:NamedTuple,I<:NamedTuple} <: AbstractMCMC.AbstractChains
    value::A
    logevidence::L
    name_map::K
    info::I
end

include("utils.jl")
include("chains.jl")
include("constructors.jl")
include("ess.jl")
include("summarize.jl")
include("discretediag.jl")
include("fileio.jl")
include("gelmandiag.jl")
include("gewekediag.jl")
include("heideldiag.jl")
include("mcse.jl")
include("rafterydiag.jl")
include("sampling.jl")
include("stats.jl")
include("modelstats.jl")
include("plot.jl")
include("tables.jl")
include("rstar.jl")

# deprecations
# TODO: Remove dependency on Serialization if this deprecation is removed
# somehow `@deprecate` doesn't work with qualified function names,
# so we use the following hack
const _read = Base.read
const _write = Base.write
@static if VERSION < v"1.1"
    Base.@deprecate _read(
        f::AbstractString,
        ::Type{T}
    ) where {T<:Chains} open(Serialization.deserialize, f, "r") false
    Base.@deprecate _write(
        f::AbstractString,
        c::Chains
    ) open(f, "w") do io
        Serialization.serialize(io, c)
    end false
else
    Base.@deprecate _read(
        f::AbstractString,
        ::Type{T}
    ) where {T<:Chains} Serialization.deserialize(f) false
    Base.@deprecate _write(
        f::AbstractString,
        c::Chains
    ) Serialization.serialize(f, c) false
end

end # module
