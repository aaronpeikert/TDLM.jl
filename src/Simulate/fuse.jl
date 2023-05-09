export hfuse

"""
    hfuse(is..., fuse = +)

`hfuse` is taking two or more iterators and fuses their outcomes together at each iteration using [reduce](@ref).
As soon as one of the iterators is exhousted `hfuse` terminates.
Also note that eltype is depending on both the iterators and the function.
It might be nessesary to define `eltype(::Type{HorizentalFuse{T1,T2}}) where {T1,T2 <: typeof(myfun)}`

```jldoctest; setup = :(using TDLM.Simulate)
julia> i = hfuse(0:3, 5:8)
hfuse(zip(0:3, 5:8); fuse = +)

julia> collect(i)
4-element Vector{Int64}:
  5
  7
  9
 11

```

"""
hfuse(is...; fuse = +) = HorizentalFuse(is, fuse)
struct HorizentalFuse{T1 <: Tuple, T2 <: Function}
    is::Iterators.Zip{T1}
    fuse::T2
    HorizentalFuse(is::Iterators.Zip{T1}, fuse::T2) where {T1, T2} = new{T1,T2}(is, fuse)
end
HorizentalFuse(is::Tuple, fuse::Function) = HorizentalFuse(zip(is...), fuse)

function Base.iterate(i::HorizentalFuse)
    bundle = iterate(i.is)
    bundle === nothing && return nothing
    reduce(i.fuse, bundle[1]), bundle[2]
end

function Base.iterate(i::HorizentalFuse, state)
    bundle = iterate(i.is, state)
    bundle === nothing && return nothing
    reduce(i.fuse, bundle[1]), bundle[2]
end

Base.IteratorSize(::Type{HorizentalFuse{T1,T2}}) where {T1,T2} = Iterators.SizeUnknown()
function Base.eltype(::Type{HorizentalFuse{T1,T2}}) where {T1,T2 <: Union{typeof(+),typeof(-),typeof(*),typeof(/)}}
    Base.promote_type(map(eltype, fieldtypes(T1))...)
end
function Base.show(io::IO, x::HorizentalFuse)
    println(io, "hfuse($(x.is); fuse = $(x.fuse))")
end