module Example

using Blink
Blink.maintp.tokens[5].value = """</script>\n    <script src=\"blink.js\"></script>\n    <link rel=\"stylesheet\" href=\"reset.css\">\n
        <link rel=\"stylesheet\" href=\"blink.css\">\n\n    <link rel=\"stylesheet\" href=\"spinner.css\">\n 

        <script type="text/javascript" src="assets/monaco-editor/min/vs/loader.js"></script>
        <base href="d:/Projects/Rays/Github/Glimmer.jl/src/Data/dist/"> 

        </head>\n   <body>\n\n    <!-- Spinner -->\n    <div class=\"vcentre\"><div>\n      <div class=\"sk-spinner

        sk-spinner-cube-grid\">\n        <div class=\"sk-cube\"></div>\n        <div class=\"sk-cube\"></div>\n
              <div class=\"sk-cube\"></div>\n        <div class=\"sk-cube\"></div>\n        <div class=\"sk-cube\"></div>\n        <div class=\"sk-cube\"></div>\n        <div class=\"sk-cube\"></div>\n        <div class=\"sk-cube\"></div>\n        <div class=\"sk-cube\"></div>\n      </div>\n    </div></div>\n\n  
</body>\n</html>\n"""

using Glimmer, Glimmer.FlexUI
using TableView, DataFrames, CSV

println("Start [$(splitext(basename(@__FILE__))[1])]")

#---------------------------------------------------------------
# define the application and some basic properties such as title and initial window size
#---------------------------------------------------------------
app = App()
prop!(app, :title, "Glimmer Example - CodeEditor")
prop!(app, :winInitWidth, 1200)
prop!(app, :winInitHeight, 800)

#---------------------------------------------------------------
# Define the Variables we will be using in this example
#---------------------------------------------------------------

# image file name
code = addVariable!(app, Variable(name="code", type="string",
        value="""
        a = 1
        for i in 1:10
            println(i)
        end
        """))

#---------------------------------------------------------------
# Define Controls
#---------------------------------------------------------------
ui = VContainer(
    Card(
        title="This is an example of a TableView GRID which updates a Julia Dataframe",
        subtitle="Currently, Glimmer does not contain a GRID component, but allow you to utilize existing GRID component such as the one in the TableView package.",
        content=VContainer(
            CodeEditor(
                variable="code"   ,
            ),
            Image(
                source="test.png",
            )
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
