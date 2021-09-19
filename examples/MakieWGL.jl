module Example

using Glimmer, Glimmer.FlexUI
using SparseArrays
using LinearAlgebra
using Makie
import WGLMakie, JSServe

println("Start [$(splitext(basename(@__FILE__))[1])]")

#---------------------------------------------------------------
# function to convert a WGLMakie scene to HTML
#---------------------------------------------------------------
function renderWGLMakieHTML(obj)
    io = IOBuffer()
    show(io, MIME"text/html"(), JSServe.Page(exportable=true, offline=true))
    app = JSServe.App() do
        return JSServe.DOM.div(
            obj,
        )
    end
    show(io, MIME"text/html"(), app)
    page_html = String(take!(io))
end

#---------------------------------------------------------------
# rendering the two figures
#---------------------------------------------------------------
WGLMakie.activate!()
Makie.inline!(true)

fig1 = WGLMakie.surface(rand(4, 4))

x, y = collect(-8:0.5:8), collect(-8:0.5:8)
z = [sinc(√(X^2 + Y^2) / π) for X ∈ x, Y ∈ y]

fig2 = wireframe(x, y, z, axis=(type=Axis3,), color=:black)



#---------------------------------------------------------------
# define the application and some basic properties such as title and initial window size
#---------------------------------------------------------------
app = App()
prop!(app, :title, "Glimmer Example - Makie with WGLMakie backend")
prop!(app, :winInitWidth, 1200)
prop!(app, :winInitHeight, 800)

#---------------------------------------------------------------
# Define Controls
#---------------------------------------------------------------
ui = VContainer(
    Card(
        title="This is an example of a WGLMakie scene",
        subtitle="WGLMakie allow us to embed an interactive Makie figure into any webpage. Note: Not every figure is interactive (see thge second one), but according to the developers, more and more will becode so in the future.",
        content=VContainer(
            Card(
                title="Interactive Figure (use mouse to rotate)",
                content=VContainer(
                    RawHTML(                                # Container for figure 1
                        html=renderWGLMakieHTML(fig1),
                        useFrame=true,
                        style="width: 100%; height: 650px;"
                    ),
                ),              
            ),
            Card(
                title="Non-Interactive Figure",
                content=VContainer(
                    RawHTML(
                        html=renderWGLMakieHTML(fig2),      # Container for figure 2
                        useFrame=true,
                        style="width: 100%; height: 650px;"
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
# the render function 
#---------------------------------------------------------------
function render()
end
renderFunction!(app, render)


#---------------------------------------------------------------
# Run the application
#---------------------------------------------------------------
run(app)

println("End [$(splitext(basename(@__FILE__))[1])]")

end # module
