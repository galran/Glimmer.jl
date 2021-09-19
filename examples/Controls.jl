module Example

using Glimmer, Glimmer.FlexUI
using Colors
using StaticArrays

println("Start [$(splitext(basename(@__FILE__))[1])]")

# ---------------------------------------------------------------
# some default styles
# ---------------------------------------------------------------
card_style = "margin:0.2em; border: 1px solid lightgray!important; border-radius: 30px !important;"

expansion_panel_style = "margin:0.2em;"
expansion_panel_header_style = "" # "border: 1px solid lightgray!important;"
expansion_panel_subtitle_style = "position: absolute; padding-left: 30%;"

# ---------------------------------------------------------------
# utility functions
# ---------------------------------------------------------------
# returns the syntaxt and the result of an expression
function syntax(e::String)
    d = Meta.parse(e) 
    a = eval(d)
    
    # b = MDJulia(e)
    b = CodeSnip(text=e)
    return (a, b)
end

# returns a Card control 
function ExampleCard(e::String)
    return Card(
        style=card_style,
        content=VContainer(
            syntax(e)...,
        ),
    )
end
current_module = @__MODULE__

# ---------------------------------------------------------------
# Create the Application Object and the 3D viewer 
# ---------------------------------------------------------------
app = App()
prop!(app, :title, "Glimmer Example - Controls Gallery")

# scene = Scene(openWindow = false)
# set_Z_up!(scene)
# grid!(scene, false)
# cameraTransform!(scene, lookAt(SVector(0.0, 10.0, 200.0), zero3()))
# cameraPlanes!(scene, 0.1, 1000.0)

# ---------------------------------------------------------------
# Define Variables
# ---------------------------------------------------------------

labelText = addVariable!(app, Variable(name="labelText", type="string", value="This text comes from a variable"))
firstName = addVariable!(app, Variable(name="firstName", type="string", value=""))
height = addVariable!(app, Variable(name="height", type="flota64", value="176"))

option = addVariable!(app, Variable(name="option", type="string", value="Four"))

range1 = addVariable!(app, Variable(name="range1", type="flota64", value=0))
range2 = addVariable!(app, Variable(name="range2", type="flota64", value=0.5))

image1 = addVariable!(app, Variable(name="image1", type="image", value="https://julialang.org/assets/infra/onlinestats.gif"))

toggle1 = addVariable!(app, Variable(name="toggle1", type="bool", value=false))

option1 = addVariable!(app, Variable(name="option1", type="string", value="first"))


# ---------------------------------------------------------------
# Define Controls
# ---------------------------------------------------------------

ui = VContainer(
    # Markdown(
    #     content = "# Ran Gal\n## AAA\n",
    # ),
#     Markdown(
#         content = 
# raw"""

# ## Markdown __rulez__!
# ---

# ### Syntax highlight
# ## Syntax highlight
# # __Syntax__ highlight

# ```typescript
# const language = 'typescript';
# const language = 'typescript';
# const language = 'typescript';
# const language = 'typescript';
# ````

# ```julia
# a::Float64 = 1.0
# for i in 1:10
#     println("This is a string interpolation $i")
# end 
# @info "some info"     
# ```


# this is __some__ ~~normal~~ text
# Basic inline <abbr title="Hypertext Markup Language">HTML</abbr> may be supported.

# ### Lists
# 1. Ordered list with a [Link to google](http://www.google.com)
# 2. Another bullet point
#   - Unordered __list__
#   - Another unordered bullet point

# ### Blockquote
# > Blockquote to the max


# """,
#     ),

    Accordion(
        panels=[

            # Labels
            ExpansionPanel(
                title="Label",
                subtitle="labels are non-interactive elements used to display text",
                style=expansion_panel_style,
                headerStyle=expansion_panel_header_style,
                subtitleStyle=expansion_panel_subtitle_style,
                content=Container(
                    direction="row warp",
                    children=[
                        ExampleCard("""Label(text="A Normal Label")"""),
                        ExampleCard("""Label(text="Label with style", style="color: red;")"""),
                        ExampleCard("""Label(text="Label with style and class H1", class="h1", style="color: red;")"""),
                        ExampleCard("""Label(text="Label with style and class H2", class="h2", style="color: blue;")"""),
                        ExampleCard("""Label(text="Label with style and class H3", class="h3", style="background-color:rgb(255, 99, 71);")"""),
                        ExampleCard("""Label(text="Label with style and class H4", class="h4", style="background-color:#ff6347;")"""),
                        ExampleCard("""Label(text="Allow <u>HTML</u> tags in <span style='color:red;'>text.</span>", isHTML=true)"""),
                        Card(
                            style=card_style, 
                            content=VContainer(
                                syntax("""Label(variable="labelText", isHTML=true)""")...,
                                Label(text="""You can change the content of the label using the Julia REPL:"""),
                                CodeSnipJulia("""$(current_module).labelText[] = "This text is from Julia" """),
                                Label(text="""or even include HTML tags (isHTML=true)"""),
                                CodeSnipJulia("""$(current_module).labelText[] = "Do <span style='color:red;'>somthing</span> <b>BOLD</b>" """),

                            ),              
                        ),
                    ],
                ),
            ),


            # Fields
            ExpansionPanel(
                title="Field",
                subtitle="fields allow user input",
                style=expansion_panel_style,
                headerStyle=expansion_panel_header_style,
                subtitleStyle=expansion_panel_subtitle_style,
                content=Container(
                    direction="row warp",
                    children=[
                        Card(
                            title="String Field",
                            style=card_style,
                            content=VContainer(
                                syntax("""Field(
                                    input="text",
                                    label="First Name",
                                    hint="Please Enter your first name",
                                    variable="firstName",
                                )""")...,
                                Label(text="""You can change the content of the field using the Julia REPL:"""),
                                CodeSnipJulia("""$(current_module).firstName[] = "Robert" """),
                            ),              

                        ),

                        Card(
                            title="Numeric Field",
                            style=card_style,
                            content=VContainer(
                                syntax("""Field(
                                    input="number",
                                    label="Height",
                                    hint="in centimeters",
                                    variable="height",
                                )""")...,
                                Label(text="""You can change the content of the field using the Julia REPL:"""),
                                CodeSnipJulia("""$(current_module).height[] = 183.1"""),
                            ),              

                        ),

                        Card(
                            title="Combobox Field (options)",
                            style=card_style,
                            content=VContainer(
                                syntax("""Field(
                                    input="select",
                                    label="A Simple ComboBox",
                                    hint="Please select an option",
                                    variable="option",
                                    options=[
                                        Dict(:key => "One", :value => "First Option"),
                                        Dict(:key => "Two", :value => "Second Option"),
                                        Dict(:key => "Three", :value => "Third Option"),
                                        Dict(:key => "Four", :value => "Fourth Option"),
                                    ]
                                )""")...,
                                Label(text="""You can change the content of the field using the Julia REPL:"""),
                                CodeSnipJulia("""$(current_module).option[] = "Two" """),
                            ),              

                        ),


                    ],
                ),
            ),            

            # Sliders
            ExpansionPanel(
                title="Slider",
                subtitle="sliders allow range type update of values",
                style=expansion_panel_style,
                headerStyle=expansion_panel_header_style,
                subtitleStyle=expansion_panel_subtitle_style,
                content=Container(
                    direction="row warp",
                    children=[
                        Card(
                            title="Simple Slider",
                            style=card_style,
                            content=VContainer(
                                syntax("""Slider(
                                    min=0,
                                    max=100,
                                    value=10,
                                    variable="range1"
                                )""")...,
                                Label(text="""You can change the content of the field using the Julia REPL:"""),
                                CodeSnipJulia("""$(current_module).range1[] = 55 """),
                            ),              

                        ),

                        Card(
                            title="Slider with text and embedded value",
                            style=card_style,
                            content=VContainer(
                                syntax(raw"""Slider(
                                    text="Embedded Value [\$()]",
                                    trailing_text="[\$()cm]",
                                    min=0,
                                    max=100,
                                    value=10,
                                    variable="range1"
                                )""")...,
                                Label(text="""You can change the content of the field using the Julia REPL:"""),
                                CodeSnipJulia("""$(current_module).range1[] = 55 """),
                            ),              

                        ),

                        Card(
                            title="Step Size",
                            style=card_style,
                            content=VContainer(
                                syntax(raw"""Slider(
                                    text="Step Size",
                                    trailing_text="current value is \$()",
                                    min=0,
                                    max=1,
                                    value=0.5,
                                    step=0.01,
                                    variable="range2"
                                )""")...,
                                Label(text="""You can change the content of the field using the Julia REPL:"""),
                                CodeSnipJulia("""$(current_module).range2[] = 0.5 """),
                            ),              

                        ),


                    ],
                ),
            ),            

            # Buttons
            ExpansionPanel(
                title="Button",
                subtitle="buttons are activators that can run functions in the Julia backend",
                style=expansion_panel_style,
                headerStyle=expansion_panel_header_style,
                subtitleStyle=expansion_panel_subtitle_style,
                content=Container(
                    direction="row warp",
                    children=[
                        Card(
                            title="Simple Button",
                            style=card_style,
                            content=VContainer(
                                syntax("""HContainer(
                                    Button(
                                        text = "Basic",
                                    ),
                                    Button(
                                        text = "Primary",
                                        color = "primary",
                                    ),
                                    Button(
                                        text = "Accent",
                                        color = "accent",
                                    ),
                                    Button(
                                        text = "Warn",
                                        color = "warn",
                                    ),
                                )""")...,
                            ),              

                        ),

                        Card(
                            title="Raised Button",
                            style=card_style,
                            content=VContainer(
                                syntax("""HContainer(
                                    Button(
                                        text = "Basic",
                                        buttonType = "raised"
                                    ),
                                    Button(
                                        text = "Primary",
                                        color = "primary",
                                        buttonType = "raised"
                                    ),
                                    Button(
                                        text = "Accent",
                                        color = "accent",
                                        buttonType = "raised"
                                    ),
                                    Button(
                                        text = "Warn",
                                        color = "warn",
                                        buttonType = "raised"
                                    ),
                                )""")...,
                            ),              

                        ),

                        Card(
                            title="Stroked Button",
                            style=card_style,
                            content=VContainer(
                                syntax("""HContainer(
                                    Button(
                                        text = "Basic",
                                        buttonType = "stroked"
                                    ),
                                    Button(
                                        text = "Primary",
                                        color = "primary",
                                        buttonType = "stroked"
                                    ),
                                    Button(
                                        text = "Accent",
                                        color = "accent",
                                        buttonType = "stroked"
                                    ),
                                    Button(
                                        text = "Warn",
                                        color = "warn",
                                        buttonType = "stroked"
                                    ),
                                )""")...,
                            ),              

                        ),

                        Card(
                            title="Flat Button",
                            style=card_style,
                            content=VContainer(
                                syntax("""HContainer(
                                    Button(
                                        text = "Basic",
                                        buttonType = "flat"
                                    ),
                                    Button(
                                        text = "Primary",
                                        color = "primary",
                                        buttonType = "flat"
                                    ),
                                    Button(
                                        text = "Accent",
                                        color = "accent",
                                        buttonType = "flat"
                                    ),
                                    Button(
                                        text = "Warn",
                                        color = "warn",
                                        buttonType = "flat"
                                    ),
                                )""")...,
                            ),              

                        ),

                        Card(
                            title="Icon Button",
                            style=card_style,
                            content=VContainer(
                                syntax("""HContainer(
                                    Button(
                                        text = "more_vert",
                                        buttonType = "icon"
                                    ),
                                    Button(
                                        text = "home",
                                        color = "primary",
                                        buttonType = "icon"
                                    ),
                                    Button(
                                        text = "menu",
                                        color = "accent",
                                        buttonType = "icon"
                                    ),
                                    Button(
                                        text = "favorite",
                                        color = "warn",
                                        buttonType = "icon"
                                    ),
                                )""")...,
                            ),              

                        ),

                        Card(
                            title="FAB Button",
                            style=card_style,
                            content=VContainer(
                                syntax("""HContainer(
                                    Button(
                                        text = "delete",
                                        buttonType = "fab"
                                    ),
                                    Button(
                                        text = "bookmark",
                                        color = "primary",
                                        buttonType = "fab"
                                    ),
                                    Button(
                                        text = "home",
                                        color = "accent",
                                        buttonType = "fab"
                                    ),
                                    Button(
                                        text = "favorite",
                                        color = "warn",
                                        buttonType = "fab"
                                    ),
                                )""")...,
                            ),              

                        ),


                        Card(
                            title="Mini FAB Button",
                            style=card_style,
                            content=VContainer(
                                syntax("""HContainer(
                                    Button(
                                        text = "menu",
                                        buttonType = "mini-fab"
                                    ),
                                    Button(
                                        text = "plus_one",
                                        color = "primary",
                                        buttonType = "mini-fab"
                                    ),
                                    Button(
                                        text = "filter_list",
                                        color = "accent",
                                        buttonType = "mini-fab"
                                    ),
                                    Button(
                                        text = "dashboard",
                                        color = "warn",
                                        buttonType = "mini-fab"
                                    ),
                                )""")...,
                            ),              

                        ),

                        Card(
                            title="General",
                            style=card_style * "max-width: 400px",
                            content=VContainer(
                                Markdown(
                                    content="""
                                    For button types __icon__, __fab__ and __mini-fab__, the button text contains the icon name to be displayed.\n
                                    You can find the full list of available icons at:
                                    ```HTML
                                    https://fonts.google.com/icons
                                    ```
                                    
                                    """,
                                ),
                                Label(
                                    text="""<a href="https://fonts.google.com/icons" target="_blank">(link)</a>""",
                                    isHTML=true, 
                                ), 
                            ),              

                        ),
                        


                    ],
                ),
            ),            

            # Images and Pan-Zoom
            ExpansionPanel(
                title="Image and PanZoom",
                subtitle="controls for displaying images",
                style=expansion_panel_style,
                headerStyle=expansion_panel_header_style,
                subtitleStyle=expansion_panel_subtitle_style,
                content=Container(
                    direction="row warp",
                    children=[
                        Card(
                            title="Simple Image",
                            style=card_style,
                            content=VContainer(
                                syntax("""Image(
                                    source="https://julialang.org/assets/infra/waves.gif",
                                    style="width: 250px;"
                                )""")...,
                            ),              

                        ),

                        Card(
                            title="Image using a Variable source",
                            style=card_style,
                            content=VContainer(
                                syntax("""Image(
                                    source="\\\$(image1)",
                                    style="width: 250px;"
                                )""")...,
                                Label(text="""You can change the image source:"""),
                                CodeSnipJulia("""$(current_module).image1[] = "https://microsoft.github.io/OpticSim.jl/dev/assets/tele.png" """),
                                Label(text="""To a local file:"""),
                                CodeSnipJulia("""$(current_module).image1[] = "file://" * joinpath(dirname(pathof(Glimmer)), "data", "ExampleImage.png") """),
                                Label(text="""Or to an imaged created on the fly (note the type notation - png and svg are supported):"""),
                                CodeSnipJulia("""# using Makie
                                                 Makie.inline!(true)   
                                                 $(current_module).image1["png"] = Makie.scatter(rand(100)) """),
                            ),              

                        ),

                        Card(
                            title="PanZoom component that allow, well, pan and zoom duh!",
                            style=card_style * "max-width: 600px",
                            content=VContainer(
                                Label(
                                    text="(note: i'm still looking for a better image viewer component that handle the mouse wheel without scrolling the page. if you know of such a component, please let me know...)"
                                ),
                                syntax("""PanZoom(
                                    style="width: 100%; height: 400px",
                                    content = VContainer(
                                        Image(
                                            source="\\\$(image1)",
                                            # style="width: 250px;"
                                        ),
                                    ),
                                )""")...,
                            
                            ),              

                        ),


                    ],
                ),
            ),            

            # Checkboxes
            ExpansionPanel(
                title="CheckBox",
                subtitle="toggler",
                style=expansion_panel_style,
                headerStyle=expansion_panel_header_style,
                subtitleStyle=expansion_panel_subtitle_style,
                content=Container(
                    direction="row warp",
                    children=[
                        Card(
                            title="Simple checkbox",
                            style=card_style,
                            content=VContainer(
                                syntax("""CheckBox(
                                    label="Always save before closing",
                                    variable="toggle1",
                                )""")...,
                                Label(text="Adding a label to debug the toggle value:"),
                                syntax("""Label(
                                    text="Current value of toggle1 is [\\\$(toggle1)]",
                                )""")...,
                                Label(text="""You can update the toggle value from the REPL:"""),
                                CodeSnipJulia("""$(current_module).toggle1[] = true """),
                            ),              
                        ),
                    ],
                ),
            ),            

            # RadioGroup and ButtonToggle
            ExpansionPanel(
                title="RadioGroup and ButtonToggle",
                subtitle="option selectors",
                style=expansion_panel_style,
                headerStyle=expansion_panel_header_style,
                subtitleStyle=expansion_panel_subtitle_style,
                content=Container(
                    direction="row warp",
                    children=[
                        Card(
                            title="Horizontal Radio Group",
                            style=card_style,
                            content=VContainer(
                                syntax("""RadioGroup(
                                    variable="option1",
                                    direction="horizontal",
                                    options=[
                                        Dict(:key=>"first", :value=>"First Option"),
                                        Dict(:key=>"second", :value=>"Second Option"),
                                        Dict(:key=>"third", :value=>"Third Option"),
                                        Dict(:key=>"fourth", :value=>"Fourth Option")
                                    ]
                                )""")...,
                                Label(text="""You can update the toggle value from the REPL:"""),
                                CodeSnipJulia("""$(current_module).option1[] = "third" """),
                            ),              
                        ),

                        Card(
                            title="Vertical Radio Group",
                            style=card_style,
                            content=VContainer(
                                syntax("""RadioGroup(
                                    variable="option1",
                                    direction="vertical",
                                    options=[
                                        Dict(:key=>"first", :value=>"First Option"),
                                        Dict(:key=>"second", :value=>"Second Option"),
                                        Dict(:key=>"third", :value=>"Third Option"),
                                        Dict(:key=>"fourth", :value=>"Fourth Option")
                                    ]
                                )""")...,
                                Label(text="""You can update the toggle value from the REPL:"""),
                                CodeSnipJulia("""$(current_module).option1[] = "third" """),
                            ),              
                        ),

                        Card(
                            title="Button Toggle",
                            style=card_style,
                            content=VContainer(
                                syntax("""ButtonToggle(
                                    variable="option1",
                                    options = [
                                        Dict(:key=>"first", :value=>"First Option"),
                                        Dict(:key=>"second", :value=>"Second Option"),
                                        Dict(:key=>"third", :value=>"Third Option"),
                                        Dict(:key=>"fourth", :value=>"Fourth Option")
                                    ]
                                )""")...,
                                Label(text="""You can update the toggle value from the REPL:"""),
                                CodeSnipJulia("""$(current_module).option1[] = "third" """),
                            ),              
                        ),

                    ],
                ),
            ),            

            # ExpansionPanel and Accordion
            ExpansionPanel(
                title="ExpansionPanel and Accordion",
                subtitle="provides an expandable details-summary view",
                style=expansion_panel_style,
                headerStyle=expansion_panel_header_style,
                subtitleStyle=expansion_panel_subtitle_style,
                content=Container(
                    direction="row warp",
                    children=[
                        Card(
                            title="Expansion Panel",
                            style=card_style,
                            content=VContainer(
                                syntax("""ExpansionPanel(
                                    title = "Good Stuff",
                                    subtitle = "please press to expand",
                                    content = VContainer(       # vertical container
                                        Label(text="We are inside an expansion label now"),
                                        Label(text="The value of the checkbox below if [\\\$(toggle1)]"),
                                        CheckBox(
                                            label="Always save before closing",
                                            variable="toggle1",
                                        ),
                                        HContainer(
                                            Button(
                                                text = "Button1",
                                                color = "primary",
                                                buttonType = "raised"
                                            ),
                                            Button(
                                                text = "Button2",
                                                color = "primary",
                                                buttonType = "raised"
                                            ),
                                        )
                                    ),
                                )""")...,
                            ),              
                        ),


                        Card(
                            title="Accordion",
                            style=card_style,
                            content=VContainer(
                                syntax("""Accordion(
                                    panels = [
                                        ExpansionPanel(
                                            title="My First Expansion Panel",
                                            style=card_style,
                                            content = VContainer(
                                                H2Label("Inside the FIRST expansion panel"),
                                                H4Label("Try to expand other panels"),
                                            ),
                                        ),        

                                        ExpansionPanel(
                                            title="My First Expansion Panel",
                                            style=card_style,
                                            content = VContainer(
                                                H2Label("Inside the SECOND expansion panel"),
                                                H4Label("Try to expand other panels"),
                                            ),
                                        ),        

                                        ExpansionPanel(
                                            title="My First Expansion Panel",
                                            style=card_style,
                                            content = VContainer(
                                                H2Label("Inside the THIRD expansion panel"),
                                                H4Label("Try to expand other panels"),
                                            ),
                                        ),        
                                    ],
                                )""")...,
                            ),              
                        ),



                    ],
                ),
            ),            

            # Tabs
            ExpansionPanel(
                title="Tabs",
                subtitle="ganize content into separate views where only one view can be visible at a time",
                style=expansion_panel_style,
                headerStyle=expansion_panel_header_style,
                subtitleStyle=expansion_panel_subtitle_style,
                content=Container(
                    direction="row warp",
                    children=[
                        Card(
                            title="Tabs",
                            style=card_style,
                            content=VContainer(
            
                                syntax("""Tabs(
                                    style="min-height: 300px;",
                                    tabs=[
                                        Tab(                        # First Tab Definition    
                                            label="First Tab",
                                            content=VContainer(
                                                Image(
                                                    source="https://julialang.org/assets/infra/waves.gif",
                                                    style="width: 350px;"
                                                ),        
                                                Button(
                                                    text="Just a button",
                                                ),        
                                            ),
                                        ),
                                        Tab(                        # Second Tab Definition
                                            label="Second Tab",
                                            content=HContainer(
                                                Image(
                                                    source="\\\$(image1)",
                                                    style="width: 350px;"
                                                ),        
                                                Button(
                                                    text="Just a button",
                                                ),        
                                            ),
                                        ),

                                        Tab(                        # Third Tab Definition
                                            label="Third Tab",
                                            content=VContainer(
                                                ExpansionPanel(
                                                    title = "Good Stuff",
                                                    subtitle = "please press to expand",
                                                    style=card_style,
                                                    content = VContainer(       # vertical container
                                                        Label(text="We are inside an expansion label now"),
                                                        Label(text="The value of the checkbox below if [\\\$(toggle1)]"),
                                                        CheckBox(
                                                            label="Always save before closing",
                                                            variable="toggle1",
                                                        ),
                                                        HContainer(
                                                            Button(
                                                                text = "Button1",
                                                                color = "primary",
                                                                buttonType = "raised"
                                                            ),
                                                            Button(
                                                                text = "Button2",
                                                                color = "primary",
                                                                buttonType = "raised"
                                                            ),
                                                        )
                                                    ),
                                                )                                                
                                            ),
                                        ),
                                        
                                    ],
                                )""")...,
                            ),              
                        ),



                    ],
                ),
            ),            

            # Markdown
            ExpansionPanel(
                title="Markdown and CodeSnip",
                subtitle="support a basic implementation of the markdown language",
                style=expansion_panel_style,
                headerStyle=expansion_panel_header_style,
                subtitleStyle=expansion_panel_subtitle_style,
                content=Container(
                    direction="row warp",
                    children=[
                        Card(
                            style=card_style,
                            content=VContainer(
                                # Markdown(
                                #     content = 
                                #         raw"""
                                #         ## Markdown __rulez__!
                                #         ---

                                #         # __Syntax__ highlight
                                #         ## Syntax highlight
                                #         ### Syntax highlight

                                #         ## inline code blocks in typescript and Julia with highlights
                                #         ```typescript
                                #         const language = 'typescript';
                                #         const language = 'typescript';
                                #         ````

                                #         ```julia
                                #         a::Float64 = 1.0
                                #         for i in 1:10
                                #             println("String interpolation $i")
                                #         end 
                                #         @info "Blah Blah" a
                                #         ```

                                #         This is __some__ ~~normal~~ text.

                                #         Basic inline <abbr title="Hypertext Markup Language">HTML</abbr> may be supported.

                                #         ### Lists
                                #         1. Ordered list with a [Link](https://github.com/galran/Glimmer.jl) - you won't be able to go back to this page
                                #         2. Another bullet point
                                #         - Unordered __list__
                                #         - Another unordered bullet point

                                #         ### Blockquote
                                #         > Blockquote to the max
                                #         """,
                                # ),

                                syntax("""Markdown(
                                        content=
                                            "
                                            ## Markdown __rulez__!
                                            ---

                                            # __Syntax__ highlight
                                            ## Syntax highlight
                                            ### Syntax highlight

                                            ## inline code blocks in typescript and Julia with highlights
                                            ```typescript
                                            const language = 'typescript';
                                            const language = 'typescript';
                                            ````

                                            ```julia
                                            length::Float64 = 1.0
                                            for i in 1:10
                                                println(i)
                                            end 
                                            @info length
                                            ```

                                            This is __some__ ~~normal~~ text.

                                            Basic inline <abbr>HTML</abbr> may be supported.

                                            ### Lists
                                            1. Ordered list with a [Link](https://github.com/galran/Glimmer.jl). 
                                            __NOTE__: You won't be able to go back to this page
                                            2. Another bullet point

                                            - Unordered __list__
                                            - Another unordered bullet point

                                            ### Blockquote
                                            > Blockquote to the max
                                            ")""")...,
                                

                            ),              
                        ),

                        Card(
                            title="CodeSnip",
                            style=card_style,
                            content=VContainer(
                                H3Label("CodeSnip allow more control over the code block, such as adding line numbers:"),
                                syntax("""CodeSnip(
                                    lineNumbers=true,
                                    text=
                                        "function mandelbrot(a)
                                            z = 0
                                            for i=1:50
                                                z = z^2 + a
                                            end
                                            return z
                                        end

                                        for y=1.0:-0.05:-1.0
                                            for x=-2.0:0.0315:0.5
                                                abs(mandelbrot(complex(x, y))) < 2 ? print('*') : print(' ')
                                            end
                                            println()
                                        end",
                                )""")...,
                                H3Label("or adding a command prompt for all or some lines"),
                                syntax("""CodeSnip(
                                    commandLine=true,
                                    rawLines="",
                                    prompt="julia>",
                                    text="angle = π / 2.1
                                    halfAngle = angle / 2.0
                                    println(halfAngle)",
                                    )""")...,

                                    syntax("""CodeSnip(
                                        commandLine=true,
                                        rawLines="2-999",
                                        prompt="julia>",
                                        text="angle = π / 2.1
                                        halfAngle = angle / 2.0
                                        println(halfAngle)",
                                        )""")...,
    
                            ),              
                        ),
                
                    ],
                ),
            ),            
            
        ],
    ),

)
# set the controls for the application
controls!(app, ui)

# ---------------------------------------------------------------
# Run the application
# ---------------------------------------------------------------
run(app)

println("End [$(splitext(basename(@__FILE__))[1])]")

end # module