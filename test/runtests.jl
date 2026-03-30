using ComplexPhasePortrait, Colors, ColorSchemes, Images
using Test

using Plots
using CairoMakie

@testset "ComplexPhasePortrait" begin
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

    @testset "Plot recipees" begin
        @testset "Plots.jl" begin
            for ctype in ["standard", "nist"]
                phaseplot(-1..1, -1..1, f, PTcgrid, ctype=ctype; dpi=300)
            end
        end

        @testset "Makie.jl" begin
            for ctype in ["standard", "nist"]
                phase(-1..1, -1..1, f, portrait_type=PTcgrid, ctype=ctype)
            end
        end
    end

    @testset "Custom Colormap Tests" begin
        # Define a custom colormap
        custom_colormap = [RGB(1.0, 0.0, 0.0), RGB(0.0, 1.0, 0.0), RGB(0.0, 0.0, 1.0)]

        # Generate a phase portrait with the custom colormap
        img = portrait(fz, colormap=custom_colormap)

        # Verify that the image uses the custom colormap
        @test img[1,1] in custom_colormap
        @test img[end,end] in custom_colormap
    end

    @testset "Viridis Colormap Test" begin
        using ColorSchemes

        # Use the viridis colormap
        viridis_colormap = [RGB(c.r, c.g, c.b) for c in ColorSchemes.viridis.colors]

        # Generate a phase portrait with the viridis colormap
        img = portrait(fz, colormap=viridis_colormap)

        # Verify that the image uses colors from the viridis colormap
        @test img[1,1] in viridis_colormap
        @test img[end,end] in viridis_colormap
    end

    @testset "Gradient Colormap Test" begin
        using Colors

        # Define a gradient colormap
        gradient_colormap = [RGB(Colors.lerp(0.0, 1.0, t), Colors.lerp(0.0, 0.5, t), Colors.lerp(1.0, 0.0, t)) for t in range(0, stop=1, length=256)]

        # Generate a phase portrait with the gradient colormap
        img = portrait(fz, colormap=gradient_colormap)

        # Verify that the image uses colors from the gradient colormap
        @test img[1,1] in gradient_colormap
        @test img[end,end] in gradient_colormap
    end
end
