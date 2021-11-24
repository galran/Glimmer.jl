module Glimmer

using Blink

using LinearAlgebra
import MeshCat
using CoordinateTransformations
using Rotations
import GeometryBasics
using Colors: RGBA, RGB
import Colors
import ColorSchemes
import FileIO
import MeshIO

import Tables
import JSON, JSONTables
import Dates
using OrderedCollections 

using StaticArrays
import UUIDs
import Base64

using Reexport


include("Misc.jl")
include("GridUtils.jl")
include("Material.jl")
include("SceneObject.jl")
include("Scene.jl")


include("JSInterface/JuliaJSBridge.jl")
include("UI/UIVariables.jl")
include("UI/UIControls.jl")
include("UI/WGL.jl")

include("UI/FlexUI.jl")

# reexport all the public stuff from UIControls and UIVariables

@reexport using ..UIControls
@reexport using ..UIVariables
@reexport using ..WGL
@reexport using ..GridUtils

        
#------------------------------------------------------------------------------
# Exports
#------------------------------------------------------------------------------
export  Scene,
        set_Y_up!,
        set_Z_up!,
        grid!,
        axes!,
        # root, root!,
        parent, parent!,
        material, material!,
        Material,
        transform, lookAt,
        rotation,
        local_tr, local_tr!,
        cameraTransform!, cameraPlanes!,
        EmptySceneObject,
        Box,
        Mesh,
        Arrow,
        Axes,
        LineSegments,
        PointCloud,
        dataPath,
        unitX3,
        unitY3,
        unitZ3,
        zero3,
        cameraTransform!,
        url,
        clear,
        send!,
        root, 
        root_transform,
        win,
        vis


export  BasicValidation, on, Variable

export  Container,
        Slider,
        Button,        
        MeshCatViewer,
        Label,
        Image,
        PanZoom,
        Field,
        ButtonToggle,
        RadioGroup,
        CheckBox,
        ExpansionPanel, 
        Accordion,
        Tabs,
        Tab,
        Divider,
        Card,
        Markdown,

        VContainer,
        HContainer,
        HContainerSpace,
        H1Label,
        H2Label,
        H3Label,
        H4Label


# export the common functions of a UI implementation
export addVariable!, prop, prop!, controls, controls!, renderFunction, renderFunction!

end # module Glimmer
