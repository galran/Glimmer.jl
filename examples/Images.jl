module Example

using Glimmer, Glimmer.FlexUI
using Images, ImageSegmentation

println("Start [$(splitext(basename(@__FILE__))[1])]")

#---------------------------------------------------------------
# define the application and some basic properties such as title and initial window size
#---------------------------------------------------------------
app = App()
prop!(app, :title, "Glimmer Example - Images")
prop!(app, :winInitWidth, 1200)
prop!(app, :winInitHeight, 800)

#---------------------------------------------------------------
# Define the Variables we will be using in this example
#---------------------------------------------------------------

# image file name
filename = addVariable!(app, Variable(name="filename", type="string",
        value=abspath(joinpath(dirname(pathof(Glimmer)), "Data", "horse.jpg"))))
# size of segments
size = addVariable!(app, Variable(name="size", type="int",value=10))
# contains the result of the segmentation 
details = addVariable!(app, Variable(name="details", type="string",value=10))
# source and destination images
src_image = addVariable!(app, Variable(name="src_image", type="image", value=""))
dst_image = addVariable!(app, Variable(name="dst_image", type="image", value=""))

#---------------------------------------------------------------
# Define the UI Controls
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
                trailingText="[\$()]",
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
    
    Glimmer.exampleSourceAsCard(@__FILE__),     # add the source code of the example as the last control

)
# set the controls for the application
controls!(app, ui)

#---------------------------------------------------------------
# utility function to load the current image from disk
#---------------------------------------------------------------
function loadImage()
    @info "Loading Image [$(filename[])]"
    global src_img = load(filename[])
end

#---------------------------------------------------------------
# define an event that will trigger when the vriable "filename" is changed
#---------------------------------------------------------------
on(filename) do val
    loadImage()
end

#---------------------------------------------------------------
# the render function will be caulled when any of the UI controls changes value
#---------------------------------------------------------------
src_img = nothing
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
# load the initial image and Run the application
#---------------------------------------------------------------
loadImage()
run(app)

println("End [$(splitext(basename(@__FILE__))[1])]")

end # module
