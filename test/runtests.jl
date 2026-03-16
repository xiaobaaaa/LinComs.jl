using DataFrames
using FixedEffectModels
using LinComs
using StatsAPI
using StatsBase
using StatsModels
using Test
using Vcov

struct DummyModel <: RegressionModel
    coefficients::Vector{Float64}
    covariance::Matrix{Float64}
    names::Vector{String}
    dof_resid::Int
    response::String
end

StatsAPI.coef(m::DummyModel) = m.coefficients
StatsAPI.vcov(m::DummyModel) = m.covariance
StatsAPI.coefnames(m::DummyModel) = m.names
StatsAPI.dof_residual(m::DummyModel) = m.dof_resid
StatsAPI.responsename(m::DummyModel) = m.response

@testset "LinComs" begin
    @testset "Generic RegressionModel" begin
        covariance = [0.09 0.01 0.00; 0.01 0.16 0.02; 0.00 0.02 0.25]
        model = DummyModel([1.0, 2.0, 4.0], covariance, ["g0", "g1", "g2"], 12, "y")
        result = lincom(model, :((g0 + g1 + g2) / 3))

        weights = [1 / 3, 1 / 3, 1 / 3]
        expected_coef = sum(weights .* coef(model))
        expected_vcov = [weights' * vcov(model) * weights]

        @test result isa LinCom
        @test coef(result)[1] ≈ expected_coef atol = 1.0e-12
        @test vcov(result) ≈ expected_vcov atol = 1.0e-12
        @test coefnames(result) == ["Linear Combination"]
        @test responsename(result) == "y"
        @test dof_residual(result) == 12
        @test size(confint(result)) == (1, 2)
        @test occursin("Linear Combination", sprint(show, result))
    end

    @testset "FixedEffectModels integration" begin
        df = DataFrame(
            y = [1.0, 2.2, 3.1, 4.5, 5.2, 6.8, 7.1, 8.9],
            x1 = [0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0],
            x2 = [1.0, 1.5, 1.8, 2.2, 2.9, 3.1, 3.8, 4.0],
        )

        model = reg(df, @formula(y ~ x1 + x2), Vcov.simple())
        result = lincom(model, :(x1 + 2 * x2))

        names = String.(coefnames(model))
        idx_x1 = findfirst(==("x1"), names)
        idx_x2 = findfirst(==("x2"), names)
        @test idx_x1 !== nothing
        @test idx_x2 !== nothing

        weights = zeros(length(names))
        weights[idx_x1] = 1.0
        weights[idx_x2] = 2.0

        expected_coef = sum(weights .* coef(model))
        expected_vcov = [weights' * Matrix(vcov(model)) * weights]

        @test coef(result)[1] ≈ expected_coef atol = 1.0e-10
        @test vcov(result) ≈ expected_vcov atol = 1.0e-10
        @test responsename(result) == responsename(model)
        @test occursin("Linear Combination", sprint(show, result))
    end
end
