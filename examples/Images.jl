module Example

using Glimmer, Glimmer.FlexUI
using Colors
using StaticArrays
using GeometryBasics
using Images, ImageSegmentation

println("Start [$(splitext(basename(@__FILE__))[1])]")

app = App()
prop!(app, :title, "Glimmer Example - Images")
prop!(app, :winInitWidth, 1200)
prop!(app, :winInitHeight, 800)


#---------------------------------------------------------------
# Define Variables
#---------------------------------------------------------------

filename = addVariable!(app, Variable(name="filename", type="string",value="C:/t/TestImages/horse.jpg"))
size = addVariable!(app, Variable(name="size", type="int",value=10))
details = addVariable!(app, Variable(name="details", type="string",value=10))

src_image = addVariable!(app, Variable(name="src_image", type="image", value=""))
dst_image = addVariable!(app, Variable(name="dst_image", type="image", value=""))

#---------------------------------------------------------------
# Define Controls
#---------------------------------------------------------------

ui = VContainer(
    H1Label("Segmantation Example"),
    HContainer(
        Button(
            text="Load a file",
            fileTypes=".png,.jpg",
            variable="filename",
        ),  
        Label(text="Current file [\$(filename)]"),
    ),
    Container(
        direction = "row warp",
        align = "space-between center",
        children = [
            Slider(
                text="Segments Size",
                trailing_text="[\$()]",
                min=2,
                max=100,
                value=8,
                variable="size"
            ),  
            Label(text="\$(details)"),
        ],
    ),
    H1Label("Image Viewer allowing Pan (left-drag) and Zoom (wheel)"),
    PanZoom(
        style="width: 100%; height: 60vh;  border: 1px solid black;",
        content = Container(
            direction = "row",
            children = [
                Card(
                    title="Source Image",
                    # style=card_style, 
                    content=VContainer(
                        Image(
                            source="\$(src_image)",
                        ),        
                    ),              
                ),
                Card(
                    title="Segmented Image",
                    # style=card_style, 
                    content=VContainer(
                        Image(
                            source="\$(dst_image)",
                        ),        
                    ),              
                ),
            ]
        ),
    ),        

)
FlexUI.controls!(app, ui)

#---------------------------------------------------------------
# load the image at the start and on name change
#---------------------------------------------------------------
src_img = nothing
function loadImage()
    @info "Loading Image [$(filename[])]"
    global src_img = load(filename[])
end

on(filename) do val
    loadImage()
end


#---------------------------------------------------------------
# the render function
#---------------------------------------------------------------
function processImages()
    global src_img

    segments = felzenszwalb(src_img, size[])
    dst_img = map(i->segment_mean(segments,i), labels_map(segments))
    src_image["png"] = src_img
    dst_image["png"] = dst_img
    details[] = "$segments"
end


function render()
    processImages();
end
renderFunction!(app, render)


#---------------------------------------------------------------
# Run the application
#---------------------------------------------------------------
loadImage()
run(app)

println("End [$(splitext(basename(@__FILE__))[1])]")

end # module
