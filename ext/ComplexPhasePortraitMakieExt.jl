module ComplexPhasePortraitMakieExt
using IntervalSets

import Makie
import Makie: plot!, image!, FRect

using ComplexPhasePortrait
import ComplexPhasePortrait: phase, phase!, _range

Makie.@recipe(Phase) do scene
    Makie.Theme(
        portrait_type = PTproper,
        ctype = "standard"
    )
end

function plot!(plot::Phase{Tuple{X,Y,F}}) where {X<:AbstractVector,Y<:AbstractVector,F<:AbstractMatrix}
    x,y,f = plot[1:3]
    c = portrait(convert(AbstractMatrix{ComplexF64}, f[]),
                 plot.portrait_type[], ctype=plot.ctype[])

    a_x,b_x = first(x[]),last(x[])
    a_y,b_y = first(y[]),last(y[])

    image!(plot, a_x .. b_x, a_y .. b_y, c, limits = FRect(a_x,a_y,b_x-a_x,b_y-a_y))
end

function plot!(plot::Phase{Tuple{X,Y,F}}) where {X<:Any,Y<:Any,F<:Function}
    x,y,f = plot[1:3]

    xv = _range(x[])
    yv = _range(y[])

    Z = xv .+ im*yv'
    v = f[].(Z)[end:-1:1,:] # Why do we need to flip it?

    phase!(plot, xv, yv, v,
           portrait_type=plot.portrait_type,
           ctype=plot.ctype)

    plot
end
end
