export TransitionSequence, TransitionDictSequence, possible_states, PatternSequence

"""
A `TransitionSequence` starts in a random state, and then returns states according to the transitions till it runs out of states.
The how long such a sequence is, cannot be known beforehand (might be infinite for infinite cycles of transitions).
"""
abstract type TransitionSequence end

"""
    TransitionDictSequence(dict::Dict)

An instance of TransitionSequence, where the transitions are expressed as dictionary/pairing of states.

```jldoctest; setup = :(using TDLM.Simulate, StableRNGs)
julia> S = TransitionDictSequence(1 => 2, 2 => 3; rng = StableRNG(42));

julia> collect(S)
2-element Vector{Int64}:
 2
 3
```
"""
struct TransitionDictSequence{T <: Dict} <: TransitionSequence
    dict::T
    rng
    TransitionDictSequence(dict::T; rng = Random.GLOBAL_RNG) where T = new{T}(dict, rng)
end
TransitionDictSequence(args::Pair...; kwargs...) = TransitionDictSequence(Dict(args...); kwargs...)
function Base.iterate(S::TransitionDictSequence, state = rand(S.rng, keys(S.dict)))
    haskey(S.dict, state) ? (S.dict[state], S.dict[state])  : nothing
end
Base.eltype(::Type{TransitionDictSequence{T}}) where T = eltype(eltype(T))
Base.IteratorSize(::Type{TransitionDictSequence{T}}) where T = Base.SizeUnknown()
"""
    possible_states(transition::TransitionSequence)

Returns the possible states a TransitionSequence may have.

```jldoctest; setup = :(using TDLM.Simulate)
julia> S = TransitionDictSequence(1 => 2, 2 => 3);

julia> possible_states(S) == Set(1:3)
true
```
"""
possible_states(transition::TransitionDictSequence) = union(keys(transition.dict), values(transition.dict))

"""
    PatternSequence(transition, patterns)

Instead of returning a state, a pattern sequence goes through the state transistions and returns the corresponding patttern.

```jldoctest; setup = :(using TDLM.Simulate, StableRNGs)
julia> S = PatternSequence(TransitionDictSequence(1 => 2, 2 => 1; rng = StableRNG(42)), ["a", "b"]);

julia> collect(Iterators.take(S, 5))
5-element Vector{String}:
 "b"
 "a"
 "b"
 "a"
 "b"
```
"""
struct PatternSequence{T1, T2}
    transition::T1
    pattern::T2
    axis::Int
    function PatternSequence(transition::T1, pattern::T2; axis = 1) where {T1 <: TransitionSequence, T2}
        if !issubset(possible_states(transition), axes(pattern, axis))
            throw(ArgumentError("States and pattern don't match."))
        else
            new{T1, T2}(transition, pattern)
        end
    end
end
function Base.iterate(S::PatternSequence)
    (state, _) = iterate(S.transition)
    isnothing(state) ? nothing : (S.pattern[state], state)
end
function Base.iterate(S::PatternSequence, state)
    (new_state, _) = iterate(S.transition, state)
    isnothing(state) ? nothing : (S.pattern[new_state], new_state)
end
Base.eltype(::Type{PatternSequence{T1, T2}}) where {T1, T2} = eltype(T2)
Base.IteratorSize(::Type{PatternSequence{T1, T2}}) where {T1, T2} = Base.IteratorSize(T1)
