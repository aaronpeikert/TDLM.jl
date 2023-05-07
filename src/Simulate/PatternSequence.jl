export PatternSequence

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
