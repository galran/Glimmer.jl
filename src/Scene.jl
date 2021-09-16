


struct Scene <: AbstractScene
    _vis::MeshCat.Visualizer
    _windows::Union{Blink.Window, Nothing}
    _root::AbstractSceneObject
    _root_transform::AbstractSceneObject

    function Scene(; openWindow::Bool = false)
        vis = MeshCat.Visualizer()
 
        win = nothing
        if (openWindow)
            window_defaults = Blink.@d(
                :title => "Glimmer Viewer", 
                :width=>1200, 
                :height=>800,
            )
            win = Blink.Window(window_defaults)
            
            Blink.AtomShell.opentools(win)
            open(vis, win)
        end
 
        root, root_transform = prepare_scene!(vis)

        return new(vis, win, root, root_transform)
    end

end

# returns the URL for the local server
url(s::Scene) = MeshCat.url(s._vis.core)

vis(s::Scene) = s._vis
win(s::Scene) = s._window
root(s::Scene) = s._root
root_transform(s::Scene) = s._root_transform

function clear(s::Scene)
    root_so = root(s)
    root_children = prop(root_so, :children)
    while(length(root_children) > 0)
        delete!(root_children[1])
        root_children = prop(root_so, :children)
    end

    # index = findfirst(x -> x===so, parent_children)
    # if (index === nothing)
    #     @error "Can't find the child $(name(so)) to delete"
    # end
    # deleteat!(parent_children, index)

    # v = vis(so)
    # delete!(v)
end

function prepare_scene!(vis::MeshCat.Visualizer)
    root_transform = EmptySceneObject(name="GlimmerTransform")
    root_transform_vis = vis["/Glimmer"]
    vis!(root_transform, root_transform_vis)

    root = EmptySceneObject(name="GlimmerRoot")
    root_vis = root_transform_vis["Root"]
    vis!(root, root_vis)

    # flip Y and Z axes
    # MeshCat.settransform!(root_transform_vis, tr2affine(Transform(unitX3(), unitZ3(), unitY3())))
    # rotation = SMatrix{3,3}(1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 1.0, 0.0) # X, Z, Y
    # MeshCat.settransform!(root_transform_vis, AffineMap(rotation, zero3()))
    set_Y_up!(root_transform_vis)

    return root, root_transform
end

function cameraTransform!(s::Scene, tr::AffineMap)
    cam_vis = vis(s)["/Cameras/default/rotated/<object>"]

    MeshCat.settransform!(cam_vis, tr)
end

function set_Y_up!(s::Scene)
    set_Y_up!(vis(s))
end

function set_Y_up!(vis::MeshCat.Visualizer)
    rotation = SMatrix{3,3}(1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 1.0, 0.0) # X, Z, Y
    MeshCat.settransform!(vis, AffineMap(rotation, zero3()))
end


function set_Z_up!(s::Scene)
    # MeshCat.settransform!(vis(s), tr2affine(Transform(unitX3(), unitY3(), unitZ3())))
    rotation = SMatrix{3,3}(1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0) # X, Y, Z
    MeshCat.settransform!(vis(s), AffineMap(rotation, zero3()))
end

function grid!(s::Scene, visible::Bool)
    MeshCat.setprop!(vis(s)["/Grid"], "visible", visible)
end

function axes!(s::Scene, visible::Bool)
    MeshCat.setprop!(vis(s)["/Axes"], "visible", visible)
end

function cameraPlanes!(s::Scene, near::Float64 = 0.1, far::Float64 = 1000.0)
    cam_vis = vis(s)["/Cameras/default/rotated/<object>"]

    # MeshCat.setprop!(cam_vis, "zoom", 1.0)
    MeshCat.setprop!(cam_vis, "near", near)
    MeshCat.setprop!(cam_vis, "far", far)
end





