module Example

using Glimmer, Glimmer.FlexUI

println("Start [$(splitext(basename(@__FILE__))[1])]")

# ---------------------------------------------------------------
# define the application and some basic properties such as title and initial window size
# ---------------------------------------------------------------
app = App()
prop!(app, :title, "Glimmer Example - Grid Types Tree")
prop!(app, :winInitWidth, 1200)
prop!(app, :winInitHeight, 800)

# ---------------------------------------------------------------
# load the data
# ---------------------------------------------------------------
types=Vector{Any}()
# this function do not belong in this package and is just included for this example.
# it returns a table of all the types/functions/modules inside the requsted module (Glimmer in this case).
GridUtils.getTypes(Glimmer, types)
table = GridUtils.toJSONTable(types)

# ---------------------------------------------------------------
# Define Variables
# ---------------------------------------------------------------
type_doc = addVariable!(app, Variable(name="type_doc", type="string", value="No Selected Type"))
table_var = addVariable!(app, Variable(name="table_var", type="aggrid", value=""))

# setup the grid data and options - will get friendlier in the near future
# for tree type tables, we need to supply the name of the "id" firld and the "parent" field.
table_var[] = GridUtils.table2agGridTree(table, "_id", "_parentId") 

# setting some grid options - because of it's complexity, the grid's data and visualization properties 
# are all stored in the variable and not the UI control.
gridOption!(table_var, "rowSelection", "single")
gridOption!(table_var, "showRowIndex", true)
gridOption!(table_var, "treeViewIndentPixels", 30)
gridOption!(table_var, "suppressScrollOnNewData", true)
gridOption!(table_var, "showTreeViewFilter", true)
forEachGridColumn!(table_var, "editable", false)

# override the default column definitions - don't want to show all the fields in the table
clearGridColumns!(table_var)
addGridColumn!(table_var, gridTreeViewCell(header="Type Name", eventName="myTreeFieldClicked", field="name", width=350))
addGridColumn!(table_var, gridCell(header="Description", field="desc"))
addGridColumn!(table_var, gridCell(header="Type", field="type"))
addGridColumn!(table_var, gridCell(header="Has Documentation", field="hasDocs"))

# define the column default values (note the cellStyle to color a line red according to documantation existance)
gridDefaultColDef!(table_var, gridCell(
    editable=false, 
    resizable=true,
    cellStyle="__js__ params => params.data.hasDocs==false ? { color: 'red' } : { color: 'green' }",
))



# ---------------------------------------------------------------
# Define Events
# ---------------------------------------------------------------
# see https://www.ag-grid.com/angular-data-grid/grid-events/ for details

# this is an example of how to convert the grid variable back into a table - not used in this example
on(table_var, :valueChanged) do val
    @show "ON valueChanged" 
    new_table = Tables.matrix(table_var[]);
    @show new_table
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

    rows = val["selectedRows"];
    if (length(rows) == 0)
        type_doc[] = "No Selected Type";
        return
    end
    if (length(rows) > 1)
        @warn "currently can't handle more than a single selected row - will process first one only" 
    end

    doc = rows[1]["docs"]
    type_doc[] = (doc!=="") ? doc : "No Selected Type"
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
        subtitle="The grid show a tree structure representing the types/functions/modules inside the Glimmer package.",
        content=HContainerStartStart(
            AGGrid(
                style="width: 500px; max-width: 500px; height: 500px;",
                variable="table_var",
            ),
            Card(
                title="Documentation",
                # experementing with different styles because i have no clue about html/css
                contentStyle="max-width: 500px; background-color: lightgreen; border: 1px solid black;overflow:auto;",
                # contentStyle="max-width: 500px; overflow:auto;",
                content=HContainer(
                    Markdown(
                        content="\$(type_doc)",
                    ),
                ),
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
