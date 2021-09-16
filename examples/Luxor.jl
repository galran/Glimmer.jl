module Example

using Glimmer, Glimmer.FlexUI
using Colors
using StaticArrays
using GeometryBasics
import Luxor

println("Start [$(splitext(basename(@__FILE__))[1])]")

app = App()
prop!(app, :title, "Glimmer Example - Luxor")


#---------------------------------------------------------------
# Define Variables
#---------------------------------------------------------------

angle = addVariable!(app, Variable(name="angle", type="flota64",value=8))
count = addVariable!(app, Variable(name="count", type="flota64",value=16))

image = addVariable!(app, Variable(
    name="image",
    type="image",
    value="", 
))

#---------------------------------------------------------------
# Define Controls
#---------------------------------------------------------------

ui = VContainer(
    H1Label("Value Controls"),
    Slider(
        text="Angle (π over value)",
        trailing_text="[\$()]",
        min=2,
        max=16,
        value=8,
        variable="angle"
    ),  
    Slider(
        text="Count",
        trailing_text="[\$()]",
        min=1,
        max=30,
        value=16,
        variable="count"
    ),  
    H1Label("Static Image Example"),
    Image(
        source="\$(image)",
        # height="50%",
    ),        
    H1Label("Image Viewer allowing Pan (left-drag) and Zoom (wheel)"),
    PanZoom(
        style="width: 100%; height=400px;",
        content = Container(
            direction = "row warp",
            children = [
                Image(
                    source="\$(image)",
                ),        
            ]
        ),
    ),        

)
FlexUI.controls!(app, ui)


#---------------------------------------------------------------
# the render function
#---------------------------------------------------------------
function render()
    Luxor.Drawing(600, 400, :svg)
    Luxor.origin()
    Luxor.background("white")
    
    for θ in range(0, step=π/angle[], length=count[])
        Luxor.gsave()
        Luxor.scale(0.2)
        Luxor.rotate(θ)
        Luxor.translate(350, 0)
        Luxor.julialogo(action=:fill, bodycolor=Luxor.randomhue())
        Luxor.grestore()
    end
    
    Luxor.gsave()
    Luxor.scale(0.3)
    Luxor.juliacircles()
    Luxor.grestore()
    
    Luxor.translate(150, -150)
    Luxor.scale(0.3)
    Luxor.julialogo()
    Luxor.finish()
    

    image["svg"] = Luxor.preview()
end
renderFunction!(app, render)


#---------------------------------------------------------------
# Run the application
#---------------------------------------------------------------
run(app)

println("End [$(splitext(basename(@__FILE__))[1])]")

end # module
