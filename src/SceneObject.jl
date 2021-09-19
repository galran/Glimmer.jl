

props(so::AbstractSceneObject) = so._props
function prop(so::AbstractSceneObject, p::Symbol, default_val = nothing)
    return get(props(so), p, default_val)
end
function prop!(so::AbstractSceneObject, p::Symbol, val::Any)
    props(so)[p] = val
end

name(so::AbstractSceneObject) = prop(so, :name)

tr(so::AbstractSceneObject) = prop(so, :tr)
function tr!(so::AbstractSceneObject, tr::AffineMap) 
    prop!(so, :tr, tr)
end

local_tr(so::AbstractSceneObject) = prop(so, :tr)
function local_tr!(so::AbstractSceneObject, local_tr::AffineMap) 
    prop!(so, :tr, local_tr)
end


vis(so::AbstractSceneObject) = prop(so, :vis)
function vis!(so::AbstractSceneObject, vis::MeshCat.Visualizer) 
    prop!(so, :vis, vis)
end

scene(so::AbstractSceneObject) = prop(so, :scene)
function scene!(so::AbstractSceneObject, s::AbstractScene) 
    prop!(so, :scene, s)
end

parent(so::AbstractSceneObject) = prop(so, :parent)
function parent!(so::AbstractSceneObject, parent_so::AbstractSceneObject)
    prop!(so, :parent, parent_so)

    parent_children = prop(parent_so, :children)
    index = findfirst(x -> x===so, parent_children)
    if (index === nothing)
        push!(parent_children, so)
    end

    update!(so)
end

material(so::AbstractSceneObject) = prop(so, :material)
function material!(so::AbstractSceneObject, mat::Material)
    prop!(so, :material, mat)
    
    update!(so)
end


function update!(so::AbstractSceneObject)
    v = vis(parent(so))[name(so)]
    vis!(so, v)

    render!(so)
end

function Base.delete!(so::AbstractSceneObject)
    parent_so = prop(so, :parent)
    parent_children = prop(parent_so, :children)
    index = findfirst(x -> x===so, parent_children)
    if (index === nothing)
        @error "Can't find the child $(name(so)) to delete"
    end
    deleteat!(parent_children, index)

    v = vis(so)
    delete!(v)

    # render!(so)
end

function display(so::AbstractSceneObject, level=0)
    print(' '^(3*level))
    println(name(so))
    children = prop(so, :children)
    for child in children
        display(child, level+1)
    end
end


function build_props(;kwargs...)
    res = Dict{Symbol, Any}(
        :tr => identityTransform(),
        :children => Vector{AbstractSceneObject}(undef, 0),
    )
    for a in kwargs
        res[a[1]] = a[2]
    end
    return res
end



#-----------------------------------------------------------------
# Empty Scene Object 
#-----------------------------------------------------------------
mutable struct EmptySceneObject <: AbstractSceneObject
    _props::Dict{Symbol, Any}

    function EmptySceneObject(;kwargs...)
        props = build_props(;kwargs...)
        return new(props)
    end
end

function render!(e::EmptySceneObject) 
end

#-----------------------------------------------------------------
# Box
#-----------------------------------------------------------------
mutable struct PointCloud <: AbstractSceneObject
    _props::Dict{Symbol, Any}

    function PointCloud(;name="defaultPoints", points::Vector{SVector{3, Float64}} = [], kwargs...)
        props = build_props(;name=name, points=points, kwargs...)

        return new(props)
    end
end

points(pc::PointCloud) = prop(pc, :points)

function render!(pc::PointCloud) 
    v = vis(pc)

    points = prop(pc, :points)

    mat = material(pc)
    if (mat !== nothing)
        mat_color = color(mat)
        colors = repeat([mat_color], length(points))
        pointcloud = MeshCat.PointCloud(points, colors)
    else
        pointcloud = MeshCat.PointCloud(points)
    end

    if (mat !== nothing)
        MeshCat.setobject!(v, pointcloud, points_material(mat))
        # MeshCat.setobject!(v, pointcloud)
    else
        MeshCat.setobject!(v, pointcloud)
    end

    MeshCat.settransform!(v, local_tr(pc))
end

#-----------------------------------------------------------------
# Box
#-----------------------------------------------------------------
mutable struct Box <: AbstractSceneObject
    _props::Dict{Symbol, Any}

    function Box(;name="defaultBox", size::SVector{3, Float64} = SVector(1.0, 1.0, 1.0), kwargs...)
        props = build_props(;name=name, size=size, kwargs...)

        return new(props)
    end
end

Base.size(b::Box) = prop(b, :size)

function render!(b::Box) 
    v = vis(b)
    min_point = size(b) * -0.5
    mat = material(b)
    box = GeometryBasics.HyperRectangle(GeometryBasics.Vec(min_point...), GeometryBasics.Vec(size(b)...))
    if (mat !== nothing)
        MeshCat.setobject!(v, box, material(mat))
    else
        MeshCat.setobject!(v, box)
    end

    affine_map = local_tr(b)
    MeshCat.settransform!(v, affine_map)
end

#-----------------------------------------------------------------
# MeshCat.Mesh
#-----------------------------------------------------------------
mutable struct Mesh <: AbstractSceneObject
    _props::Dict{Symbol, Any}

    function Mesh(; name="defaultMesh", mesh::GeometryBasics.AbstractMesh, kwargs...)
        props = build_props(; mesh=mesh, name=name, kwargs...)

        return new(props)
    end
end

mesh(m::Mesh) = prop(m, :mesh)

function render!(m::Mesh) 
    v = vis(m)
    mat = material(m)
    if (mat !== nothing)
        MeshCat.setobject!(v, mesh(m), material(mat))
    else
        MeshCat.setobject!(v, mesh(m))
    end

    MeshCat.settransform!(v, local_tr(m))
end

# create a primitive mesh: rect, box, sphere, cone
function primitive(type::Symbol = :sphere; name="primitive", kwargs...)
    mesh = nothing
    if (type == :box || type == :cube)
        box = GeometryBasics.HyperRectangle(GeometryBasics.Vec(-0.5, -0.5, -0.5), GeometryBasics.Vec(1.0, 1.0, 1.0))
        mesh = GeometryBasics.mesh(box, uv=GeometryBasics.Vec2f0)        
    elseif (type == :rect || type == :rectangle)
        box = GeometryBasics.HyperRectangle(GeometryBasics.Vec(-0.5, -0.5, 0), GeometryBasics.Vec(1.0, 1.0, 0))
        mesh = GeometryBasics.mesh(box, uv=GeometryBasics.Vec2f0)        
    else (type == :sphere)
        sphere = GeometryBasics.HyperSphere(GeometryBasics.Point(0.0, 0.0, 0.0), 0.5)
        mesh = GeometryBasics.mesh(sphere, uv=GeometryBasics.Vec2f0)        
    end
    res = Mesh(; name=name, mesh=mesh, kwargs...)
    return res
end

#-----------------------------------------------------------------

#-----------------------------------------------------------------
# Arrow
#-----------------------------------------------------------------
mutable struct Arrow <: AbstractSceneObject
    _props::Dict{Symbol, Any}

    function Arrow(; name="defaultArrow", from::SVector{3, Float64}, to::SVector{3, Float64}, kwargs...)
        props = build_props(; from=from, to=to, name=name, kwargs...)

        return new(props)
    end
end

from(a::Arrow) = prop(a, :from)
to(a::Arrow) = prop(a, :to)

function render!(a::Arrow) 
    v = vis(a)
    mat = material(a)
    if (mat === nothing)
        mat = Material()
    end

    f = from(a)
    t = to(a)
    vec = t - f
    point = GeometryBasics.Point(f...)
    vec = GeometryBasics.Vec((t - f)...)

    arrow = MeshCat.ArrowVisualizer(v)
    MeshCat.setobject!(arrow, material(mat))
    MeshCat.settransform!(arrow, point, vec)
end
#-----------------------------------------------------------------

#-----------------------------------------------------------------
# Axes
#-----------------------------------------------------------------
mutable struct Axes <: AbstractSceneObject
    _props::Dict{Symbol, Any}

    function Axes(; 
        name="defaultAxes", 
        x_axis::SVector{3, Float64} = unitX3(), 
        y_axis::SVector{3, Float64} = unitY3(), 
        z_axis::SVector{3, Float64} = unitZ3(), 
        kwargs...
    )
        props = build_props(; x_axis=x_axis, y_axis=y_axis, z_axis=z_axis, name=name, kwargs...)

        return new(props)
    end
end

x_axis(a::Axes) = prop(a, :x_axis)
y_axis(a::Axes) = prop(a, :y_axis)
z_axis(a::Axes) = prop(a, :z_axis)

function render!(a::Axes) 
    v = vis(a)
    mat = material(a)
    if (mat === nothing)
        mat = Material()
    end

    point = GeometryBasics.Point(0.0, 0.0, 0.0)

    shaft_scale = prop(a, :shaft_scale, 0.01)
    axes_scale = prop(a, :axes_scale, 1.0)

    color!(mat, Colors.RGBA(0.9, 0.1, 0.1, 1.0))
    vec = GeometryBasics.Vec(prop(a, :x_axis)) * axes_scale
    arrow = MeshCat.ArrowVisualizer(v["X"])
    MeshCat.setobject!(arrow, material(mat))
    MeshCat.settransform!(arrow, point, vec, shaft_radius = shaft_scale)

    color!(mat, Colors.RGBA(0.1, 0.9, 0.1, 1.0))
    vec = GeometryBasics.Vec(prop(a, :y_axis)) * axes_scale
    arrow = MeshCat.ArrowVisualizer(v["Y"])
    MeshCat.setobject!(arrow, material(mat))
    MeshCat.settransform!(arrow, point, vec, shaft_radius = shaft_scale)

    color!(mat, Colors.RGBA(0.1, 0.1, 0.9, 1.0))
    vec = GeometryBasics.Vec(prop(a, :z_axis)) * axes_scale
    arrow = MeshCat.ArrowVisualizer(v["Z"])
    MeshCat.setobject!(arrow, material(mat))
    MeshCat.settransform!(arrow, point, vec, shaft_radius = shaft_scale)

    MeshCat.settransform!(v, local_tr(a))
end
#-----------------------------------------------------------------

#-----------------------------------------------------------------
# Line Segments
#-----------------------------------------------------------------
mutable struct LineSegments <: AbstractSceneObject
    _props::Dict{Symbol, Any}

    function LineSegments(; name="defaultAxes", points::Vector{SVector{3, Float64}} = [], kwargs...)
        props = build_props(; points=points, name=name, kwargs...)

        return new(props)
    end
end

points(ls::LineSegments) = prop(ls, :points)

function render!(ls::LineSegments) 
    v = vis(ls)
    mat = material(ls)

    pts = points(ls)
    pts2 = GeometryBasics.Point.(pts)

    if (mat !== nothing)
        MeshCat.setobject!(v, MeshCat.LineSegments(GeometryBasics.Point.(points(ls)), lines_material(mat)))
    else
        MeshCat.setobject!(v, MeshCat.LineSegments(GeometryBasics.Point.(points(ls))))
    end
    MeshCat.settransform!(v, transform(local_tr(ls)))
end

#-----------------------------------------------------------------
