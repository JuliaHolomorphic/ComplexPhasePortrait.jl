using ComplexPhasePortrait, Colors
using Test

nx = 1000
x = range(-1, stop=1, length=nx)
Z = x' .+ reverse(x)*im

f = z -> (z - 0.5im)^2 * (z + 0.5+0.5im)/z
fz = f.(Z)

img = portrait(fz)
@test img[1,5] ≈ RGB{Float64}(0.11686143572621054,1.0,0.0)

img = portrait(fz, ctype="nist")
@test img[1,5] ≈ RGB{Float64}(0.4916573971078975,1.0,0.0)

img = portrait(fz, PTstepphase)
@test img[1,5] ≈ RGB{Float64}(0.09621043816546014,0.8232864637301505,0.0)

img = portrait(fz, PTstepmod)
@test img[1,5] ≈ RGB{Float64}(0.10275080341985139,0.8792533035498697,0.0)

img = portrait(fz, PTcgrid)
@test img[1,5] ≈ RGB{Float64}(0.08803468544171197,0.7533253797083627,0.0)
