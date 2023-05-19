# lincom().
function lincom(@nospecialize(regresult::RegressionModel),     
    @nospecialize(expr::Expr))
    StatsAPI.fit(RegressionModel, expr, regresult)
end
  
function StatsAPI.fit(::Type{RegressionModel},     
    @nospecialize(expr::Expr),
    @nospecialize(regresult::RegressionModel))

    sorted_weight = sort_weight(regresult, expr)

    k = size(vcov(regresult), 1)
    weights = zeros(1, k)
    for (i, coef) in enumerate(map(x -> x[2], sorted_weight))
        weights[1, i] = coef
    end

    b = coef(regresult)
    coef_lincom = [sum(weights .* b')]
    vcov_regresult = vcov(regresult)
    replace!(vcov_regresult, NaN => 0)
    vcov_lincom = weights * vcov_regresult * weights'
    coef_names = ["Linear Combination"]
    response_name = responsename(regresult)
    dof_residual = regresult.dof_residual
    return LinCom(coef_lincom, vcov_lincom, dof_residual, coef_names, response_name)
end
