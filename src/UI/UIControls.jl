
module UIControls

using ..Glimmer
import ..UIVariables
using Parameters
import UUIDs

#------------------------------------------------------------------------------
# EXports
#------------------------------------------------------------------------------
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
        MDJulia,

        CodeSnip,
        CodeSnipJulia,
        RawHTML,

        VContainer,
        HContainer,
        HContainerSpace,
        H1Label,
        H2Label,
        H3Label,
        H4Label,

        DummyExport
        



# mutable struct Slider <: UIControl
# end

# typedict(x) = Dict(fn=>getfield(x, fn) for fn ∈ fieldnames(typeof(x)))
typedict(x) = Dict(fn=>getfield(x, fn) for fn ∈ filter(x->!startswith(string(x), "_"), fieldnames(typeof(x))))

# function on(func::Function, control::AbstractUIControl)
#     control._func = func    
# end

# function asInt(control::AbstractUIControl)::Int
#     try
#         val = value(control)
#         @show val, typeof(val)
#         if (isa(val, String))
#             return Int(floor(parse(Float64, val)))
#         end
#         if (isa(val, Int64))
#             return val
#         end
#         if (isa(val, Float64))
#             return Int(floor(val))
#         end
#     catch
#         return 0
#     end
# end

# function asFloat(control::AbstractUIControl)::Int
#     try
#         val = value(control)
#         if (isa(val, String))
#             return parse(Float64, val)
#         end
#         if (isa(val, Int))
#             return convert(Float64, val)
#         end
#         if (isa(val, Float64))
#             return val
#         end
#         @error "should not reach here"
#     catch
#         return 0
#     end
# end

@with_kw mutable struct Container <: AbstractUIControl 
    type::String = "container"
    direction::String = "row"
    gap::String = "20px"
    align::String = "left left"
    children::Vector{UIControls.AbstractUIControl} = []

    _app::Union{Nothing, AbstractUIApp} = nothing
end

VContainer(args...) = Container(direction = "column", children=[args...])
HContainer(args...) = Container(direction = "row", align="left center",  children=[args...])
HContainerSpace(args...) = Container(direction = "row", align="space-between center",  children=[args...])
HContainerFill(args...) = Container(direction = "row", align="space-between center",  children=[args...])

"""
    Slider Control

Create a slider control.

```julia
    text::String = ""                   # text to apear to the left of the slider
    trailing_text::String = ""          # text to apear to the right of the slider
    min::Float64 = 0.0                  # minimum value
    max::Float64 = 100.0                # maximum value
    value::Float64 = 0                  # starting value (unused if connected to a variable)
    step::Float64 = 1.0                 # tick change value
    variable::Any = nothing             # variable
```    
"""
@with_kw mutable struct Slider <: AbstractUIControl 
    type::String = "slider"
    text::String = ""
    trailing_text::String = ""
    min::Float64 = 0.0
    max::Float64 = 100.0
    value::Float64 = 0
    step::Float64 = 1.0
    variable::Any = nothing

    _app::Union{Nothing, AbstractUIApp} = nothing
end
# value(c::Slider) = c.value

@with_kw mutable struct Button <: AbstractUIControl 
    type::String = "button"
    text::String = "default button"
    variable::Any = nothing
    buttonType::String = "raised"     # normal, raised, stroked, flat, icon, fab, mini-fab
    color::String = "primary"         # normal, primary, accent, warn, 
    fileTypes::String = ""            # used for an open file dialog, like ".png,.jpg"  

    _variable_name_to_create::String = ""
    _app::Union{Nothing, AbstractUIApp} = nothing
end
# value(c::Button) = c.text

function Button(text::String, var_name::String) 
    return Button(text=text, _variable_name_to_create=var_name)
end


@with_kw mutable struct MeshCatViewer <: AbstractUIControl 
    type::String = "meshcat-viewer"
    url::String = ""
    width::Any = "100%"
    height::Any = "600px"

    _app::Union{Nothing, AbstractUIApp} = nothing
end
# value(c::Button) = c.text

@with_kw mutable struct Label <: AbstractUIControl 
    type::String = "label"
    class::String = "normal"
    text::Any = ""
    style::Any = ""
    variable::Any = nothing
    isHTML::Bool = false

    _app::Union{Nothing, AbstractUIApp} = nothing
end

Label(text::String) = Label(text=text)
H1Label(text::String) = Label(text=text, class="h1")
H2Label(text::String) = Label(text=text, class="h2")
H3Label(text::String) = Label(text=text, class="h3")
H4Label(text::String) = Label(text=text, class="h4")

@with_kw mutable struct Image <: AbstractUIControl 
    type::String = "image"
    style::Any = ""
    source::Any = nothing

    _app::Union{Nothing, AbstractUIApp} = nothing
end

@with_kw mutable struct PanZoom <: AbstractUIControl 
    type::String = "pan-zoom"
    style::Any = "width: 100%; height: 300px;"
    innerStyle::Any = "width: auto; height: calc(100% - 30px);"
    content::Union{Nothing, UIControls.Container} = nothing

    _app::Union{Nothing, AbstractUIApp} = nothing
end

@with_kw mutable struct Field <: AbstractUIControl 
    type::String = "field"
    style::Any = ""
    input::String = "number"
    label::String = "default label"
    hint::String = "hint"
    options::Union{Nothing, Vector{Any}} = nothing
    variable::Any = nothing

    _func::Union{Nothing, Function} = nothing
end

@with_kw mutable struct ButtonToggle <: AbstractUIControl 
    type::String = "button-toggle"
    options::Union{Nothing, Vector{Any}} = nothing
    variable::Any = nothing

    _func::Union{Nothing, Function} = nothing
end

@with_kw mutable struct RadioGroup <: AbstractUIControl 
    type::String = "radio-group"
    direction::String = "horizontal"
    options::Union{Nothing, Vector{Any}} = nothing
    variable::Any = nothing

    _func::Union{Nothing, Function} = nothing
end

@with_kw mutable struct CheckBox <: AbstractUIControl 
    type::String = "checkbox"
    label::String = "default label"
    variable::Any = nothing

    _func::Union{Nothing, Function} = nothing
end

@with_kw mutable struct ExpansionPanel <: AbstractUIControl 
    type::String = "expansion-panel"
    title::String = "defaut title"
    subtitle::String = ""
    content::Union{Nothing, UIControls.Container} = nothing
    style::Any = ""
    titleStyle::String = ""
    subtitleStyle::String = ""
    headerStyle::Any = ""

    _app::Union{Nothing, AbstractUIApp} = nothing
end

@with_kw mutable struct Accordion <: AbstractUIControl 
    type::String = "accordion"
    panels::Union{Nothing, Vector{UIControls.ExpansionPanel}} = nothing

    _app::Union{Nothing, AbstractUIApp} = nothing
end


@with_kw mutable struct Tab <: AbstractUIControl 
    type::String = "tab"
    label::String = "default label"
    content::Union{Nothing, UIControls.Container} = nothing

    _app::Union{Nothing, AbstractUIApp} = nothing
end

@with_kw mutable struct Tabs <: AbstractUIControl 
    type::String = "tabs"
    style::Any = ""
    tabs::Union{Nothing, Vector{UIControls.Tab}} = nothing

    _app::Union{Nothing, AbstractUIApp} = nothing
end

@with_kw mutable struct Divider <: AbstractUIControl 
    type::String = "divider"

    _app::Union{Nothing, AbstractUIApp} = nothing
end

@with_kw mutable struct Card <: AbstractUIControl 
    type::String = "card"
    style::Any = ""
    title::String = ""
    titleVariable::Any = ""
    titleStyle::String = ""
    subtitle::String = ""
    subtitleVariable::Any = ""
    subtitleStyle::String = ""
    content::Union{String, UIControls.Container} = ""
    contentStyle::Any = ""
    variable::Any = ""                  # content source
    isHTML::Bool = false

    _app::Union{Nothing, AbstractUIApp} = nothing
end

@with_kw mutable struct Markdown <: AbstractUIControl 
    type::String = "markdown"
    style::Any = ""
    content::String = ""
    variable::Any = ""                  # content source
    lineNumbers::Bool = false

    _app::Union{Nothing, AbstractUIApp} = nothing
end

MDJulia(code) = Markdown(content = """```julia\n$(code)\n```""")

@with_kw mutable struct CodeSnip <: AbstractUIControl 
    type::String = "codesnip"
    text::String = ""
    language::String = "julia"
    lineNumbers::Bool = false
    commandLine::Bool = false
    prompt::String = "julia>"
    promptStyle::String = "-webkit-text-fill-color: rgb(51, 200, 51); -webkit-text-stroke-width:0.2px; -webkit-text-stroke-color: black;"
    rawLines::String = "2-999"

    _app::Union{Nothing, AbstractUIApp} = nothing
end

CodeSnipJulia(code) = CodeSnip(text=code, commandLine=true, prompt="julia>")


@with_kw mutable struct RawHTML <: AbstractUIControl 
    type::String = "raw-html"
    html::String = ""
    style::Any = "width: 100%; height: 400px;"
    useFrame::Bool = false

    _app::Union{Nothing, AbstractUIApp} = nothing
end


end # module UIControlsget