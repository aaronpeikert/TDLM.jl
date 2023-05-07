export interweave

"""
    interweave(is...; limiters = 1)

Interweave takes a number of iterators and returns them alternating till one runs out of elements.
By default it returns one element per iterator, but limimters accept (a) function(s) that controls when alternation occurs.

```jldoctest; setup = :(using TDLM.Simulate)
julia> collect(interweave(1:2, 11:12))
4-element Vector{Int64}:
  1
 11
  2
 12

julia> collect(interweave(1:3, Iterators.cycle(0), limiters = (1, 2)))
9-element Vector{Int64}:
 1
 0
 0
 2
 0
 0
 3
 0
 0

julia> collect(interweave(1:3, 11:13, limiters = x -> random_length(x, [1 2])));

```
"""
interweave(is...; limiters = 1) = Interweave(is, limiters)

struct Interweave{Is, K}
    is::Is
    limiters::NTuple{K, Function}
    function Interweave(is::Is, limiters::NTuple{K, Function}) where {Is, K}
        K != length(is) && throw(ArgumentError("`limiters` must be the same length as `is`."))
        new{Is, K}(is, limiters)
    end
end
function Interweave(is, limiter::Function)
    Interweave(is, tuple_repeat_along(is, limiter))
end
function Interweave(is, limiter::Int)
    Interweave(is, x -> Iterators.take(x, limiter))
end
function Interweave(is, limiters::Union{Tuple{Vararg{T}}, AbstractVector{<:T}}) where T <: Int
    Interweave(is, tuple((x -> Iterators.take(x, l) for l in limiters)...))
end

tuple_length(::Type{<:NTuple{N, Any}}) where {N} = Val{N}()
tuple_length(x) = tuple_length(typeof(x))
tuple_repeat_along(x::T, t) where {T<: Tuple} = ntuple(_ -> t, tuple_length(T))

struct InterweaveState
    outer
    outer_bundle
    inner
    inner_state
end

function Base.iterate(s::Interweave)
    is = Iterators.cycle(map(Iterators.Stateful, s.is))
    limiters = Iterators.cycle(s.limiters)
    outer = zip(is, limiters)
    outer_bundle = iterate(outer)
    iterate(s, InterweaveState(outer, outer_bundle, missing, missing))
end

function Base.iterate(s::Interweave, state::InterweaveState)
    if ismissing(state.inner_state)
        inner = state.outer_bundle[1][2](state.outer_bundle[1][1])
        inner_bundle = iterate(inner)
        inner_bundle === nothing && return nothing
        return inner_bundle[1], InterweaveState(state.outer, state.outer_bundle, inner, inner_bundle[2])
    end

    inner_bundle = iterate(state.inner, state.inner_state)

    if inner_bundle === nothing
        outer_bundle = iterate(state.outer, state.outer_bundle[2])
        return iterate(s, InterweaveState(state.outer, outer_bundle, missing, missing))
    else
        return inner_bundle[1], InterweaveState(state.outer, state.outer_bundle, state.inner, inner_bundle[2])
    end
end
Base.IteratorSize(::Type{Interweave{T1, T2}}) where {T1,T2} = Base.SizeUnknown()
function Base.eltype(::Type{Interweave{T1, T2}}) where {T1,T2}
    promote_type(map(eltype, fieldtypes(T1))...)
end
