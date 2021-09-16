
module UIVariables

#------------------------------------------------------------------------------
# EXports
#------------------------------------------------------------------------------
export  BasicValidation,
        Variable,
        on


using ..Glimmer
using Parameters
import UUIDs


function typedict(x::Union{AbstractUIVariable, AbstractUIValidation}) 
    res = Dict()

    for fn in filter(x->!startswith(string(x), "_"), fieldnames(typeof(x)))
        key = fn
        val = getfield(x, fn) 
        if (val === nothing)
            continue
        end
        if (isstructtype(typeof(val)) && !(val isa String))    
            @show key
            res[key] = typedict(val)
        else
            res[key] = val;
        end
    end
    # if (isstructtype(typeof(x)))
    # Dict(fn=>getfield(x, fn) for fn ∈ filter(x->!startswith(string(x), "_"), fieldnames(typeof(x))))

    return res;
end


# ----------------------------------------------------------------------
# Validation
# ----------------------------------------------------------------------
@with_kw mutable struct BasicValidation <: AbstractUIValidation 
    type::String = "any"
    min::Union{Nothing, Float64} = nothing
    max::Union{Nothing, Float64} = nothing
    valid_values::Union{Nothing, Vector{Any}} = nothing
    invalid_values::Union{Nothing, Vector{Any}} = nothing
end

function BasicValidation(min::Any, max::Any)
    # _, min, max = promote(0.0, min, max)    
    return BasicValidation(type="number", min=min, max=max)
end


# ----------------------------------------------------------------------
# Variables
# ----------------------------------------------------------------------
@with_kw mutable struct Variable <: AbstractUIVariable 
    name::String = "defaultVariableName"
    type::String = "any"
    value::Union{Nothing, Any} = nothing;
    validation::Union{Nothing, BasicValidation} = nothing

    _app::Union{Nothing, AbstractUIApp} = nothing
    _on_change_func::Union{Nothing, Function} = nothing
end

function on(func::Function, var::AbstractUIVariable)
    var._on_change_func = func    
end

function Base.getindex(var::Variable) 
    if (var.type == "integer" || var.type == "int")
        if (isa(var.value, String))
            return Int(floor(parse(Float64, var.value)))
        elseif (isa(var.value, Int64))
            return var.value
        elseif (isa(var.value, Float64))
            return Int(floor(var.value))
        else
            return var.value
        end
    elseif (var.type == "float64")
        if (isa(var.value, String))
            return parse(Float64, var.value)
        elseif (isa(var.value, Int))
            return convert(Float64, var.value)
        elseif (isa(var.value, Float64))
            return var.value
        else
            return var.value
        end
    else
        return var.value
    end
end

function Base.setindex!(var::Variable, val::Any)
    # @info "setting variable $(var.name) to $(val) - app: $(var._app)"
    var.value = val;
    Glimmer.updateVariable!(var._app, var)
end

function Base.setindex!(var::Variable, val::Any, type::String)
    if (type == "png")
        try
            val = Glimmer.base64png(val)
        catch e
            @error "Can't convert to SVG [$e]"
        end
    elseif (type == "svg")
        try
            val = Glimmer.base64svg(val)
        catch e
            @error "Can't convert to SVG [$e]"
        end
    end
    var.value = val;
    Glimmer.updateVariable!(var._app, var)
end

end # module Variables
