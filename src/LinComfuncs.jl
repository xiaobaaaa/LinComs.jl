# Extract vars from expr.

function extract_vars(expr::Expr)
    vars = Set{Symbol}()
    for arg in expr.args
        if typeof(arg) == Symbol && occursin(r"^\w+$", string(arg))
            push!(vars, arg)
        elseif typeof(arg) == Expr
            union!(vars, extract_vars(arg))
        end
    end
    return collect(vars)
end

#Define the eval_matrix() function. Given m, substitute it into expr row by row to solve for the value, in preparation for solving for weight.
function eval_matrix(m, expr)
    vars = extract_vars(expr)
    result = Vector{Float64}()
    for row in eachrow(m)
        assignment = :()
        for i in eachindex(vars)
            assignment = :($assignment; $(vars[i]) = $(row[i]))
        end
        eval(assignment)
        push!(result, eval(expr))
    end
    return result
end

# Generate an integer matrix based on the length of vars that satisfies the condition that the system of equations has a unique solution, in preparation for solving for weight.
function create_matrix(expr::Expr)
    vars = extract_vars(expr)
    n = length(vars)
    m = zeros(Int, n, n)
    Y = zeros(n)
    while rank(m) != rank([m Y]) || rank(m) != n
        m = rand(-9:9, n, n)
        Y = eval_matrix(m, expr)
    end
    B = m \ Y
    return Dict(zip(vars, B))
end

# Solving weight.
function sort_weight(regresult, expr)
    weight_m = create_matrix(expr)
    new_weight = Dict()
    for name in coefnames(regresult)
        if Symbol(name) in keys(weight_m)
            new_weight[Symbol(name)] = weight_m[Symbol(name)]
        else
            new_weight[Symbol(name)] = 0.0
        end
    end
    sorted_weight = [(name, new_weight[Symbol(name)]) for name in coefnames(regresult)]
    return sorted_weight
end



