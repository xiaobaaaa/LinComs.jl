
##############################################################################
##
## Type LinCom
##
##############################################################################

struct LinCom <: RegressionModel
    coef::Vector{Float64}   # Vector of coefficients
    vcov::Matrix{Float64}   # Covariance matrix
    dof_residual::Int64        # dof used for t-test and F-stat. nobs - degrees of freedoms with simple std
    
    coefnames::Vector       # Name of coefficients
    responsename::Union{String, Symbol} # Name of dependent variable
end

StatsAPI.coef(m::LinCom) = m.coef
StatsAPI.coefnames(m::LinCom) = m.coefnames
StatsAPI.responsename(m::LinCom) = m.responsename
StatsAPI.vcov(m::LinCom) = m.vcov
StatsAPI.dof_residual(m::LinCom) = m.dof_residual

function StatsAPI.confint(m::LinCom; level::Real = 0.95)
    scale = tdistinvcdf(StatsAPI.dof_residual(m), 1 - (1 - level) / 2)
    se = stderror(m)
    hcat(m.coef -  scale * se, m.coef + scale * se)
end

function StatsAPI.coeftable(m::LinCom; level = 0.95)
    cc = coef(m)
    se = stderror(m)
    coefnms = coefnames(m)
    conf_int = confint(m; level = level)
    tt = cc ./ se
    CoefTable(
        hcat(cc, se, tt, fdistccdf.(Ref(1), Ref(StatsAPI.dof_residual(m)), abs2.(tt)), conf_int[:, 1:2]),
        ["Estimate","Std.Error","t value", "Pr(>|t|)", "Lower 95%", "Upper 95%" ],
        ["$(coefnms[i])" for i = 1:length(cc)], 4)
end


##############################################################################
##
## Display Result
##
##############################################################################

function title(m::LinCom)
    return "lincom"
end

format_scientific(x) = @sprintf("%.3f", x)


function Base.show(io::IO, m::LinCom)
    ctitle = title(m)
    cc = coef(m)
    se = stderror(m)
    yname = responsename(m)
    coefnms = coefnames(m)
    conf_int = confint(m)

    tt = cc ./ se
    mat = hcat(cc, se, tt, fdistccdf.(Ref(1), Ref(StatsAPI.dof_residual(m)), abs2.(tt)), conf_int[:, 1:2])
    nr, nc = size(mat)
    colnms = ["Estimate","Std.Error","t value", "Pr(>|t|)", "Lower 95%", "Upper 95%"]
    rownms = ["$(coefnms[i])" for i = 1:length(cc)]
    pvc = 4
    # print
    if length(rownms) == 0
        rownms = AbstractString[lpad("[$i]",floor(Integer, log10(nr))+3) for i in 1:nr]
    end
    if length(rownms) > 0
        rnwidth = max(4, maximum(length(nm) for nm in rownms) + 2, length(yname) + 2)
        else
            # if only intercept, rownms is empty collection, so previous would return error
        rnwidth = 4
    end
    rownms = [rpad(nm,rnwidth-1) * "|" for nm in rownms]
    widths = [length(cn)::Int for cn in colnms]
    str = [sprint(show, mat[i,j]; context=:compact => true) for i in 1:nr, j in 1:nc]
    if pvc != 0                         # format the p-values column
        for i in 1:nr
            str[i, pvc] = format_scientific(mat[i, pvc])
        end
    end
    for j in 1:nc
        for i in 1:nr
            lij = length(str[i, j])
            if lij > widths[j]
                widths[j] = lij
            end
        end
    end
    widths .+= 1
    totalwidth = sum(widths) + rnwidth
    if length(ctitle) > 0
        halfwidth = div(totalwidth - length(ctitle), 2)
        println(io, " " ^ halfwidth * string(ctitle) * " " ^ halfwidth)
    end
   
    println(io,"=" ^totalwidth)
    println(io, rpad(string(yname), rnwidth-1) * "|" *
            join([lpad(string(colnms[i]), widths[i]) for i = 1:nc], ""))
    println(io,"-" ^totalwidth)
    for i in 1:nr
        print(io, rownms[i])
        for j in 1:nc
            print(io, lpad(str[i,j],widths[j]))
        end
        println(io)
    end
    println(io,"=" ^totalwidth)
end