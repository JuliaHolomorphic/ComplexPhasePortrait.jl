module ComplexPhasePortrait
using Reactive, IntervalSets, RecipesBase
import AbstractPlotting
import Images
import Colors
import Colors: RGB, HSL
import AbstractPlotting: plot!, Scene, AbstractScene, ScenePlot
export portrait,
       PTproper, PTcgrid, PTstepphase, PTstepmod, phaseplot

export (..)

abstract type PortraitType <: Any end
struct PTproper <: PortraitType end
struct PTcgrid <: PortraitType end
struct PTstepmod <: PortraitType end
struct PTstepphase <: PortraitType end

const brighten = 0.1

"""
portrait builds a phase portrait over a give complex grid.

The PortraitType determines what type of portrait is generated:

* PTproper - a proper phase portrait
* PTcgrid - a conformal grid
* PTstepphase - a stepped phase plot
* PTstepmod - a stepped modulus plot

Named arguments:

* ctype - is the colormap type. The default "standard" is a basic HSL map
  with H∈[0,360], S = 1.0, and L = 0.5. Setting `ctype="nist"` gives the
  [NIST color scheme](http://dlmf.nist.gov/help/vrml/aboutcolor).
* pres - is the phase step resolution (number of phase jumps), default
  `pres=20`.
"""

function portrait(fval::Array{Complex{Float64},2}; kwargs...)
    portrait(fval, PTproper; kwargs...)
end

function portrait(fval::Array{Complex{Float64},2}, ::Type{PTproper};
                  kwargs...)
    args = baseArgs(fval; kwargs...)
    phaseToImage!(args[1:3]...)
    return args[1]
end

function portrait(fval::Array{Complex{Float64},2}, ::Type{PTcgrid};
                  pres=20, kwargs...)
    (img, nphase, cm, farg) = baseArgs(fval; kwargs...)
    lowb = sqrt(0.75^2*(1.0 - brighten) + brighten)
    black = (sawfun(farg, 1/pres, lowb, 1.0)
             .*sawfun.(log.(abs.(fval)), 2pi/pres, lowb, 1.0))
    phaseToImage!(img, nphase, black, cm)
    return img
end

function portrait(fval::Array{Complex{Float64},2}, ::Type{PTstepmod};
                  pres=20, kwargs...)
    (img, nphase, cm) = baseArgs(fval; kwargs...)
    phaseToImage!(img, nphase, sawfun(log.(abs.(fval)), 2pi/pres, 0.75, 1.0), cm)
    return img
end

function portrait(fval::Array{Complex{Float64},2}, ::Type{PTstepphase};
                  pres=20, kwargs...)
    (img, nphase, cm, farg) = baseArgs(fval; kwargs...)
    phaseToImage!(img, nphase, sawfun(farg, 1/pres, 0.75, 1.0), cm)
    return img
end

function baseArgs(fval::Array{Complex{Float64},2}; kwargs...)
    (farg, nphase, cm) = setupPhase(fval; kwargs...)
    (m, n) = size(nphase)
    img = Array{RGB{Float64}}(undef, m, n)
    return img, nphase, cm, farg
end

function setupPhase(fval; kwargs...)
    cm = baseColorMap(;kwargs...)
    nc = length(cm)
    farg = (angle.(-fval) .+ pi)./2pi
    nphase = stepfun(farg, nc)

    return (farg, nphase, cm)
end

"Color map for complex phase portrait with 600 elements."
function baseColorMap(;ctype="standard")
    if ctype == "nist"
        nc = 900
        cm = range(HSL(0.0, 1.0, 0.5), stop=HSL(360.0, 1.0, 0.5), length=nc)
        idx = [1:Int(nc/6); Int(nc/6)+1:2:Int(nc/2); Int(nc/2)+1:2*Int(nc/3);
              2*Int(nc/3)+1:2:nc]
        cm = cm[idx]
    else
        cm = range(HSL(0.0, 1.0, 0.5), stop=HSL(360.0, 1.0, 0.5), length=600)
    end
    cm = convert(Array{RGB{Float64}}, cm)
end

"Integer step function with period 1 such that [0,1]⟶[1,nmax]."
function stepfun(x, nmax)
    y = x .- floor.(x)
    y = convert(Array{UInt16}, floor.(nmax*y) .+ 1)
end

"Sawtooth function over reals with period dx onto [a,b]."
function sawfun(x, dx, a, b)
    x = x/dx
    x = x .- floor.(x)
    x = a .+ (b - a)*x
end

function phaseToImage!(img, pidx, cm)
    n = size(pidx, 1)
    for j in 1:size(pidx, 2), i in 1:n
        img[n-i+1,j] = cm[pidx[i,j]]
    end
    nothing
end

function phaseToImage!(img, pidx, black, cm)
    n = size(pidx, 1)
    for j in 1:size(pidx, 2), i in 1:n
        img[n-i+1,j] = cm[pidx[i,j]]*black[i,j]
    end
    nothing
end

function _range(d::ClosedInterval)
    a,b = endpoints(d)
    range(a; stop=b, length=500)
end

_range(d::AbstractVector) = d

portrait(x::AbstractVector, y::AbstractVector, f::Function) =
    portrait(convert(AbstractMatrix{ComplexF64}, f.(x' .+ im .*y)))

portrait(x::ClosedInterval, y::ClosedInterval, f::Function) =
    portrait(_range(x), _range(y), f)

## Recipe for Plots

@userplot PhasePlot



@recipe function f(c::PhasePlot)
    xin, yin, ff = c.args
    xx, yy = _range(xin),  _range(yin)
    Z = ff.(xx' .+ im.*yy)
    yflip := false
    @series xx, yy, portrait(Matrix{ComplexF64}(Z[end:-1:1,:]))
end

## Recipe for Makie

@AbstractPlotting.recipe(Phase) do scene
    default_theme(scene)
end



function plot!(plot::Phase{Tuple{X,Y,F}}) where {X<:AbstractVector,Y<:AbstractVector,F<:AbstractMatrix}
    x, y, f = value.(plot[1:3])::Tuple{X,Y,F}
    image!(plot, x, y, portrait(convert(AbstractMatrix{ComplexF64}, f)))
end

# avoid compile time issues
function phase(x::AbstractVector, y::AbstractVector, f::Function; kwds...)
    z = x' .+ im.*y
    a_x,b_x = first(x),last(x)
    a_y,b_y = first(y),last(y)
    r = (b_y-a_y)/(b_x-a_x)
    N = 400
    s = Scene(resolution=(max(N,floor(Int,N/r)), max(N,floor(Int, r *N))))
    phase!(s, x, y, f.(z); limits = FRect(a_x,a_y,b_x-a_x,b_y-a_y), kwds...)
end
function phase!(plot::Union{AbstractScene,ScenePlot}, x::AbstractVector, y::AbstractVector, f::Function; kwds...)
    z = x' .+ im.*y
    phase!(plot, x, y, f.(z); kwds...)
end


phase(x::ClosedInterval, y::ClosedInterval, f::Function; kwds...) =
    phase(_range(x), _range(y), f; kwds...)

phase!(plot::Union{AbstractScene,AbstractPlotting.ScenePlot}, x::ClosedInterval, y::ClosedInterval, f::Function; kwds...) =
    phase!(plot, _range(x), _range(y), r; kwds...)

end # module
