# ComplexPhasePortrait.jl

[![Build Status](https://travis-ci.org/JuliaHolomorphic/ComplexPhasePortrait.jl.svg?branch=master)](https://travis-ci.org/JuliaHolomorphic/ComplexPhasePortrait.jl)

This package is a [Julia](http://julialang.org) implementation of the phase portrait ideas presented in Elias Wegert's book "[Visual Complex Functions](http://www.visual.wegert.com)".

## Installation

From the Julia command prompt:
```julia
Pkg.clone("git://github.com/JuliaHolomorphic/ComplexPhasePortrait.jl.git")
```

## Examples

There is so far one exported function, `portrait`, and here I will try to detail its use. First we need function data over a grid.
```julia
using ComplexPhasePortrait

nx = 1000
x = range(-1, stop=1, length=nx)
Z = x' .+ reverse(x)*im

f = z -> (z - 0.5im)^2 * (z + 0.5+0.5im)/z
fz = f.(Z)
```

Now a basic phase plot.
```julia
img = portrait(fz)
```
![proper phase plot](doc/figures/proper.png)

Now for a basic plot using [NIST coloring](http://dlmf.nist.gov/help/vrml/aboutcolor).
```julia
img = portrait(fz, ctype="nist")
```
![nist coloring](doc/figures/nist.png)

Lines of constant phase are given by
```julia
img = portrait(fz, PTstepphase)
```
![constant phase](doc/figures/stepphase.png)

Lines of constant modulus are given by
```julia
img = portrait(fz, PTstepmod)
```
![constant modulus](doc/figures/stepmod.png)

Finally, a conformal grid is given by
```julia
img = portrait(fz, PTcgrid)
```
![conformal grid](doc/figures/cgrid.png)
