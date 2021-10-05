
module FlexUI

import Blink
import ..JuliaJSBridge
import ..UIVariables
import ..UIControls
using ..Glimmer
import WebIO
import UUIDs

export  App, 
        # win, 
        jjs, 
        variables, variables!, 
        variable,
        controls, controls!, 
        # viewerUrl, viewerUrl!, 
        renderFunction, renderFunction!,
        addVariable!,

        sendJSMessage,
        send!,

        run

mutable struct App <: AbstractUIApp
    _win::Union{Nothing, Blink.Window}
    _jjs::Union{Nothing, JuliaJSBridge.JuliaJS}

    _props::Dict{Symbol, Any}
    _variables::Vector{UIVariables.AbstractUIVariable}
    _controls::Vector{UIControls.AbstractUIControl}

    _render_function::Union{Nothing, Function}

    __insideRender::Bool
end

function App(; 
    variables::Vector = [],
    controls::Vector = [],
    render_function::Union{Nothing, Function} = nothing
)
    app = App(
        nothing, 
        nothing, 
        Dict{Symbol, Any}(),
        Vector{UIVariables.AbstractUIVariable}[], 
        Vector{UIControls.AbstractUIControl}[], 
        nothing,
        false
    )

    variables!(app, variables)
    controls!(app, controls)
    # viewerUrl!(app, viewer_url)
    renderFunction!(app, render_function)

    return app
end


Glimmer.win(app::App) = app._win
function win!(app::App, win::Blink.Window)
    app._win = win
end

jjs(app::App) = app._jjs
function jjs!(app::App, jjs::JuliaJSBridge.JuliaJS)
    app._jjs = jjs
end

props(app::App) = app._props
function Glimmer.prop(app::App, p::Symbol, default_val = nothing)
    return get(props(app), p, default_val)
end
function Glimmer.prop!(app::App, p::Symbol, val::Any)
    props(app)[p] = val
end


variables(app::App) = app._variables
function variables!(app::App, variables::Vector)
    app._variables = convert(Vector{UIVariables.AbstractUIVariable}, variables)
end

Glimmer.controls(app::App) = app._controls
function Glimmer.controls!(app::App, controls::Vector)
    app._controls = convert(Vector{UIControls.AbstractUIControl}, controls)
    fix_controls!(app, app._controls)
end
function Glimmer.controls!(app::App, control::AbstractUIControl)
    app._controls = [control]
    fix_controls!(app, app._controls)
end

"""
    variable(app::App, name::String)

Return the variable object or nothing if variable cannot be found in app.    
"""
function variable(app::App, name::String)
    index = findfirst(x -> (x.name == name), variables(app))
    if (index === nothing)
        return nothing
    else
        return variables(app)[index]
    end
end


# viewerUrl(app::App) = app._viewer_url
# function viewerUrl!(app::App, url::String)
#     app._viewer_url = url
# end

"""
    forceUpdateControls!(app::App)

Force an update of controls that are not updated during the normal execution of an application. Currently, RawHTML is the only    
component that behaves like that due to the time it can take to update it.
"""
function forceUpdateControls!(app::App)
    if (app !== nothing && Glimmer.win(app) != nothing)
        Blink.@js_ Glimmer.win(app) begin
            window.fireAngularEvent("updateRawHTML", [])
        end
        render!(app)
    end
end


function sendJSMessage(app::App, type::String, data::Any)
    if (app === nothing || Glimmer.win(app) === nothing)
        @warn "sendJSMessage: app or app window is not initialized yes...skipping "
        return
    end

    @info "sending data to JS"
    Blink.@js_ Glimmer.win(app) begin
        console.log("Ran");
        window.fireAngularEvent($(type), [$(data)])
    end
end


Glimmer.renderFunction(app::App) = app._render_function
function Glimmer.renderFunction!(app::App, render_func::Union{Nothing, Function})
    app._render_function = render_func
end


function findVariable(app::App, var_name::String)
    return findfirst(x->x.name == var_name, variables(app))
end

function var(app::App, var_name::String)
    index = findVariable(app, var_name)
    if (index === nothing)
        error("can't find variable [$var_name]");
    end
    return variables(app)[index]
end


function Glimmer.addVariable!(app::App, var::AbstractUIVariable)
    if (findVariable(app, var.name) !== nothing)
        error("Application already contains a variable [$(var.name)]")
    end
    var._app = app
    push!(variables(app), var)
    return var
end


function prepareApp!(app::App)
    # set the app on all variables and controls
    for var in variables(app)
        var._app = app
    end

    for c in controls(app)
        c._app = app
    end

end


function fix_controls!(app::App, controls::Vector{UIControls.AbstractUIControl})
    for control in controls
        # generate dummy variable for buttons is nececery
        # @info control.type
        if (control.type == "button" && control.variable === nothing)
            unique_var_name = isempty(control._variable_name_to_create) ? "auto_generate_for_button_$(UUIDs.uuid1())" : control._variable_name_to_create
            @info "Adding automatic variable for Button [$unique_var_name]"
            auto_var = UIVariables.Variable(
                name=unique_var_name,
                type="number",
                value=0, 
            )
            push!(variables(app), auto_var)
            control.variable = unique_var_name
        end

        # TODO: Should replace these statements with a scan of all fields and run the fix on each which is a UIControls.AbstractUIControl
        if (hasproperty(control, :children))
            fix_controls!(app, control.children)
        end
        if (hasproperty(control, :content))
            if (control.content isa UIControls.AbstractUIControl)
                fix_controls!(app, Vector{UIControls.AbstractUIControl}([control.content]))
            end
        end
        if (hasproperty(control, :tabs))
            fix_controls!(app, Vector{UIControls.AbstractUIControl}(control.tabs))
        end
    end
end

function prepareJSStructure(app::App)
    res = Dict{Symbol, Any}(
        :app => Dict{Symbol, Any}(),
        :variables => Dict{Symbol, Any}(),
        :ui => [],
    )

    res[:app][:title] = prop(app, :title, "?? app title ??")
    # @info app._props
    # @info prop(app, :title, "?? app title ??")

    # add variables
    for var in variables(app)
        res[:variables][Symbol(var.name)] = UIVariables.typedict(var)
    end
    # @show variables(app)
    # @show res[:variables]


    res[:ui] = [UIControls.typedict(c) for c in controls(app)]

    return res;
end

function getUIFolder()

    res = joinpath(dirname(@__FILE__), "..", "..", "deps", "FlexUI");
    if (isdir(res))
        return res
    end

    res = joinpath(dirname(@__FILE__), "..", "Data", "dist");
    if (isdir(res))
        return res
    end

    res = raw"D:\Projects\Rays\Github\FlexUI\dist\FlexUI"

    return res;
end

function Base.run(app::App)
    prepareApp!(app)

    # this is a hack to change the base reference of the loaded page to be out dist direction.
    # it is needed for the angular application to be able to load assets correctly.
    # the problem is that Blink does not expose this in a nice way - so i have do to some horrible things.
    restore_blink_html = false;
    saved_blink_html = ""
    saved_blink_index = 0;
    for (index, token) in enumerate(Blink.maintp.tokens)
        str = token.value;
        pos = findfirst("</head>", str)
        if (pos !== nothing) 
            restore_blink_html = true 
            saved_blink_index = index
            saved_blink_html = str
            # slash at the end of the base href is IMPORTANT
            str = str[1:pos[1]-1] * 
                    """<base href="$(replace(abspath(getUIFolder()), '\\'=>'/'))/">""" *
                    """<script src='assets/WGLRenderer/Build/WGLRenderer.loader.js'></script>""" *
                    str[pos[1]:end]
            token.value = str
            # @info "replaced blink html" str
            break
        end
    end
    # saved_value = Blink.maintp.tokens[5].value

    # <script src='/assets/demo/Build/Build.loader.js'></script>
    #     <base href="$(replace(abspath(getUIFolder()), '\\'=>'/'))">
    # <base href="D:/Projects/Rays/Github/Glimmer.jl/src/Data/dist/">

    # slash at the end of the base href is IMPORTANT
    # Blink.maintp.tokens[5].value = """</script>
    # <script src=\"blink.js\"></script>    
    # <link rel=\"stylesheet\" href=\"reset.css\">
    # <link rel=\"stylesheet\" href=\"blink.css\">
    # <link rel=\"stylesheet\" href=\"spinner.css\">

    # <base href="$(replace(abspath(getUIFolder()), '\\'=>'/'))/">
    # <script src='assets/demo/Build/Build.loader.js'></script>

    # </head>\n  <body>\n\n    <!-- Spinner -->\n    <div class=\"vcentre\"><div>\n      <div class=\"sk-spinner sk-spinner-cube-grid\">\n        <div class=\"sk-cube\"></div>\n     
    # <div class=\"sk-cube\"></div>\n        <div class=\"sk-cube\"></div>\n        <div class=\"sk-cube\"></div>\n        <div class=\"sk-cube\"></div>\n        <div class=\"sk-cube\"></div>\n        <div class=\"sk-cube\"></div>\n        <div class=\"sk-cube\"></div>\n        <div class=\"sk-cube\"></div>\n      </div>\n    </div></div>\n\n  </body>\n</html>\n"""


    window_defaults = Blink.@d(
        :title => prop(app, :title, "?? app title ??"), 
        :width => prop(app, :winInitWidth, 1600), 
        :height => prop(app, :winInitHeight, 1200),
        # this will allow us to load local file which is a security risk
        :webPreferences => Blink.@d(
            :webSecurity => false, 
            :experimentalFeatures => true,
            :nodeIntegration => true,
        ),
    )
    win =Blink. Window(window_defaults)

    win!(app, win)

    bridge = JuliaJSBridge.JuliaJS(win; update_func=onBlinkUpdate, update_func_tag=app)
    jjs!(app, bridge)

    app_dir = getUIFolder() # raw"D:\Projects\Rays\Tests\UI\FlexUI\dist\FlexUI"
    app_node = JuliaJSBridge.application_node(jjs(app), app_dir)
    
    ui = WebIO.Node(:dom, 
        app_node,
        WebIO.Node(Symbol("app-root"), ""),
    )

    # show the blink window
    Blink.body!(win, ui, async=false)
    # Blink.AtomShell.opentools(win)

    # set the controls through JavaScript and also the viewer url
    # js_controls = [UIControls.typedict(c) for c in controls(app)]
    data = prepareJSStructure(app)
    # viewer_url = viewerUrl(app)
    Blink.@js_ win begin
        # JuliaJS.SetHTMLFromJulia($(guid), $(html))
        # console.log("Controls", $(js_controls))
        window.fireAngularEvent("initializeApplication", [$(data)])
        # window.fireAngularEvent("setViewerUrl", [$(viewer_url)])
    end

    # call the general update function once after initialization
    render!(app)

    if (restore_blink_html)
        # @info "restored blink html"
        Blink.maintp.tokens[saved_blink_index].value = saved_blink_html
    end

end

function onBlinkUpdate(args::Dict, app::App)
    # @info args
    meta_data = args["meta_data"]
    data = args["data"]
    
    if get(meta_data, "source", "") == "variable-update"
        var_name = get(data, "name", "")
        index = findfirst(x -> (x.name == var_name), variables(app))
        if (index === nothing)
            @error "Failed to locate a variable [$var_name]"
        else
            var = variables(app)[index]
            val = get(data, "value", "?")
            var.value = val;
        end

        # call variable's onChange function
        # if (var._on_change_func !== nothing)
        #     var._on_change_func(val)
        # end
        emit(var, :valueChanged)

        render!(app)
    
    elseif get(meta_data, "source", "") == "event"
        # @info args
        event = Symbol(get(data, "type", "unknownEvet"))
        if (haskey(data, "variable"))
            var_name = get(data, "variable", "")
            var = variable(app, var_name)
            if (var != nothing)
                emit(var, event, data)
            end
        end

    elseif get(meta_data, "source", "") == "dev-tools-update"
        state = get(data, "state", "")
        if (state) 
            Blink.AtomShell.opentools(Glimmer.win(app))
        else
            Blink.AtomShell.closetools(Glimmer.win(app))
        end

    elseif get(meta_data, "source", "") == "set-zoom-level"
        level = get(data, "level", "")
        if (endswith(level, '%'))
            level = level[1:end-1]
        end
        level = parse(Float64, level) / 100.0;
        
        w = Glimmer.win(app)
        id = w.id
        # @info "zoom level", level
        command = """windows["$(id)"].webContents.setZoomFactor($level);"""
        Blink.js(w.shell, Blink.JSString(command), callback=false)
        # @info "zoom level done"
    else
        @warn "Got a BLINK message - don't know how to handle it\n" args 
    end

    # id = data["id"]
    # index = findfirst(x -> x.id == id, controls(app))
    # c = controls(app)[index]

    # # get the new value
    # val = nothing
    # if (data["type"] == "slider")
    #     val = get(data, "value", 0.0)
    #     c.value = val
    # elseif (data["type"] == "button")
    #     val = get(data, "text", "")
    # elseif (data["type"] == "field")
    #     val = get(data, "value", "")
    #     c.value = string(val)
    # else
    #     @error "unrecognized control type"
    # end

    # if (c._func !== nothing)
    #     c._func(val)
    # end

    # if (renderFunction(app) !== nothing)
    #     renderFunction(app)()
    # end

end

function Glimmer.updateVariable!(app::App, var::UIVariables.AbstractUIVariable)
    if (app !== var._app)
        # need to add variable as new in this app - not supported yet
        @error "unsupported behaviour - please check"
    end

    # send update to julia - check that the app and win are set already. 
    # otherwise it might be an assignment to the variable before running the application
    if (app !== nothing && Glimmer.win(app) != nothing)
        data = UIVariables.typedict(var)
        Blink.@js_ Glimmer.win(app) begin
            window.fireAngularEvent("setVariableFromJulia", [$(data)])
        end

        render!(app)
    end

    # call variable's onChange function
    # if (var._on_change_func !== nothing)
    #     var._on_change_func(var.value)
    # end
    emit(var, :valueChanged)

    render!(app)
end

function render!(app::App)
    # guard agaist stack overflow when updating variables inside the render function
    if (app.__insideRender)
        return
    end
    app.__insideRender = true;
    try
        # call the general update function
        if (renderFunction(app) !== nothing)
            renderFunction(app)()
        end
    catch e
        @error "Encountered some errror [$e]" exception=(e, catch_backtrace())
    end
    app.__insideRender = false;
end



# some utility function for communication with WGLRenderer
function send!(var::AbstractUIVariable, data::Any)
    if (var.type != "wgl-renderer")
        @warn "Variable [$(var.name)] is not of type 'wgl-renderer' - oprration is not supported"
        return;
    end

    # @info var

    js_data = Dict{Symbol, Any}(
        :type => "wgl-renderer",
        :variable => var.name,
        :data => data,
    )

    # @info js_data

    sendJSMessage(var._app, "WGLRendererData", js_data);
    # @info "js data sent"
    
end




end # modeule FlexUI