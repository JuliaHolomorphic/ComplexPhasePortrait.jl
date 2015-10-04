# ComplexPhasePortrait

This package is an implementation of the phase portrait plotting portion of Elias Wegert's [complex function explorer](http://www.mathworks.com/matlabcentral/fileexchange/45464-complex-function-explorer).

## Installation

From the Julia command prompt:
```julia
Pkg.clone("git://github.com/ehkropf/ComplexPhasePortrait.jl.git")
```

## Example

There is so far one exported function, `portrait`, and here we will try to detail its use. First we need function data over a grid.
```julia
nx = 1000
x = linspace(-1, 1, nx)
Z = x' .+ flipdim(x, 1)*im

f(z) = (z - 0.5im).^2.*(z + 0.5+0.5im)./z
fz = f(Z)
```

First is a basic phase plot.
```julia
img = portrait(fz)
```
(Image goes here.)
