module Example

using Glimmer, Glimmer.FlexUI
using Colors
using StaticArrays
import Markdown as MD

println("Start [$(splitext(basename(@__FILE__))[1])]")

# ---------------------------------------------------------------
# some default styles
# ---------------------------------------------------------------
card_style = "margin:0.2em; border: 1px solid lightgray!important; border-radius: 30px !important;"
highlight_color_style = "background-color: #D1F2EB;"


expansion_panel_style = "margin:0.2em;"
expansion_panel_style = "margin:0.4em; border: 0.5px solid lightgray!important; border-radius: 10px !important;"
expansion_panel_header_style = "font-weight: bold;" # "border: 1px solid lightgray!important;"
expansion_panel_subtitle_style = "position: absolute; padding-left: 30%;"

# ---------------------------------------------------------------
# prepare some data for the grids
# ---------------------------------------------------------------
mlb_data_json = "[{\"Name\":\"Adam Donachie\",\"Team\":\"ANA\",\"Position\":\"Catcher\",\"Height(inches)\":74,\"Weight(lbs)\":180,\"Age\":22.99},{\"Name\":\"Paul Bako\",\"Team\":\"SEA\",\"Position\":\"Catcher\",\"Height(inches)\":74,\"Weight(lbs)\":215,\"Age\":34.69},{\"Name\":\"Ramon Hernandez\",\"Team\":\"BOS\",\"Position\":\"Catcher\",\"Height(inches)\":72,\"Weight(lbs)\":210,\"Age\":30.78},{\"Name\":\"Kevin Millar\",\"Team\":\"BAL\",\"Position\":\"First Baseman\",\"Height(inches)\":72,\"Weight(lbs)\":210,\"Age\":35.43},{\"Name\":\"Chris Gomez\",\"Team\":\"BAL\",\"Position\":\"First Baseman\",\"Height(inches)\":73,\"Weight(lbs)\":188,\"Age\":35.71},{\"Name\":\"Brian Roberts\",\"Team\":\"BAL\",\"Position\":\"Second Baseman\",\"Height(inches)\":69,\"Weight(lbs)\":176,\"Age\":29.39},{\"Name\":\"Miguel Tejada\",\"Team\":\"BAL\",\"Position\":\"Shortstop\",\"Height(inches)\":69,\"Weight(lbs)\":209,\"Age\":30.77},{\"Name\":\"Melvin Mora\",\"Team\":\"BAL\",\"Position\":\"Third Baseman\",\"Height(inches)\":71,\"Weight(lbs)\":200,\"Age\":35.07},{\"Name\":\"Aubrey Huff\",\"Team\":\"BAL\",\"Position\":\"Third Baseman\",\"Height(inches)\":76,\"Weight(lbs)\":231,\"Age\":30.19},{\"Name\":\"Adam Stern\",\"Team\":\"BAL\",\"Position\":\"Outfielder\",\"Height(inches)\":71,\"Weight(lbs)\":180,\"Age\":27.05},{\"Name\":\"Jeff Fiorentino\",\"Team\":\"BAL\",\"Position\":\"Outfielder\",\"Height(inches)\":73,\"Weight(lbs)\":188,\"Age\":23.88},{\"Name\":\"Freddie Bynum\",\"Team\":\"BAL\",\"Position\":\"Outfielder\",\"Height(inches)\":73,\"Weight(lbs)\":180,\"Age\":26.96},{\"Name\":\"Nick Markakis\",\"Team\":\"BAL\",\"Position\":\"Outfielder\",\"Height(inches)\":74,\"Weight(lbs)\":185,\"Age\":23.29},{\"Name\":\"Brandon Fahey\",\"Team\":\"BAL\",\"Position\":\"Outfielder\",\"Height(inches)\":74,\"Weight(lbs)\":160,\"Age\":26.11},{\"Name\":\"Corey Patterson\",\"Team\":\"BAL\",\"Position\":\"Outfielder\",\"Height(inches)\":69,\"Weight(lbs)\":180,\"Age\":27.55},{\"Name\":\"Jay Payton\",\"Team\":\"BAL\",\"Position\":\"Outfielder\",\"Height(inches)\":70,\"Weight(lbs)\":185,\"Age\":34.27},{\"Name\":\"Jay Gibbons\",\"Team\":\"BAL\",\"Position\":\"Designated Hitter\",\"Height(inches)\":72,\"Weight(lbs)\":197,\"Age\":30.0},{\"Name\":\"Erik Bedard\",\"Team\":\"BAL\",\"Position\":\"Starting Pitcher\",\"Height(inches)\":73,\"Weight(lbs)\":189,\"Age\":27.99},{\"Name\":\"Hayden Penn\",\"Team\":\"BAL\",\"Position\":\"Starting Pitcher\",\"Height(inches)\":75,\"Weight(lbs)\":185,\"Age\":22.38},{\"Name\":\"Adam Loewen\",\"Team\":\"BAL\",\"Position\":\"Starting Pitcher\",\"Height(inches)\":78,\"Weight(lbs)\":219,\"Age\":22.89}]"
mlb_data_table = GridUtils.toJSONTable(mlb_data_json)

countries_data_json = "[{\"Population\":\"30M\",\"ParentID\":-1,\"Type\":\"Country\",\"Name\":\"USA\",\"ID\":1},{\"Population\":\"250K \",\"ParentID\":1,\"Type\":\"City\",\"Name\":\"Seattle\",\"ID\":2},{\"Population\":\"600K \",\"ParentID\":1,\"Type\":\"City\",\"Name\":\"Boston\",\"ID\":3},{\"Population\":\"2M \",\"ParentID\":1,\"Type\":\"City\",\"Name\":\"New-York\",\"ID\":4},{\"Population\":\"250 people \",\"ParentID\":1,\"Type\":\"City\",\"Name\":\"Redmond\",\"ID\":5},{\"Population\":\"3 on week days\",\"ParentID\":5,\"Type\":\"Place\",\"Name\":\"City Center\",\"ID\":6},{\"Population\":\"0.5 during covid\",\"ParentID\":5,\"Type\":\"Place\",\"Name\":\"MS Campus\",\"ID\":7},{\"Population\":\"35M 24/7\",\"ParentID\":5,\"Type\":\"Place\",\"Name\":\"River Trail\",\"ID\":8},{\"Population\":\"20M\",\"ParentID\":-1,\"Type\":\"Country\",\"Name\":\"Canada\",\"ID\":9},{\"Population\":\"1.7M\",\"ParentID\":9,\"Type\":\"City\",\"Name\":\"Montreal\",\"ID\":10},{\"Population\":\"3M\",\"ParentID\":9,\"Type\":\"City\",\"Name\":\"Toronto\",\"ID\":11},{\"Population\":\"630K\",\"ParentID\":9,\"Type\":\"City\",\"Name\":\"Vancouver\",\"ID\":12},{\"Population\":\"25M\",\"ParentID\":-1,\"Type\":\"Country\",\"Name\":\"Mexico\",\"ID\":13},{\"Population\":\"9.2M\",\"ParentID\":13,\"Type\":\"City\",\"Name\":\"Mexico City\",\"ID\":14},{\"Population\":\"1.5M\",\"ParentID\":13,\"Type\":\"City\",\"Name\":\"Guadalajara\",\"ID\":15},{\"Population\":\"890K\",\"ParentID\":13,\"Type\":\"City\",\"Name\":\"Cancún\",\"ID\":16}]"
countries_data_table = GridUtils.toJSONTable(countries_data_json)

loremText = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Nec ullamcorper sit amet risus nullam. Sagittis eu volutpat odio facilisis mauris sit amet massa vitae."

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

# prepare the grid tabel
table_label = addVariable!(app, Variable(name="table_label", type="string", value="press the button to see row details"))
table_var = addVariable!(app, Variable(name="table_var", type="aggrid", value=""))

# setup the grid data and options - will get friendlier in the near future
table_var[] = GridUtils.table2agGrid(mlb_data_table) 

# setting some grid options - because of it's complexity, the grid's data and visualization properties 
# are all stored in the variable and not the UI control.
gridOption!(table_var, "rowSelection", "single")

# insert a row field
insertGridColumn!(table_var, 1, gridRowIndexCell(
    header="Row", 
    width=70, 
    cellStyle = Dict(
        "color" => "yellow",
        "background-color" => "pink",
    ),
))

# insert a combobox field in addition to the non-combobox Team field. you can edit either.
replaceGridColumn!(table_var, 3, gridSelectCell(
    header="Teams Combobox", 
    field="Team",
    selectOptions=[
        Dict(:key=>"BAL", :value=>"Baltimore Orioles"),
        Dict(:key=>"CWS", :value=>"College World Series"),
        Dict(:key=>"ANA", :value=>"Los Angeles Angels"),
        Dict(:key=>"BOS", :value=>"Boston Red Sox"),
        Dict(:key=>"CLE", :value=>"Cleveland Indians"),
        Dict(:key=>"OAK", :value=>"Oakland Athletics"),
        Dict(:key=>"NYY", :value=>"New York Yankees"),
        Dict(:key=>"DET", :value=>"Detroit Tigers"),
        Dict(:key=>"SEA", :value=>"Seattle Mariners"),
        Dict(:key=>"TB", :value=>"Tampa Bay Rays"),
        Dict(:key=>"KC", :value=>"Kansas City Royals"),
        Dict(:key=>"TEX", :value=>"Texas Rangers"),
        
    ]
))

# insert a button column and defining the event for it. further down we write a function to handle that event per row.
insertGridColumn!(table_var, 4, gridButtonCell(
    header="Example Button", 
    eventName="myButtonClicked",
    buttonText="Show Details",
))

# define the column default values (note the cellStyle to color a line red according to documantation existance)
gridDefaultColDef!(table_var, gridCell(
    editable=true, 
    resizable=true,
    # filter = "agTextColumnFilter",
    # floatingFilter = true,
    # cellStyle="__js__ params => params.data.hasDocs==false ? { color: 'red' } : { color: 'green' }",
))

# prepare the countries table grid
table_var2 = addVariable!(app, Variable(name="table_var2", type="aggrid", value=""))

# setup the grid data and options - will get friendlier in the near future
# for tree type tables, we need to supply the name of the "id" firld and the "parent" field.
table_var2[] = GridUtils.table2agGridTree(countries_data_table, "ID", "ParentID") 

# setting some grid options - because of it's complexity, the grid's data and visualization properties 
# are all stored in the variable and not the UI control.
gridOption!(table_var2, "rowSelection", "single")
gridOption!(table_var2, "showRowIndex", true)
gridOption!(table_var2, "treeViewIndentPixels", 30)
gridOption!(table_var2, "suppressScrollOnNewData", true)
gridOption!(table_var2, "showTreeViewFilter", true)

clearGridColumns!(table_var2)
addGridColumn!(table_var2, gridTreeViewCell(header="Name", field="Name", width=250))
addGridColumn!(table_var2, gridCell(header="Type", field="Type"))
addGridColumn!(table_var2, gridCell(header="Population", field="Population"))

# define the column default values (note the cellStyle to color a line red according to documantation existance)
gridDefaultColDef!(table_var2, gridCell(
    editable=false, 
    resizable=true,
    width=150,
    # cellStyle="__js__ params => params.data.hasDocs==false ? { color: 'red' } : { color: 'green' }",
))


# ---------------------------------------------------------------
# Define Events Handlers
# ---------------------------------------------------------------
on(table_var, :myButtonClicked) do val
    # @info """Button Clicked: name=[$(val["data"]["Name"])]"""
    data = val["data"]
    table_label[] = """[$(data["Name"])] is a [$(data["Name"])], [$(data["Age"]) years old)]"""
end


# ---------------------------------------------------------------
# Define Controls
# ---------------------------------------------------------------

ui = VContainer(
    Card(
        # title="Information",
        style=card_style * highlight_color_style,
        content=UIControls.HContainerCenter(
            Label(
                text = "This example shows most of the Glimmer.jl UI controls in an interactive format.",
                style = "font-weight: bold; font-size:24px; align: center;",
            ),
        ),              
    ),
    Accordion(
        panels=[

            # Labels
            ExpansionPanel(
                title="Label",
                subtitle="labels are non-interactive elements used to display text",
                style=expansion_panel_style,
                titleStyle=expansion_panel_header_style,
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
                titleStyle=expansion_panel_header_style,
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
                                    label="A basic ComboBox",
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
                titleStyle=expansion_panel_header_style,
                subtitleStyle=expansion_panel_subtitle_style,
                content=Container(
                    direction="row warp",
                    children=[
                        Card(
                            title="Basic Slider",
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
                                    trailingText="[\$()cm]",
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
                                    trailingText="current value is \$()",
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
                titleStyle=expansion_panel_header_style,
                subtitleStyle=expansion_panel_subtitle_style,
                content=Container(
                    direction="row warp",
                    children=[
                        Card(
                            title="Basic Button",
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
                titleStyle=expansion_panel_header_style,
                subtitleStyle=expansion_panel_subtitle_style,
                content=Container(
                    direction="row warp",
                    children=[
                        Card(
                            title="Basic Image",
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

            # Checkboxes and SlideToggle
            ExpansionPanel(
                title="CheckBox and SlideToggle",
                subtitle="togglers",
                style=expansion_panel_style,
                titleStyle=expansion_panel_header_style,
                subtitleStyle=expansion_panel_subtitle_style,
                content=Container(
                    direction="row warp",
                    children=[
                        Card(
                            title="Basic CheckBox",
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
                        Card(
                            title="Basic SlideToggle",
                            style=card_style,
                            content=VContainer(
                                syntax("""SlideToggle(
                                    text = "Sample Text Before Toggle",
                                    trailingText = "Sample Text After Toggle",
                                    color = "primary",
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
                titleStyle=expansion_panel_header_style,
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
                titleStyle=expansion_panel_header_style,
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
                titleStyle=expansion_panel_header_style,
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
                titleStyle=expansion_panel_header_style,
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

            # Grid
            ExpansionPanel(
                title="Grid",
                subtitle="editing tabular and hierarchical data",
                style=expansion_panel_style,
                titleStyle=expansion_panel_header_style,
                subtitleStyle=expansion_panel_subtitle_style,
                content=Container(
                    direction="row warp",
                    children=[
                        Card(
                            title="Basic Grid with a Combobox and Button examples",
                            style=card_style,
                            content=VContainer(
                                AGGrid(
                                    style="width: 600px; height: 500px;",
                                    variable="table_var",
                                ),
                                Label(variable="table_label"),
                                
                                Divider(),

                                Label(text="To see how to define the grid properties please take a look in the example code."),
                            ),              
                        ),

                        Card(
                            title="Grid with Tree/hierarchy support",
                            style=card_style,
                            content=VContainer(
                                AGGrid(
                                    style="width: 600px; height: 500px;",
                                    variable="table_var2",
                                ),
                                
                                Divider(),

                                Label(text="To see how to define the grid properties please take a look in the example code."),
                            ),              
                        ),

                    ],
                ),
            ),            
            
            # Splitter
            ExpansionPanel(
                title="Splitter",
                subtitle="split views and allow dragging to resize areas",
                style=expansion_panel_style,
                titleStyle=expansion_panel_header_style,
                subtitleStyle=expansion_panel_subtitle_style,
                content=Container(
                    direction="row warp",
                    children=[
                        Card(
                            title="Basic example of horizontal and vertical splitters",
                            style=card_style,
                            content=VContainer(
                                syntax("""Splitter(
                                    units = "percent",
                                    direction = "horizontal",
                                    style= "width: 100%; height: 500px;",
                                    areas = [
                                        SplitterArea(
                                            size = "30",
                                            minSize=10,
                                            content = VContainer(
                                                Card(
                                                    title="Nested Splitters",
                                                    subtitle="A Card inside a aplitter area containing a vertical splitter",
                                                    style=card_style,
                                                    content=VContainer(
                                                        Splitter(
                                                            units = "pixel",
                                                            direction = "vertical",
                                                            style= "width: 100%; height: 350px;",
                                                            areas = [
                                                                SplitterArea(
                                                                    size = "*",
                                                                    content = VContainer(
                                                                        Label(text=loremText),
                                                                    ),    
                                                                ),
                                                                SplitterArea(
                                                                    size = "100",
                                                                    minSize=50,
                                                                    content = VContainer(
                                                                        Label(text=loremText),
                                                                    ),    
                                                                ),
                                                                SplitterArea(
                                                                    size = "100",
                                                                    minSize=50,
                                                                    content = VContainer(
                                                                        Label(text=loremText),
                                                                    ),    
                                                                ),
                                                            ],
                                                        ),
                                                    ),              
                                                ),
                                            ),    
                                        ),
                                        SplitterArea(
                                            size = "40",
                                            minSize=10,
                                            content = VContainer(
                                                Label(text="We are inside a splitter area"),
                                                Label(text="The value of the checkbox below if [\\\$(toggle1)]"),
                                                CheckBox(
                                                    label="Always save before closing",
                                                    variable="toggle1",
                                                ),
                                                HContainer(
                                                    Button(text = "Button1", color = "primary", buttonType = "raised"),
                                                    Button(text = "Button2", color = "primary", buttonType = "raised"),
                                                )
                                            ),    
                                        ),
                                        SplitterArea(
                                            size = "30",
                                            minSize=10,
                                            content = VContainer(
                                                Label(text="Another splitter area"),
                                                Slider(
                                                    text="Value ",
                                                    trailingText="[\\\$()cm]",
                                                    min=0, max=100, value=10, variable="range1"
                                                )                                                
                                            ),    
                                        )

                                    ],
                                )""")...,
                            ),              
                        ),
                    ],
                ),
            ),  
            
            # RawHTML
            ExpansionPanel(
                title="RawHTML",
                subtitle="allowing hosting of HTML rendered content inside the application",
                style=expansion_panel_style,
                titleStyle=expansion_panel_header_style,
                subtitleStyle=expansion_panel_subtitle_style,
                content=Container(
                    direction="row warp",
                    children=[
                        Card(
                            title="Techinal Details",
                            style=card_style * highlight_color_style,
                            # contentStyle="background-color: pink;",
                            content=VContainer(
                                Label(text="""The Glimmer package UI is an Angular application (a framework for building web applications)  
                                              running inside a Blink window.  The UI controls that are supported by Glimmer are mostly Angular 
                                              compatible components. However, sometimes you might find the need to host a pure html content 
                                              inside the Glimmer UI. An example would be a Julia package that renders HTML, such as WGLMakie.jl 
                                              or TableView.jl.""",
                                ),
                                Label(text="""Is such cases, you will need to use the RawHTML control. This control allows you to inject pure 
                                              HTML to the angular scope or use an IFRAME html tag to treat it as an isolated island 
                                              (useFrame = true or false). """,
                                ),
                            ),              
                        ),

                        Card(
                            title="RawHTML inject an iframe tag",
                            style=card_style,
                            content=VContainer(
                                syntax("""RawHTML(
                                    html="<iframe id='inlineFrameExample'
                                                title='Inline Frame Example'
                                                width='100%'
                                                height='300'
                                                src='https://www.openstreetmap.org/export/embed.html?bbox=-0.004017949104309083%2C51.47612752641776%2C0.00030577182769775396%2C51.478569861898606&layer=mapnik'>
                                            </iframe>
                                        ",
                                    style = "width: 100%; height: 100%;",
                                )""")...,
                            ),              
                        ),


                        Card(
                            title="RawHTML inject an iframe tag",
                            style=card_style,
                            content=VContainer(
                                syntax("""RawHTML(
                                    html="<iframe width='560' height='415' 
                                           src='https://www.youtube.com/embed/owsfdh4gxyc' 
                                           frameborder='0' allowfullscreen></iframe>",
                                )""")...,
                            ),              
                        ),

                        Card(
                            title="RawHTML display an entire html page in a frame",
                            style=card_style,
                            content=VContainer(
                                syntax("""RawHTML(
                                    html="<!DOCTYPE html>
                                    <html>
                                    <body>
                                        <h1>My First Heading</h1>
                                    
                                        <p>\$(loremText).</p>
                                    </body>
                                    </html>",
                                    style = "width: 100%; height: 300%;",
                                    useFrame = true,
                                )""")...,
                            ),              
                        ),
                        
                        Card(
                            title="RawHTML result of rendering a Julia object's HTML",
                            subtitle="Convert a Julia markdown string to it's HTML representation",
                            style=card_style,
                            content=VContainer(
                                syntax("""RawHTML(
                                    html=renderHTML(MD.md\"\"\"# Level One
                                                            ## Level Two
                                                            ### Level Three
                                                            #### Level Four
                                                            ##### Level Five
                                                            ###### Level Six\"\"\" ),
                                    style = "width: 100%; height: 300%;",
                                    useFrame = true,
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