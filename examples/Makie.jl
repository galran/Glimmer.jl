module Example

using Glimmer, Glimmer.FlexUI
import Makie, GLMakie

println("Start [$(splitext(basename(@__FILE__))[1])]")

#---------------------------------------------------------------
# define the application and some basic properties such as title and initial window size
#---------------------------------------------------------------
app = App()
prop!(app, :title, "Glimmer Example - Makie")
prop!(app, :winInitWidth, 1200)
prop!(app, :winInitHeight, 800)

#---------------------------------------------------------------
# Define Variables
#---------------------------------------------------------------
xscale = addVariable!(app, Variable(name="xscale", type="flota64",value=1))
yscale = addVariable!(app, Variable(name="yscale", type="flota64",value=1))

image = addVariable!(app, Variable(name="image", type="image", value="", ))

#---------------------------------------------------------------
# Define Controls
#---------------------------------------------------------------
ui = VContainer(
    Card(
        title="Controls",
        content=VContainer(
            Slider(
                text="X Scale [1-10]",
                trailingText="[\$()]",
                min=1,
                max=10,
                value=1,
                variable="xscale"
            ),  
            Slider(
                text="Y Scale [1-10]",
                trailingText="[\$()]",
                min=1,
                max=10,
                value=1,
                variable="yscale"
            ),  
        ),              
    ),

    Card(
        title="Result Image",
        content=VContainer(
            Image(
                source="\$(image)",
            ),        
        ),              
    ),

    Glimmer.exampleSourceAsCard(@__FILE__),     # add the source code of the example as the last control

)
# set the controls for the application
controls!(app, ui)

#---------------------------------------------------------------
# the render function
#---------------------------------------------------------------
function render()
    Makie.inline!(true);
    
    f = Makie.Figure()
    Makie.Axis(f[1, 1])
    
    xs = LinRange(0, 10, 100)
    ys = LinRange(0, 15, 100)
    zs = [cos(xscale[]*x) * sin(yscale[]*y) for x in xs, y in ys]
    
    Makie.contour!(xs, ys, zs)
    
    # Makie.display(f)
    image["png"] = f;

end
renderFunction!(app, render)

#---------------------------------------------------------------
# Run the application
#---------------------------------------------------------------
run(app)

println("End [$(splitext(basename(@__FILE__))[1])]")

end # module