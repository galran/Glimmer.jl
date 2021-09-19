module Example

using Glimmer, Glimmer.FlexUI
import Luxor

println("Start [$(splitext(basename(@__FILE__))[1])]")

#---------------------------------------------------------------
# define the application and some basic properties such as title and initial window size
#---------------------------------------------------------------
app = App()
prop!(app, :title, "Glimmer Example - Luxor")
prop!(app, :winInitWidth, 1200)
prop!(app, :winInitHeight, 800)

#---------------------------------------------------------------
# Define Variables
#---------------------------------------------------------------
angle = addVariable!(app, Variable(name="angle", type="flota64",value=8))
count = addVariable!(app, Variable(name="count", type="flota64",value=16))

image = addVariable!(app, Variable(name="image", type="image", value="", ))

#---------------------------------------------------------------
# Define Controls
#---------------------------------------------------------------
ui = VContainer(
    Card(
        title="Controls",
        content=VContainer(
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
# the render function - preparing the image
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
    

    image["svg"] = Luxor.preview()      # updating the UI with the new image
end
renderFunction!(app, render)

#---------------------------------------------------------------
# Run the application
#---------------------------------------------------------------
run(app)

println("End [$(splitext(basename(@__FILE__))[1])]")

end # module
