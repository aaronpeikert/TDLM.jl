export RandomLength, Chain


"""
RandomLength(xs, dist)

`RandomLength` wraps a sequence but returns the first `n` elements, where `n` is choosen randomly based on `dist`.

```jldoctest; setup = :(using TDLM.Simulate, StableRNGs)
julia> S = RandomLength(1:100, [1 3]; rng = StableRNG(42));

julia> collect(S)
3-element Vector{Int64}:
 1
 2
 3 
julia> collect(S)
1-element Vector{Int64}:
 1
```
"""
struct RandomLength{I}
    xs::I
    dist
    fun
    rng
    RandomLength(xs::I, dist; fun = first, rng = Random.GLOBAL_RNG) where I = new{I}(xs, dist, fun, rng)
end

function Base.iterate(S::RandomLength, state = (S.fun(rand(S.rng, S.dist, 1)), ))
    n, rest = state[1], Iterators.tail(state)
    n <= 0 && return nothing
    y = iterate(S.xs, rest...)
    y === nothing && return nothing
    return y[1], (n - 1, y[2])
end

Base.eltype(::Type{RandomLength{T}}) where {T} = eltype(T)
Base.IteratorSize(::Type{RandomLength{T}}) where {T} = Base.SizeUnknown()

"""
    Chain(iterators...)

Chain simply connects iterators but instead of collecting them, it returns again an iterator.

```jldoctest; setup = :(using TDLM.Simulate, StableRNGs)
julia> S = Chain(1:2, 100:102)
Chain{Tuple{UnitRange{Int64}, UnitRange{Int64}}}((1:2, 100:102))
julia> collect(S)
5-element Vector{Int64}:
   1
   2
 100
 101
 102
```
"""
struct Chain{Is}
    is::Is
end

Chain(i...) = Chain(i)

function Base.iterate(S::Chain, state = (1, ))
    n, rest = state[1], Iterators.tail(state)
    length(S.is) < n && return nothing
    result = iterate(S.is[n], rest...)
    if result === nothing
        return iterate(S, (n + 1, ))
    else
        return result[1], (n, result[2])
    end
end

Base.IteratorSize(::Type{Chain{T}}) where {T} = Base.SizeUnknown()
function Base.eltype(::Type{Chain{T}}) where {T}
    promote_type(map(eltype, fieldtypes(T))...)
end

struct Interweave{Is}
    is::Is
    length::Tuple
    function Interweave(i::T; length = missing) where T
        length = ismissing(length) ? ones_for_tuple(T) : length
        new{T}(i, length)
    end
end
Interweave(i...; length = missing) = Interweave(i; length = length)

tuple_length(::Type{<:NTuple{N, Any}}) where {N} = Val{N}()
tuple_length(x) = tuple_length(typeof(x))
ones_for_tuple(x::Type{<:NTuple{N, Any}}) where {N} = ntuple(_ -> 1, tuple_length(x))
ones_for_tuple(x) = ones_for_tuple(typeof(x))

s = Interweave(1:3, 6:8; length = (2, 2))


function Base.iterate(S::Interweave)
    iters = map(Iterators.Stateful, S.is)
    iters = map(Iterators.Take, iters, S.length)
    Base.iterate(S, (iters, iterate(iters)))    
end

function Base.iterate(S::Interweave, state)
    iters = state[1]
    iter = state[2][1]
    result = iterate(iter)
    while result === nothing
        iter = iterate(iters, state[2][2])
        iter === nothing && return nothing
        result = iterate(iter[1])
    end
end

# @propagate_inbounds function iterate(f::Flatten, state=())
#     if state !== ()
#         y = iterate(tail(state)...)
#         y !== nothing && return (y[1], (state[1], state[2], y[2]))
#     end
#     x = (state === () ? iterate(f.it) : iterate(f.it, state[1]))
#     x === nothing && return nothing
#     y = iterate(x[1])
#     while y === nothing
#          x = iterate(f.it, x[2])
#          x === nothing && return nothing
#          y = iterate(x[1])
#     end
#     return y[1], (x[2], x[1], y[2])
# end

S = (1:6, 6:12)

struct InterweaveState
    statefuls
    which
    current
    current_state
end

function test(S)
    stateful = map(Iterators.Stateful, S.is)
    which = 1
    current = Iterators.take(stateful[which], S.length[which])
    current_bundle = iterate(current)
    return current_bundle[1], InterweaveState(stateful, which, current, current_bundle[2])
end

S, state = test(S)

S1 = Iterators.Stateful(1:3)
S2 = Iterators.Stateful(6:10)
is = (S1, S2)


outer_bundle = "the current iterator [1] and the outer state [2]"
inner_bundle = "the current result [1] and the inner state"

struct InterweaveState
    outer
    outer_bundle
    length
    length_bundle
    inner
    inner_state
end

function Base.iterate(s::Interweave, state::InterweaveState = InterweaveState(missing, missing, missing, missing, missing, missing))
    if ismissing(state.outer_bundle)
        outer = Iterators.cycle(map(Iterators.Stateful, s.is))
        outer_bundle = iterate(outer)
        length = Iterators.cycle(s.length)
        length_bundle = iterate(length)
    else
        outer = state.outer
        outer_bundle = state.outer_bundle
        length = state.length
        length_bundle = state.length_bundle
    end

    if ismissing(state.inner_state)
        if isinf(length_bundle[1])
            inner = outer_bundle[1]
        else
            inner = Iterators.take(outer_bundle[1], length_bundle[1])
        end
        inner_bundle = iterate(inner)
        inner_bundle === nothing && return nothing
        return inner_bundle[1], InterweaveState(outer, outer_bundle, length, length_bundle, inner, inner_bundle[2])
    end

    inner_bundle = iterate(state.inner, state.inner_state)

    if inner_bundle === nothing
        outer_bundle = iterate(outer, outer_bundle[2])
        length_bundle = iterate(length, length_bundle[2])
        return test(s, InterweaveState(outer, outer_bundle, length, length_bundle, missing, missing))
    else
        return inner_bundle[1], InterweaveState(state.outer, state.outer_bundle, state.length, state.length_bundle, state.inner, inner_bundle[2])
    end
end
Base.IteratorSize(::Type{Interweave{T}}) where {T} = Base.SizeUnknown()

#import TDLM; using TDLM.Simulate
nosignal = Iterators.cycle(0)
signal = TransitionSequence(1=>2, 2=>3, 3=>1)