# LinComs.jl

Linear combinations of coefficients for Julia regression models, with `FixedEffectModels.jl` and `EventStudyInteracts.jl` as the main use cases.

## Status

The current package line is prepared for:

- `Julia 1.10+`
- `FixedEffectModels.jl 1.13`
- `EventStudyInteracts.jl 0.2`
- `Vcov.jl 0.8`

## Installation

`LinComs.jl` is registered in the [`General`](https://github.com/JuliaRegistries/General) registry.

```julia
using Pkg
Pkg.add("LinComs")
```

## What It Does

`lincom(...)` computes a linear combination of estimated coefficients and returns a lightweight result object with:

- the combined estimate
- the implied variance-covariance matrix
- t statistics, p values, and confidence intervals through `coeftable(...)` and `confint(...)`

The implementation works with regression results that expose the standard `StatsAPI` accessors used here: `coef`, `coefnames`, `vcov`, `dof_residual`, and `responsename`.

## FixedEffectModels Example

```julia
using DataFrames
using FixedEffectModels
using LinComs
using Vcov


df = DataFrame(
    y = [1.0, 2.2, 3.1, 4.5, 5.2, 6.8, 7.1, 8.9],
    x1 = [0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0],
    x2 = [1.0, 1.5, 1.8, 2.2, 2.9, 3.1, 3.8, 4.0],
)

m = reg(df, @formula(y ~ x1 + x2), Vcov.simple())
lincom(m, :(x1 + 2 * x2))
```

## EventStudyInteracts Example

```julia
using EventStudyInteracts
using LinComs

m = eventreg(df, formula1, rel_varlist1, control_cohort1, cohort1, vcov1)
lincom(m, :((g0 + g1 + g2 + g3 + g4) / 5))
```

A typical use case is aggregating post-treatment event-study coefficients into an average treatment effect.

## Development

This repository includes:

- CI on `main`
- `CompatHelper`
- `TagBot`
- a minimal regression test suite under [`test/runtests.jl`](test/runtests.jl)

For releases, bump `Project.toml`, run the tests, register with `Registrator`, and let `TagBot` create the Git tag and GitHub release.
