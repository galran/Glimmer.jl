module Example

using Glimmer, Glimmer.FlexUI
using Meshing
using FileIO # MeshIO should also be installed
using GeometryBasics
using StaticArrays
using Colors
using LinearAlgebra


println("Start [$(splitext(basename(@__FILE__))[1])]")

#---------------------------------------------------------------
# define the application and some basic properties such as title and initial window size
#---------------------------------------------------------------
app = App()
prop!(app, :title, "Glimmer Example - Meshing")
prop!(app, :winInitWidth, 1400)
prop!(app, :winInitHeight,1200)

#---------------------------------------------------------------
# create the MeshCat 3D viewer
#---------------------------------------------------------------
scene = Scene(openWindow = false)
set_Z_up!(scene)
grid!(scene, false)
axes!(scene, false)
cameraTransform!(scene, lookAt(SVector(-1.0, 1.0, 1.0)*10, zero3()))
cameraPlanes!(scene, 0.1, 1000.0)


#---------------------------------------------------------------
# Define Variables
#---------------------------------------------------------------
surface_code = addVariable!(app, Variable(name="surface_code", type="string",
        value="""begin
                    gyroid(v) = cos(v[1])*sin(v[2])+cos(v[2])*sin(v[3])+cos(v[3])*sin(v[1]);
                    gyroid_shell(v) = max(gyroid(v)-0.4,-gyroid(v)-0.4);
                end"""))
status = addVariable!(app, Variable(name="status", type="string", value = ""))               

show_mesh =addVariable!(app, Variable(name="show_mesh", type="bool",value=true))
mesh_opacity = addVariable!(app, Variable(name="mesh_opacity", type="flota64",value=0.8))
mesh_wireframe =addVariable!(app, Variable(name="mesh_wireframe", type="bool",value=false))

show_pc =addVariable!(app, Variable(name="show_pc", type="bool",value=false))
pc_opacity = addVariable!(app, Variable(name="pc_opacity", type="flota64",value=0.5))

sample_resolution = addVariable!(app, Variable(name="sample_resolution", type="int",value=40))

#---------------------------------------------------------------
# Define Controls
#---------------------------------------------------------------
ui = VContainer(
    Card(
        title="Marching Cube",
        content=VContainer(
            Field(
                label = "Surface Definition",
                input = "multiline",
                style = "width: 100%; font-family: monospace; font-size: 20px;",
                hint = "defining the sureface to be constructed",
                variable="surface_code"
            ),  
            Label(
                text = "\$(status)",
                class = "h2",
                style="color: red;"
            ),

            Card(
                # title="Controls",
                content=HContainer(
                    Card(
                        # title="Controls",
                        content=VContainer(
                            Card(
                                title="Mesh Controls",
                                content=VContainer(
                                    CheckBox(
                                        label="Show Mesh",
                                        variable="show_mesh"
                                    ),  
                                    Slider(
                                        text="Mesh Opacity",
                                        trailingText="[\$()]",
                                        min=0,
                                        max=1,
                                        value=0.5,
                                        step=0.1,
                                        variable="mesh_opacity"
                                    ),  
                                    CheckBox(
                                        label="Wireframe",
                                        variable="mesh_wireframe"
                                    ),  
                                ),              
                            ),

                            Card(
                                title="Points Controls",
                                content=VContainer(
                                    CheckBox(
                                        label="Show Points",
                                        variable="show_pc"
                                    ),  
                                    Slider(
                                        text="Points Opacity",
                                        trailingText="[\$()]",
                                        min=0,
                                        max=1,
                                        value=0.5,
                                        step=0.1,
                                        variable="pc_opacity"
                                    ),  
                                ),              
                            ),

                            Card(
                                title="Sampling",
                                content=VContainer(
                                    Slider(
                                        text="Sample Resolution",
                                        trailingText="[\$()]",
                                        min=4,
                                        max=100,
                                        value=20,
                                        variable="sample_resolution"
                                    ),  
                                ),              
                            ),

                        ),              
                    ),

                    Card(
                        title="Surface Visualization",
                        style="width: 50vw;",
                        content=VContainer(
                            MeshCatViewer(
                                url =  url(scene),
                                width = "100%",
                                height = "600px",
                            ),        
                        ),              
                    ),
                
                ),              
            ),


        ),              
    ),

    Glimmer.exampleSourceAsCard(@__FILE__),     # add the source code of the example as the last control
)
# set the controls for the application
controls!(app, ui)

#---------------------------------------------------------------
# the render function - preparing the image
#---------------------------------------------------------------
# gyroid(v) = cos(v[1])*sin(v[2])+cos(v[2])*sin(v[3])+cos(v[3])*sin(v[1])
# gyroid_shell(v) = max(gyroid(v)-0.4,-gyroid(v)-0.4)
function compile()
    try
        d = Meta.parse(surface_code[]) 
        eval(d)
        Base.invokelatest(gyroid_shell, [0.0, 0.0, 0.0])    # sanity check
        status[] = ""
    catch e
        status[] = "Encountered an error [$e]"
    end
end

function surface_function(v) 
    Base.invokelatest(gyroid_shell, v)
end 

# prepare a simple texture
img = zeros(RGB, 1, 4)
img[1,1] = RGB(1.0, 0.0, 0.0)
img[1,2] = RGB(0.0, 1.0, 0.0)
img[1,3] = RGB(0.0, 0.0, 1.0)
img[1,4] = RGB(1.0, 1.0, 0.0)

io = IOBuffer()
# save(io, img)
save(Stream(format"PNG", io), img)
res = String(take!(io))
tex = Glimmer.TextureData(Vector{UInt8}(res))

function render()
    # clear the scene
    clear(scene)

    # compile the UI code
    compile()
    
    # don't process if there is an error
    if (status[] != "")
        return;
    end

    # generate directly using GeometryBasics API
    # Rect specifies the sampling intervals
    gy_mesh = GeometryBasics.Mesh(
        surface_function, 
        Rect(Vec(pi*4,pi*4,pi*4)*-0.5, Vec(pi*4,pi*4,pi*4)*1),
        MarchingCubes(), 
        samples=(sample_resolution[], sample_resolution[], sample_resolution[])
    )

    # create the texture coordinates for the new mesh
    verts = coordinates(gy_mesh)
    faces = GeometryBasics.faces(gy_mesh)
    N = length(verts)
    point_attributes = Dict{Symbol, Any}()
    point_attributes[:uv] = Vector{SVector{2, Float32}}(undef, N)
    for (i, v) in enumerate(verts)
        x = norm(v)
        y = 0.1
        point_attributes[:uv][i] = SVector(x, y)
    end

    gy_mesh = GeometryBasics.Mesh(meta(verts; point_attributes...), faces)

    # origin axes
    origin = Axes(
        tr=identityTransform(), 
        shaft_scale=0.1,
        axes_scale=5.0,
        name="Origin")
    parent!(origin , root(scene))

    # triangulated mesh
    if (show_mesh[])
        # mat = Material(color=RGBA(0.2, 0.8, 0.2, mesh_opacity[]), wireframe=mesh_wireframe[])
        mat = Material(color=RGBA(1.0, 1.0, 1.0, mesh_opacity[]), wireframe=mesh_wireframe[], texture=tex)
        mesh = Glimmer.Mesh(mesh=gy_mesh, material=mat, name="MC Mesh")
        parent!(mesh , root(scene))
    end

    # vertices
    if (show_pc[])
        points = [SVector{3, Float64}(p) for p in coordinates(gy_mesh)]
        pc_mat = Material(color=RGBA(0.7, 0.2, 0.1, pc_opacity[]), size=0.05)
        pc = PointCloud(points=points, tr=identityTransform(), material=pc_mat, name="Mesh Points")
        parent!(pc , root(scene))
    end
end
renderFunction!(app, render)

#---------------------------------------------------------------
# Run the application
#---------------------------------------------------------------
run(app)

println("End [$(splitext(basename(@__FILE__))[1])]")

GeometryBasics.normal_mesh

end # module






# # save("gyroid.ply", gy_mesh)

