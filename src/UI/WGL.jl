
module WGL

using ..Glimmer
import ..UIVariables
using Parameters
import UUIDs
import Colors;
using OrderedCollections 
import JSON

export  WGLColor,
        WGLWireframe,
        WGLMaterial,
        WGLMeshGeometry,
        WGLLinesGeometry,
        WGLPointsGeometry,
        WGLObject,
        WGLTransform,
        WGLSetTransform,
        wglSet!,

        DymmyExport



function typedict(x::AbstractWGLComponent) 
    res = OrderedDict()

    for fn in filter(x -> !startswith(string(x), "_"), fieldnames(typeof(x)))
        key = fn
        val = getfield(x, fn) 
        if (val === nothing)
            continue
        end
        if (isstructtype(typeof(val)) && !(val isa String))    
            if (val isa Dict || val isa OrderedDict)
                # @info "DICT" key, val
                res[key] = val;
            elseif (val isa Vector)
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

# -----------------------------------------------------------------------

@enum WGLTypes begin
    TMaterial = 1
    TGeometry = 2
    TObject = 3
    TOther = 4
end

@with_kw mutable struct WGLPath <: AbstractWGLComponent
    var::AbstractUIVariable
    path::String
    type::WGLTypes
end


@with_kw mutable struct WGLColor <: AbstractWGLComponent
    r::Float32 = 0.0f
    g::Float32 = 0.0f
    b::Float32 = 0.0f
    a::Float32 = 1.0f
end


WGLColor(c::Tuple{Int64,Int64,Int64}) = WGLColor(
    r=Float32(c[1]) / 255.0f0, 
    g=Float32(c[2]) / 255.0f0, 
    b=Float32(c[3]) / 255.0f0, 
    a=1.0f0)


@with_kw mutable struct WGLWireframe <: AbstractWGLComponent
    show::Bool = false
    lineWidth::Float32 = 1.0f
    color::WGLColor = WGLColor((0, 0, 0))
end

WGLWireframe(lineWidth::Float32, color::WGLColor=WGLColor(0.0f0, 0.0f0, 0.0f0, 1.0f0)) = WGLWireframe(
    show=true,
    lineWidth=lineWidth,
    color=color
)

@with_kw mutable struct WGLTransform <: AbstractWGLComponent
    matrixCoef::Union{Nothing, Vector{Float32}} = nothing
    
    scale::Union{Nothing, Vector{Float32}} = nothing
    translation::Union{Nothing, Vector{Float32}} = nothing
    rotation::Union{Nothing, Vector{Float32}} = nothing
end

WGLTransform(pos::Tuple{Float32,Float32,Float32}) = WGLTransform(
    translation = [pos[1], pos[2], pos[3]],
    rotation = [0.0f0, 0.0f0, 0.0f0],
    scale = [1.0f0, 1.0f0, 1.0f0],
)



@with_kw mutable struct WGLMaterial <: AbstractWGLMaterial 
    name::String
    type::String
    color::WGLColor = WGLColor((0, 0, 0))
    wireframe::Union{Nothing, WGLWireframe} = WGLWireframe(show=false)
end


@with_kw mutable struct WGLMeshGeometry <: AbstractWGLMaterial 
    name::String
    vertices::Union{Nothing, Vector{Float32}} = nothing
    triangles::Union{Nothing, Vector{Int64}} = nothing
    uvs::Union{Nothing, Vector{Float32}} = nothing
end

@with_kw mutable struct WGLLinesGeometry <: AbstractWGLMaterial 
    name::String
    vertices::Union{Nothing, Vector{Float32}} = nothing
    continuous::Bool = false
    joins::String = "none"                          # none, fill, weld
end

@with_kw mutable struct WGLPointsGeometry <: AbstractWGLMaterial 
    name::String
    vertices::Union{Nothing, Vector{Float32}} = nothing
end


@with_kw mutable struct WGLObject <: AbstractWGLMaterial 
    name::String
    parentName::String = ""
    transform::WGLTransform = WGLTransform((0f0, 0f0, 0f0))
    geometryName::String
    materialName::String
end


@with_kw mutable struct WGLSetTransform <: AbstractWGLMaterial 
    name::String = ""
    transform::WGLTransform = WGLTransform((0f0, 0f0, 0f0))
end


# ---------------------------------------------------------------------------

function wglSendToRenderer!(var::AbstractUIVariable, obj::AbstractWGLComponent, methodName::String; mergeData::Union{Nothing, Dict, OrderedDict} = nothing)
    data = WGL.typedict(obj)

    if (mergeData !== nothing)
        data = merge(data, mergeData)
    end

    json = JSON.json(data)
    js_data = Dict{Symbol, Any}(
        :methodName => methodName,
        :json => json,
    )
    send!(var, js_data);
end


function wglSet!(var::AbstractUIVariable, mat::WGLMaterial)::WGLPath
    wglSendToRenderer!(var, mat, "ProcessMaterial")

    return WGLPath(
        var = var,
        path = mat.name,
        type = TMaterial                
    )
end

function wglSet!(var::AbstractUIVariable, geometry::WGLMeshGeometry)::WGLPath
    wglSendToRenderer!(var, geometry, "ProcessTriangleMesh")

    return WGLPath(
        var = var,
        path = geometry.name,
        type = TGeometry                
    )
end

function wglSet!(var::AbstractUIVariable, geometry::WGLLinesGeometry)::WGLPath
    wglSendToRenderer!(var, geometry, "ProcessLines")

    return WGLPath(
        var = var,
        path = geometry.name,
        type = TGeometry                
    )
end

function wglSet!(var::AbstractUIVariable, geometry::WGLPointsGeometry)::WGLPath
    wglSendToRenderer!(var, geometry, "ProcessPoints")

    return WGLPath(
        var = var,
        path = geometry.name,
        type = TGeometry                
    )
end

function wglSet!(var::AbstractUIVariable, object::WGLObject)::WGLPath
    wglSendToRenderer!(var, object, "ProcessObject")

    object_path = object.parentName * "/" * object.name;

    return WGLPath(
        var = var,
        path = object_path,
        type = TObject                
    )
end


function wglSet!(path::WGLPath, object::WGLObject)::WGLPath
    wglSendToRenderer!(path.var, object, "ProcessObject"; mergeData = Dict(:parentName => path.path))

    object_path = path.path * "/" * object.name;

    return WGLPath(
        var = path.var,
        path = object_path,
        type = TObject                
    )
end

function wglSet!(var::AbstractUIVariable, objectTransform::WGLSetTransform)::WGLPath
    wglSendToRenderer!(var, objectTransform, "ProcessObjectTransform")

    return WGLPath(
        var = var,
        path = objectTransform.name,
        type = TOther                
    )
end

function wglSet!(path::WGLPath, objectTransform::WGLSetTransform)::WGLPath
    wglSendToRenderer!(path.var, objectTransform, "ProcessObjectTransform"; mergeData = Dict(:name => path.path))

    return WGLPath(
        var = path.var,
        path = path.path,
        type = TOther                
    )
end



end # module WGL

