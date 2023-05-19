
module LinComs

# slows down tss
#if isdefined(Base, :Experimental) && isdefined(Base.Experimental, Symbol("@optlevel"))
#	@eval Base.Experimental.@optlevel 1
#end

using FixedEffectModels
using EventStudyInteracts
using LinearAlgebra
using Printf
using Reexport
using Statistics
using StatsAPI
using StatsBase
using StatsFuns
@reexport using StatsModels
using Tables
using Vcov

include("LinComfit.jl")
include("LinComfuncs.jl")
include("LinComstruct.jl")
# Export from StatsBase
export coef, coefnames, coeftable, responsename, vcov, stderror, dof_residual, confint, fit


export lincom,
LinCom
end 
