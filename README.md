# LinComs.jl
Linear combinations of parameters
## Introduction

Linear combinations of parameters for [`FixedEffectModels.jl`](https://github.com/FixedEffects/FixedEffectModels.jl) and [`EventStudyInteracts.jl`](https://github.com/FixedEffects/FixedEffectModels.jl) like Stata package `lincom`. As Stata package `lincom` help document explains:

> `lincom` computes point estimates, standard errors, t or z statistics, p-values, and confidence intervals for linear combinations of coefficients after any estimation command, including survey estimation. Results can optionally be displayed as odds ratios, hazard ratios, incidence-rate ratios, or relative-risk ratios.

`lincom` can be used to aggregating event study estimates and estimate the average effect when use the Stata package [`eventstudyinteract`](https://github.com/lsun20/EventStudyInteract) provided by [Sun and Abraham (2021)](https://www.sciencedirect.com/science/article/abs/pii/S030440762030378X).

I wrote the [`EventStudyInteracts.jl`](https://github.com/FixedEffects/FixedEffectModels.jl) package, which is a Julia replication of the Stata package [`eventstudyinteract`](https://github.com/lsun20/EventStudyInteract) provided by [Sun and Abraham (2021)](https://www.sciencedirect.com/science/article/abs/pii/S030440762030378X). However, there is currently no package in Julia similar to lincom, so I wrote this package.

This package can also be used for t-tests of linear combinations of results from FixedEffectModels.jl.

## Installation

The package is registered in the [`General`](https://github.com/JuliaRegistries/General) registry and so can be installed at the REPL with `] add LinComs`.

## Usage

After estimating the results using [`EventStudyInteracts.jl`](https://github.com/FixedEffects/FixedEffectModels.jl), you can refer to the following code to estimate the ATE.

```julia
rel_varlist1 = [:g_3,:g_2 ,:g0 ,:g1 ,:g2 ,:g3 ,:g4]

m1 = eventreg(df, formula1, rel_varlist1, control_cohort1, cohort1, vcov1)

expr = :((g0+g1+g2+g3+g4)/5)

lincom(m1,expr)
# Which will return a result like this.
                                   lincom                                   
=============================================================================
ln_wage            |  Estimate Std.Error t value Pr(>|t|) Lower 95% Upper 95%
-----------------------------------------------------------------------------
Linear Combination | 0.0561422  0.012538 4.47776    0.000 0.0315618 0.0807226
=============================================================================
```

Thanks to newbing.
