module Example

using Glimmer, Glimmer.FlexUI
using DataFrames, CSV

println("Start [$(splitext(basename(@__FILE__))[1])]")

# ---------------------------------------------------------------
# define the application and some basic properties such as title and initial window size
# ---------------------------------------------------------------
app = App()
prop!(app, :title, "Glimmer Example - Grid Simple Table")
prop!(app, :winInitWidth, 1200)
prop!(app, :winInitHeight, 800)

# ---------------------------------------------------------------
# load the data
# ---------------------------------------------------------------
filename = joinpath(dirname(pathof(Glimmer)), "Data", "mlb_players.csv");
csv = CSV.File(filename)
table = DataFrame(csv)

# ---------------------------------------------------------------
# Define Variables
# ---------------------------------------------------------------
table_var = addVariable!(app, Variable(name="table_var", type="aggrid", value=""))

# setup the grid data and options - will get friendlier in the near future
table_var[] = GridUtils.table2agGrid(table) 

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
insertGridColumn!(table_var, 4, gridSelectCell(
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
insertGridColumn!(table_var, 5, gridButtonCell(
    header="Name in REPL", 
    eventName="myButtonClicked",
))

# define the column default values (note the cellStyle to color a line red according to documantation existance)
gridDefaultColDef!(table_var, gridCell(
    editable=true, 
    resizable=true,
    # filter = "agTextColumnFilter",
    # floatingFilter = true,
    # cellStyle="__js__ params => params.data.hasDocs==false ? { color: 'red' } : { color: 'green' }",
))



# ---------------------------------------------------------------
# Define Events
# ---------------------------------------------------------------
# see https://www.ag-grid.com/angular-data-grid/grid-events/ for details

# this is an example of how to convert the grid variable back into a table - not used in this example
on(table_var, :valueChanged) do val
    @show "ON valueChanged" 
    # new_table = table_var[];
    # @show new_table
end

on(table_var, :myButtonClicked) do val
    # @show "ON myButtonClicked" 
    @info """Button Clicked: name=[$(val["data"]["Name"])]"""
end

on(table_var, :cellClicked) do val
    @show "ON cellClicked" 
end

on(table_var, :cellDoubleClicked) do val
    @show "ON cellDoubleClicked" 
end

on(table_var, :rowSelected) do val
    @show "ON rowSelected" 
end

# when selection changed we update the documentation display for the new selected type
on(table_var, :selectionChanged) do val
    @show "ON selectionChanged" 
end

# example - will use in the future
on(table_var, :myGridButtonEvent) do val
    @show "ON myGridButtonEvent" val
end


# ---------------------------------------------------------------
# Define Controls
# ---------------------------------------------------------------
ui = VContainer(
    Card(
        title="This Example demonstrate some the the AGGrid component capabilities",
        subtitle="This is a simple grid showing data loader from a CSV file. Also show an example of a combobox and a user defined button. Grid allow filtering.",
        content=VContainer(
            AGGrid(
                style="width: 100%; height: 500px;",
                variable="table_var",
            ),
        ),
    ),


    Glimmer.exampleSourceAsCard(@__FILE__),     # add the source code of the example as the last control
)
# set the controls for the application
controls!(app, ui)

# ---------------------------------------------------------------
# Run the application
# ---------------------------------------------------------------
run(app)

println("End [$(splitext(basename(@__FILE__))[1])]")

end # module
