
module UIVariables

#------------------------------------------------------------------------------
# EXports
#------------------------------------------------------------------------------
export  BasicValidation,
        Variable,
        on,
        emit,
        addGridColumn!,
        insertGridColumn!,
        gridOption!,
        gridColumnOption!,
        forEachGridColumn!,
        clearGridColumns!,
        gridDefaultColDef!,
        gridDefaultColDef!



using ..Glimmer
import Tables
import JSON, JSONTables
import Dates
using OrderedCollections 
using Parameters
import UUIDs


function typedict(x::Union{AbstractUIVariable, AbstractUIValidation}) 
    res = OrderedDict()

    for fn in filter(x->!startswith(string(x), "_"), fieldnames(typeof(x)))
        key = fn
        val = getfield(x, fn) 
        if (val === nothing)
            continue
        end
        if (isstructtype(typeof(val)) && !(val isa String))    
            if (val isa Dict || val isa OrderedDict)
                # @info "DICT" key, val
                res[key] = val;
            else
                # @show key
                res[key] = typedict(val)
            end
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
    
    _events_handlers::Dict{Symbol, Vector{Function}} = Dict{Symbol, Vector{Function}}()
    _meta_data::Dict{Symbol, Any} = Dict{Symbol, Any}()
end


"""
    rawValue(var::Variable) -> string

returns the internal value of the variable. in most cases this value would be identical to using var[], but in 
some cases, such as `aggrid` type variable, this would return the internal structure of the grid definition, allowing the user 
to manually manipulate it for better control on the grid behevior.
"""
function rawValue(var::Variable)
    return var.value;
end


# function on(func::Function, var::AbstractUIVariable)
#     # var._on_change_func = func    
#     on(func, var, :valueChanged)
# end
"""
    on(func::Function, var::AbstractUIVariable, event::Symbol = :valueChanged)

Adds function `func` as listener to the variable. Whenever variables's value is set via var[] = val or one of 
the defined UI Controls, func is called with val. Most variables have just one type of events associated with them: `valueChanged`.
But some, such as 'aggrid' have additional events that you can bind listeners to.
"""
function on(func::Function, var::AbstractUIVariable, event::Symbol = :valueChanged)
    if (!haskey(var._events_handlers, event)) 
        var._events_handlers[event] = Vector{Function}()
    end
    push!(var._events_handlers[event], func)
end

"""
    on(func::Function, var::AbstractUIVariable, event::Symbol = :valueChanged)

Emits the specific event on a variable, calling all the listeners.    
"""
function emit(var::AbstractUIVariable, event::Symbol, val::Any = var.value)
    if (haskey(var._events_handlers, event)) 
        funcs = var._events_handlers[event]
        for func in funcs
            func(val)
        end
    end
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
    elseif (var.type == "aggrid")
        jtable = JSONTables.jsontable(JSON.json(var.value["rowData"]))
        return var._meta_data[:ag_grid_materializer](jtable)
    else
        return var.value
    end
end

function Base.setindex!(var::Variable, val::Any)
    # @info "setting variable $(var.name) to $(val) - app: $(var._app)"

    var.value = val;

    # special case of agGrid
    if (var.type == "aggrid")
        if !(val isa String)
            # var.value = GridUtils.table2agGrid(val)
            # var._meta_data[:ag_grid_variable] = val;
            # var._meta_data[:ag_grid_materializer] = Tables.materializer(val);
            # var._meta_data[:ag_grid_schema] = Tables.schema(val);
            if (val isa Dict || val isa OrderedDict) 
                if (haskey(val, "_metaData"))
                    var._meta_data[:ag_grid_materializer] = val["_metaData"]["ag_grid_materializer"]
                    var._meta_data[:ag_grid_schema] = val["_metaData"]["ag_grid_schema"]
                    delete!(var.value, "_metaData")
                end
            end
        end
    end

    Glimmer.updateVariable!(var._app, var)
end

function Base.setindex!(var::Variable, val::Any, type::String)
    if (var.type == "aggrid")
        if (type == "options")
            var.value["options"] = val;
        elseif (type == "readonly")
            for colDef in var.value["columnDefs"]
                colDef["editable"] = !val
            end
        else
            @warn "unrecognized property of aggrid [$type]"
        end
        return;
    end

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

#---------------------------------------------------------
# Tables and AG-Grid Utility Functions
#---------------------------------------------------------

"""
    clearGridColumns!(var::Variable)

Clear all existing definitions of columns for this `var` grid.    
"""
function clearGridColumns!(var::Variable)
    rawValue(var)["columnDefs"] = []
end

"""
    addGridColumn!(var::Variable, colDef::Dict)

Add a new grid column definition as the last column.
"""
function addGridColumn!(var::Variable, colDef::Dict)
    push!(rawValue(var)["columnDefs"], colDef)
end

"""
    addGridColumn!(var::Variable, colDef::Dict)

Add a new grid column definition as the last column.
"""
function insertGridColumn!(var::Variable, index::Int64, colDef::Dict)
    insert!(rawValue(var)["columnDefs"], index, colDef)
end

"""
    gridDefaultColDef!(var::Variable, colDef::Dict)

Set the default column definition for this grid variable.
"""
function gridDefaultColDef!(var::Variable, colDef::Dict)
    rawValue(var)["defaultColDef"] = colDef
end

"""
    gridOption!(var::Variable, option::String, value)

Set a grid options.
"""
function gridOption!(var::Variable, option::String, value)
    if (!haskey(rawValue(var), "options"))
        rawValue(var)["options"] = Dict();
    end
    rawValue(var)["options"][option] = value;
end

"""
    gridColumnOption!(var::Variable, colName::String, option::String, value)

Set a grid column's option.
"""
function gridColumnOption!(var::Variable, colName::String, option::String, value)
    found = false;    
    for col in rawValue(var)["columnDefs"]
        if (haskey(col, "field") && col["field"] == colName)
            col[option] = value;
            found = true;
        end
    end
    if (!found)
        @warn "Can't find grid column with name [$colName]"
    end
end


"""
    forEachGridColumn!(var::Variable, option::String, value)

Set a column options for each exiting column definition in this grid variable.
"""
function forEachGridColumn!(var::Variable, option::String, value)
    for col in rawValue(var)["columnDefs"]
        col[option] = value
    end
end


end # module Variables
