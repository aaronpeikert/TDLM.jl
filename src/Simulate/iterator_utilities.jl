export chain
"""
    chain(iterators...)

Chain simply connects iterators but instead of collecting them, it returns again an iterator.

```jldoctest; setup = :(using TDLM.Simulate, StableRNGs)
julia> S = chain(1:2, 100:102);

julia> collect(S)
5-element Vector{Int64}:
   1
   2
 100
 101
 102
```
"""
chain(is::Tuple) = Iterators.flatten(is)
chain(is...) = chain(is)
