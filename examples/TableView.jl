module Example

using Glimmer, Glimmer.FlexUI
using TableView, DataFrames, CSV

println("Start [$(splitext(basename(@__FILE__))[1])]")

#---------------------------------------------------------------
# define the application and some basic properties such as title and initial window size
#---------------------------------------------------------------
app = App()
prop!(app, :title, "Glimmer Example - TableView")
prop!(app, :winInitWidth, 1200)
prop!(app, :winInitHeight, 800)

#---------------------------------------------------------------
# load the data
#---------------------------------------------------------------
filename = joinpath(dirname(pathof(Glimmer)), "Data", "mlb_players.csv");
csv = CSV.File(filename)
df = DataFrame(csv)
table_data = TableView.showtable(df, cell_changed = msg -> update_cell(df, msg))

# define the grid cell update function
function update_cell(arr, msg)
    row = msg["row"] + 1 # zero-indexed in JS
    col = msg["col"]
    @info arr[row, col] "->" msg["new"]
    arr[row, col] = msg["new"]
end

#---------------------------------------------------------------
# Define Controls
#---------------------------------------------------------------
ui = VContainer(
    Card(
        title="This is an example of a TableView GRID which updates a Julia Dataframe",
        subtitle="Currently, Glimmer does not contain a GRID component, but allow you to utilize existing GRID component such as the one in the TableView package.",
        content=VContainer(
            RawHTML(
                html=renderHTML(table_data),
                style="width: 100%; height: 500px;"
            ),
        ),
    ),

    Glimmer.exampleSourceAsCard(@__FILE__),     # add the source code of the example as the last control
)
# set the controls for the application
controls!(app, ui)

#---------------------------------------------------------------
# Run the application
#---------------------------------------------------------------
run(app)

println("End [$(splitext(basename(@__FILE__))[1])]")

end # module
