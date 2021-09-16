
# declaration of basic types 
abstract type AbstractScene end
abstract type AbstractSceneObject end
abstract type AbstractMaterial end
abstract type AbstractUIApp end
abstract type AbstractUIVariable end
abstract type AbstractUIValidation end
abstract type AbstractUIControl end

export  AbstractScene,
        AbstractSceneObject,
        AbstractMaterial,
        AbstractUIApp,
        AbstractUIVariable,
        AbstractUIValidation,
        AbstractUIControl

# place holders for function names        
prop() = 0        
prop!() = 0        

function updateVariable!(app::AbstractUIApp, var::AbstractUIVariable)
    @error "abstract function - should not reach here"
end

#---------------------------------------------------------------
#   utility methods to convert image data into Base64 representation suted for JavaScript.
#---------------------------------------------------------------
show_png(io, x) = show(io, MIME"image/png"(), x)
show_svg(io, x) = show(io, MIME"image/svg+xml"(), x)

base64png(img) = "data:image/png;base64,$(Base64.base64encode(show_png, img))"
base64svg(img) = "data:image/svg+xml;base64,$(Base64.base64encode(show_svg, img))"


# #---------------------------------------------------------------
# #   Transform to AffineMat that can be used in the renderer
# #---------------------------------------------------------------
# function tr2affine(tr::Transform)
#     return AffineMap(tr[1:3,1:3], Geometry.origin(tr))
# end

unitX3(::Type{T} = Float64) where {T<:Real} = SVector{3,T}(1.0, 0.0, 0.0)
unitY3(::Type{T} = Float64) where {T<:Real} = SVector(0.0, 1.0, 0.0)
unitZ3(::Type{T} = Float64) where {T<:Real} = SVector(0.0, 0.0, 1.0)
zero3(::Type{T} = Float64)  where {T<:Real} = SVector(0.0, 0.0, 0.0)
identityTransform(::Type{T} = Float64) where {T<:Real} = AffineMap(SMatrix{3, 3, T, 9}(I), zero(SVector{3, T}))

#---------------------------------------------------------------
# utility function that given a vector, return 2 orthogonal vectors to that one 
#---------------------------------------------------------------
function get_orthogonal_vectors(direction::SVector{3, T}) where {T<:Real}
    axis1 = normalize(direction)

    dp = dot(unitX3(T), axis1)
    # check the special case where the input vector is parallel to the X axis
    if	( dp >= one(T) - eps(T))
        # axis1 = unitX(T);
        axis2 = unitY3(T);
        axis3 = unitZ3(T);
        return (axis2, axis3)
    elseif  ( dp <= -one(T) + eps(T))
        # axis1 = -unitX(T);
        axis2 = -unitY3(T);
        axis3 = -unitZ3(T);
        return (axis2, axis3)
    end

    axis3 = normalize(cross(axis1, unitX3(T)))
    axis2 = normalize(cross(axis3, axis1))
    return (axis2, axis3)
end

function rotation(axis1::SVector{3, T}, axis2::SVector{3, T}, axis3::SVector{3, T}) where {T<:Real}
    # this is a COLUMN MAJOR initialization, where axis N is column N
    return SMatrix{3,3,T,9}( 
        axis1[1], axis1[2], axis1[3],
        axis2[1], axis2[2], axis2[3],
        axis3[1], axis3[2], axis3[3]
    )
end

function transform(origin::SVector{3, T}, forward::SVector{3, T} = unitZ3(T)) where {T<:Real}
    forward = normalize(forward)
    right, up = get_orthogonal_vectors(forward)
    return AffineMap(rotation(right, up, forward), origin)
end
function lookAt(position::SVector{3, T}, target::SVector{3, T} = zero3(T)) where {T<:Real}
    forward = target - position
    return transform(position, forward)
end


dataPath() = joinpath(dirname(@__FILE__), "Data")

#---------------------------------------------------------------
#   Color conversion methods
#---------------------------------------------------------------
function to_color(c::Tuple{Int64, Int64, Int64})
    return Colors.RGBA((c ./ 255)...)
end

function to_color(c::Tuple{Float64, Int64, Int64})
    return Colors.RGBA(c...)
end

function to_color(c::Colors.RGBA)
    return c
end

function to_color(c::Colors.RGB)
    return RGBA(c)
end

function to_color(c::Symbol)
    return return to_color(Colors.color_names[string(c)])
end


#---------------------------------------------------------------
#   Examples Utilities
#---------------------------------------------------------------
fixFolderSeperator(fn::String) = replace(fn, '\\' => '/')

"""
    rootFolder()

return the root folder for this package.
"""
function rootFolder()
    return fixFolderSeperator(abspath(joinpath(dirname(@__FILE__), "..")))
end


"""
    examplesFolder()

return the examples folder (~/examples) for this package.
"""
function examplesFolder()
    return fixFolderSeperator(abspath(joinpath(rootFolder(), "examples")))
end

"""
    examplesList()

Display a list of avalable examples.
"""
function examplesList()
    folder = examplesFolder();

    files = readdir(folder, join=false)

    all_jl_files = [fn for fn in files if splitext(basename(fn))[2] == ".jl"]

    println("-"^60)
    println("Examples List for Glimmer  [$(folder)]")
    println("-"^60)
    for f in all_jl_files
        len = length(f)
        if (len < 20)
            spaces = " "^(20 - len)
        else
            spaces = ""
        end
        println("    $(f)$(spaces)       to run:  julia> Glimmer.runExample(\"$(splitext(f)[1])\")")
    end

end

"""
    runExample(example::String)

Run the specific example. [example] is given without extension.
For example, if we have an example file named "Controls.jl" the command to run it is:
Glimmer.runExample("Controls")
"""
function runExample(example::String)
    fn = fixFolderSeperator(joinpath(examplesFolder(), "$(splitext(example)[1]).jl"))

    @show fn
    code = "include(\"$fn\")"
    @show code
    exp = Meta.parse(code)
    return eval(exp)
end