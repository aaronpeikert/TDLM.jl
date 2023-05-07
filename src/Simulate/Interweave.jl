"""
    interweave(is...; ns = missing)

Interweave takes a number of iterators and returns them alternating till one runs out of elements.

```jldoctest; setup = :(using TDLM.Simulate)
julia> collect(interweave(1:2, 11:12))
4-element Vector{Int64}:
  1
 11
  2
 12

 julia> collect(interweave(1:3, Iterators.cycle(0), ns = (1, 2)))
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
```
"""

interweave(is...; ns = missing) = Interweave(is; ns)
struct Interweave{Is}
    is::Is
    ns::Tuple
    function Interweave(is::T; ns = missing) where T
        ns = ismissing(ns) ? ones_for_tuple(T) : ns
        length(ns) != length(is) && throw(ArgumentError("`ns` must be the same length as `is`."))
        new{T}(is, ns)
    end
end
Interweave(is...; ns = missing) = Interweave(is; ns = ns)

tuple_length(::Type{<:NTuple{N, Any}}) where {N} = Val{N}()
tuple_length(x) = tuple_length(typeof(x))
ones_for_tuple(x::Type{<:NTuple{N, Any}}) where {N} = ntuple(_ -> 1, tuple_length(x))
ones_for_tuple(x) = ones_for_tuple(typeof(x))

function Base.iterate(S::Interweave)
    iters = map(Iterators.Stateful, S.is)
    iters = map(Iterators.Take, iters, S.ns)
    Base.iterate(S, (iters, iterate(iters)))    
end

struct InterweaveState
    outer
    outer_bundle
    ns
    ns_bundle
    inner
    inner_state
end

function Base.iterate(s::Interweave, state::InterweaveState = InterweaveState(missing, missing, missing, missing, missing, missing))
    if ismissing(state.outer_bundle)
        outer = Iterators.cycle(map(Iterators.Stateful, s.is))
        outer_bundle = iterate(outer)
        ns = Iterators.cycle(s.ns)
        ns_bundle = iterate(ns)
    else
        outer = state.outer
        outer_bundle = state.outer_bundle
        ns = state.ns
        ns_bundle = state.ns_bundle
    end

    if ismissing(state.inner_state)
        if isinf(ns_bundle[1])
            inner = outer_bundle[1]
        else
            inner = Iterators.take(outer_bundle[1], ns_bundle[1])
        end
        inner_bundle = iterate(inner)
        inner_bundle === nothing && return nothing
        return inner_bundle[1], InterweaveState(outer, outer_bundle, ns, ns_bundle, inner, inner_bundle[2])
    end

    inner_bundle = iterate(state.inner, state.inner_state)

    if inner_bundle === nothing
        outer_bundle = iterate(outer, outer_bundle[2])
        ns_bundle = iterate(ns, ns_bundle[2])
        return iterate(s, InterweaveState(outer, outer_bundle, ns, ns_bundle, missing, missing))
    else
        return inner_bundle[1], InterweaveState(state.outer, state.outer_bundle, state.ns, state.ns_bundle, state.inner, inner_bundle[2])
    end
end
Base.IteratorSize(::Type{Interweave{T}}) where {T} = Base.SizeUnknown()
function Base.eltype(::Type{Interweave{T}}) where {T}
    promote_type(map(eltype, fieldtypes(T))...)
end
