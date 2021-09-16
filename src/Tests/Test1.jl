

using Blink

using MeshCat
using CoordinateTransformations
using Rotations
using GeometryBasics: HyperRectangle, Vec, Point, Mesh, Point3f0
using Colors: RGBA, RGB


if (false)
    vis = MeshCat.Visualizer()
    win = Blink.Window()
    open(vis, win)
    Blink.AtomShell.opentools(win)
end


# box = HyperRectangle(Vec(0., 0, 0), Vec(1., 1, 1))
# setobject!(vis, box)
# settransform!(vis, Translation(0., 1, 0))


# green_box_vis = setobject!(vis["group1"]["greenbox"], box, green_material)
# settransform!(green_box_vis, Translation(0, 0, 1))
# group1 = vis["group1"]
# settransform!(group1, Translation(0, 0, -1))

delete!(vis)

v = vis[:lines]
settransform!(v, Translation(-1, -1, 0))
points = [
    Point3f0(1, 1, 1),
    Point3f0(2, 2, 2),
    Point3f0(1, 1, 3),
    Point3f0(2, 2, 3),
]
colors = [
    RGBA(1, 0, 0, 1),
    RGBA(1, 0, 0, 1),
    RGBA(0, 1, 0, 1),
    RGBA(0, 1, 0, 1),
]
mat = LineBasicMaterial(
    color=RGBA(1.0, 1.0, 0.0, 1.0),
    linewidth = 11,
    # vertexColors = 1,
)
setobject!(v[:line_segments], LineSegments(points, colors))

# v = vis[:lines]
# settransform!(v, Translation(-1, -1, 0))
# θ = range(0, stop=2π, length=10)
# mat = LineBasicMaterial(
#     color=RGBA(1.0, 1.0, 0.0, 1.0),
#     linewidth = 11,
#     # vertexColors = 1,
# )
# setobject!(v[:line_segments], LineSegments(Point.(0.5 .* sin.(θ), 0, 0.5 .* cos.(θ)), mat))



# box = HyperRectangle(Vec(0., 0, 0), Vec(1., 1, 1))
# setobject!(vis["box"], box)
# settransform!(vis, Translation(0., 2, 0))

# vbox = vis["box"]

# va1 = vbox["arrow1"]
# arrow1 = ArrowVisualizer(va1)
# setobject!(arrow1)
# settransform!(arrow1, Point(5.0, 5.0, 5.0), Vec(-4.0, -4.0, -4.0), shaft_radius=0.1)

# va2 = vbox["arrow2"]
# arrow2 = ArrowVisualizer(va2)
# setobject!(arrow2)
# settransform!(arrow2, Point(-1.0, 2.0, 2.0), Vec(1.0, -1.0, -1.0))

# va3 = vbox["arrow3"]
# arrow3 = ArrowVisualizer(va3)
# setobject!(arrow3)
# settransform!(arrow3, Point(-1.0, -1.0, 2.0), Vec(1.0, 1.0, -1.0))

# va4 = vbox["arrow4"]
# arrow4 = ArrowVisualizer(va4)
# setobject!(arrow4)
# settransform!(arrow4, Point(2.0, -1.0, 2.0), Vec(-1.0, 1.0, -1.0))