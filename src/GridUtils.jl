
#---------------------------------------------------------
# Tables and AG-Grid Utility Functions
#---------------------------------------------------------

module GridUtils

import ..Glimmer
import Tables
using OrderedCollections
import Dates
import Markdown
import REPL
import JSON, JSONTables


export  gridCell,
        gridButtonCell,
        gridTreeViewCell,
        gridRowIndexCell,
        gridSelectCell



function _gridCommonCell(;kwargs...)
    res = Dict()

    for a in kwargs
        key = string(a[1])
        if (key == "header")
            key = "headerName"
        elseif (key == "eventName")
            key = "juliaEventName"
        end
        res[key] = a[2]
    end

    return res;
end
        


function gridCell(;
    kwargs...
)
    res = _gridCommonCell(;kwargs...)
    return res
end


function gridRowIndexCell(; 
    kwargs...
)
    res = _gridCommonCell(;kwargs...)

    res["valueGetter"] = "node.rowIndex + 1"

    res["editable"] = false;
    res["sortable"] = false;
    res["floatingFilter"] = false;
    res["filter"] = false

    return res
end


function gridButtonCell(; 
    kwargs...
)
    res = _gridCommonCell(;kwargs...)

    res["cellRenderer"] = "buttonCellRenderer"

    res["editable"] = false;
    res["sortable"] = false;
    res["floatingFilter"] = false;
    res["filter"] = ""

    return res
end

function gridTreeViewCell(; 
    kwargs...
)
    res = _gridCommonCell(;kwargs...)

    res["cellRenderer"] = "treeViewCellRenderer"

    res["editable"] = false;
    res["sortable"] = false;
    res["floatingFilter"] = false;
    res["filter"] = ""

    return res
end

function gridSelectCell(; 
    kwargs...
)
    res = _gridCommonCell(;kwargs...)

    res["cellRenderer"] = "selectCellRenderer"
    res["cellEditor"] = "selectCellEditor"

    return res
end

function _is_javascript_safe(x::Integer)
    min_safe_int = -(Int64(2)^53-1)
    max_safe_int = Int64(2)^53-1
    min_safe_int < x < max_safe_int
end

function _is_javascript_safe(x::AbstractFloat)
    min_safe_float = -(Float64(2)^53-1)
    max_safe_float = Float64(2)^53-1
    min_safe_float < x < max_safe_float
end


function table2json(schema, rows)
    res = []
    for (i, row) in enumerate(rows)
        r = OrderedDict()
        Tables.eachcolumn(schema, row) do val, ind, name
            if val isa Real && isfinite(val) && _is_javascript_safe(val)
                # JSON.show_pair(columnwriter, ser, name, val)
                r[name] = val
            elseif val === nothing || val === missing
                # JSON.show_pair(columnwriter, ser, name, repr(val))
                r[name] = repr(val)
            else
                # JSON.show_pair(columnwriter, ser, name, sprint(print, val))
                r[name] = sprint(print, val)
            end
        end
        push!(res, r)
    end
    return res
end

"""
    table2agGrid(table)

Takes a `Tables.jl` compatable table and return the agGrid represantation of it with default colDefs.
"""
function table2agGrid(table)
    res = OrderedDict()

    rows = Tables.rows(table)
    schema = Tables.schema(rows)
    
    names = schema.names
    types = schema.types

    # create the column definitions
    res["columnDefs"] = [
        OrderedDict(
            "headerName" => string(n),
            # "editable" => cell_changed !== nothing,
            "headerTooltip" => string(types[i]),
            "field" => string(n),
            "sortable" => true,
            "resizable" => true,
            "type" => types[i] <: Union{Missing, T where T <: Number} ? "numericColumn" : nothing,
            "filter" => types[i] <: Union{Missing, T where T <: Dates.Date} ? "agDateColumnFilter" :
                    types[i] <: Union{Missing, T where T <: Number} ? "agNumberColumnFilter" : true,
        ) for (i, n) in enumerate(schema.names)
    ]

    res["defaultColDef"] = OrderedDict(
        "width" => 150,
        "editable" => true,
        "filter" => "agTextColumnFilter",
        "floatingFilter" => true,
        "resizable" => true,
    )

    res["rowData"] = table2json(schema, rows)

    res["_metaData"] = OrderedDict(
        "ag_grid_materializer" => Tables.materializer(table),
        "ag_grid_schema" => schema,
    )

    return res;
end



"""
    table2agGridTree(table, id::String, parentId::String)

Takes a `Tables.jl` compatable table and return the agGrid represantation of it with default colDefs.
The table data is assumed to represent an hericical data structure where the `id` parameter is the field containing a unique id, and the
`parentId` parameter is the field containing the parent id of the specific row.
"""
function table2agGridTree(table, id::String, parentId::String)

    #
    # build a dict representing the tree from the flat table 
    #
    rows = Tables.rows(table)
    id_2_node_map = Dict()
    for (i, row) in enumerate(rows)
        # node = create_node(row)        
        node = Dict([Symbol(col) => Tables.getcolumn(row, col) for col in Tables.columnnames(row)])
        
        # each node contains a treeview specific information in a _treeview field
        node[:_treeview] = Dict{Symbol, Any}(
            :children => [],
            :expanded => false,
            :filtered => false,
            :level => 0,
        )

        id_2_node_map[Tables.getcolumn(row, Symbol(id))] = node
    end

    # move children nodes under their PrepareTableOptions
    # looping on the grid instead of the id_2_node_map in order to keep the original order of items in the table 
    # without the need to use OrderedDict
    final_tree = []
    for (i, row) in enumerate(rows)
        k = Tables.getcolumn(row, Symbol(id))
        v = id_2_node_map[k]
        parent = v[ Symbol(parentId)]
        if (parent === missing || parent == "" || parent == -1)
            push!(final_tree, v)
        else
            parent_node = id_2_node_map[parent]
            push!(parent_node[:_treeview][:children], v)
        end
    end 


    res = OrderedDict()

    rows = Tables.rows(table)
    schema = Tables.schema(rows)
    
    names = schema.names
    types = schema.types

    # create the column definitions
    res["columnDefs"] = [
        OrderedDict(
            "headerName" => string(n),
            # "editable" => cell_changed !== nothing,
            "headerTooltip" => string(types[i]),
            "field" => string(n),
            "sortable" => true,
            "resizable" => true,
            "type" => types[i] <: Union{Missing, T where T <: Number} ? "numericColumn" : nothing,
            "filter" => types[i] <: Union{Missing, T where T <: Dates.Date} ? "agDateColumnFilter" :
                    types[i] <: Union{Missing, T where T <: Number} ? "agNumberColumnFilter" : true,
        ) for (i, n) in enumerate(schema.names)
    ]

    res["defaultColDef"] = OrderedDict(
        "width" => 150,
        "editable" => true,
        "filter" => "agTextColumnFilter",
        "floatingFilter" => true,
        "resizable" => true,
    )

    # res["rowData"] = table2json(schema, rows)
    res["rowData"] = final_tree

    res["_metaData"] = OrderedDict(
        "ag_grid_materializer" => Tables.materializer(table),
        "ag_grid_schema" => schema,
    )

    return res;
end



"""
    getTypes(m::Any, arr::Vector{Any})

This function has no place in this package and is just a utility function that fills an array with information of types in the given module.
The function is here in order to test the agGrid tree view capabilities but it has nothing to do with UI or Visualization.    
"""
function getTypes(m::Any, arr::Vector{Any})
    # key = string(m)

    item = Dict{Any, Any}(
        :name => string(m),
        :type => string(m), # should be just m
        :desc => "",
        :children => Vector{Any}(),
        :file => nothing,
        :line => nothing,
        :docs => "",
        :hasDocs => false, 
        :module => "?",
        :symbol => "?",
    )

    if (m isa Module)
        sym = names(m; all=true)
        for s in sym
            if (occursin("#", string(s)))
                continue
            end
            if (string(s) in ["eval", "include"])
                continue
            end

            local type = nothing
            try
                type = getfield(m, s)
            catch e
                @warn "Can't process [$m].[$s]\n$e\nskipping..." 
                continue
            end

            # filter the actual module we are scanning - it appears in the list of names
            if (type === m)
                continue
            end

            stat = getTypes(type, item[:children])
            
            # special treatment for names of primitie types
            if (stat)
                if (isprimitivetype(typeof(type)) || type isa AbstractString || type isa Function)
                    item[:children][end][:name] = "$m.$s"
                    item[:children][end][:type] = "$m.$s"
                end
                item[:children][end][:module] = string(m)
                item[:children][end][:symbol] = string(s)

                # try to get documentation
                binding = Docs.Binding(m, s)
                documentation = Markdown.plain(REPL.doc(binding))
                # if item has documentation we want to add the summary of it anyway
                if (!startswith(documentation, "No documentation found.")) 
                    
                    item[:children][end][:hasDocs] = true
                    alias = Docs.aliasof(binding)
                    extra_doc = Markdown.plain(REPL.summarize(alias, Union{}))
                    # @info documentation extra_doc[24:end]

                    documentation = documentation * "-------------------------------" * extra_doc[25:end]
                end
                
                item[:children][end][:docs] = documentation
        
            end

        end
        len = length(item[:children])
        item[:desc] = "Module containing $len items"
        push!(arr, item)
    elseif (m isa DataType)
        item[:desc] = "DataType Super[$(supertype(m))] Mutable[$(getfield(m, :mutable))]]"
        push!(arr, item)
    elseif (isprimitivetype(typeof(m)))
        item[:desc] = "PrimitiveType Type[$(typeof(m))] value[$m]"
        push!(arr, item)
    elseif (isprimitivetype(typeof(m)))
        item[:desc] = "PrimitiveType Type[$(typeof(m))] value[$m]"
        push!(arr, item)
    elseif (m isa AbstractString)
        item[:desc] = "AbstractString Type[$(typeof(m))] value[$m]"
        push!(arr, item)
    elseif (m isa Function)
        # item[:desc] = "Function Super[$(supertype(m))] Mutable[$(getfield(m, :mutable))]]"
        meths = methods(m)
        if (length(meths) == 1)
            item[:desc] = "Function Signature[$(meths.ms[1].sig)]"
            item[:file] = string(meths.ms[1].file)
            item[:line] = meths.ms[1].line
        else
            item[:desc] = "Function Signature[$(meths)]"
        end
        push!(arr, item)
    elseif (m isa UnionAll)
        item[:desc] = "UnionAll Body[$(getfield(m, :body))]"
        push!(arr, item)
    else
        @warn "Don't know how to handle [$m] [$(typeof(m))]"
        return false
    end
    return true
end


function toJSONTableRow(item, id, parent_id)
    # shorten the name to the part after the last period

    short_name = item[:name]
    pos = findlast(".", short_name)
    if (pos !== nothing)
        short_name = short_name[pos[1]+1:end]        
    end


    return Dict(
        "_id" => id, 
        "_parentId" => parent_id,
        "name" => short_name,
        "type" => item[:type],
        "desc" => item[:desc],
        "file" => item[:file],
        "line" => item[:line],
        "docs" => item[:docs],
        "hasDocs" => item[:hasDocs],
        "module" => item[:module],
        "symbol" => item[:symbol],
    )
end

function toJSONTableRecursive(data::Vector{Any}, parent_id::Int64, json_data::Vector{Any})
    for item in data
        id = length(json_data)
        row = toJSONTableRow(item, id, parent_id)
        push!(json_data, row)

        toJSONTableRecursive(item[:children], id, json_data)
    end
end

"""
    toJSONTable(data::Vector{Any}, parent_id::Int64 = -1)

Utility function to convert the result of `getTypes` in to a JSON table (Tables.jl compatiable data structure)
"""
function toJSONTable(data::Vector{Any}, parent_id::Int64 = -1)
    json_data = Vector{Any}()

    toJSONTableRecursive(data, parent_id, json_data)

    # return JSONTables.jsontable(json_data)
    # return json_data
    JSONTables.jsontable(JSON.json(json_data))
end

function toJSONTable(jsonStr::String)
    JSONTables.jsontable(jsonStr)
end



end # module GridUtils
