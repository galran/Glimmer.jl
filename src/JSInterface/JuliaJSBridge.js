

/* console.log("Hi from JuliaJSCommunicator 22"); */

JuliaJS = {
    Requests: {
        DummyRequest: null,
    }
}

// http://slavik.meltser.info/the-efficient-way-to-create-guid-uuid-in-javascript-with-explanation/  
function CreateGuid() {
    function _p8(s) {
        var p = (Math.random().toString(16) + "000000000").substr(2, 8);
        return s ? "-" + p.substr(0, 4) + "-" + p.substr(4, 4) : p;
    }
    return _p8() + _p8(true) + _p8(true) + _p8();
}


JuliaJS["Ran"] = function (v) {
    console.log("VVVVV=");
    console.log(v);
}



JuliaJS["GetHTMLFromJulia"] = function (v) {
    // var container = v.container;
    // var source = v.source;
    console.log("GetHTMLFromJulia", "Starting")
    console.log(v)
    var guid = CreateGuid()

    JuliaJS.Requests[guid] = v

    JuliaJS.ToJulia(
        {
            From: v.source,
            Date: 'Today',
            OP: "HTMLRequest",
            GUID: guid,
        },
        {
        }
    );

    console.log("GetHTMLFromJulia", "Done")
}

// -------------------------------------------------------------------------------

JuliaJS["nodeScriptReplace"] = function (node) {
    if (JuliaJS.nodeScriptIs(node) === true) {
        node.parentNode.replaceChild(JuliaJS.nodeScriptClone(node), node);
    }
    else {
        var i = -1, children = node.childNodes;
        while (++i < children.length) {
            JuliaJS.nodeScriptReplace(children[i]);
        }
    }

    return node;
}

JuliaJS["nodeScriptClone"] = function (node) {
    var script = document.createElement("script");
    script.text = node.innerHTML;

    var i = -1, attrs = node.attributes, attr;
    while (++i < attrs.length) {
        script.setAttribute((attr = attrs[i]).name, attr.value);
    }
    return script;
}

JuliaJS["nodeScriptIs"] = function (node) {
    return node.tagName === 'SCRIPT';
}



JuliaJS["SetHTMLFromJulia"] = function (guid, html) {
    console.log("SetHTMLFromJulia", "Starting")
    console.log("GUID", guid)
    console.log("HTML", html)

    console.log(1)
    var v = JuliaJS.Requests[guid]
    console.log(2)
    console.log(v)

    var container = v.container;
    console.log(3)
    console.log(container)
    container.innerHTML = html;
    // container.innerHTML = "<script>if (window.WebIO) {console.log('WEBIO EXists');} </script>"
    // container.innerHTML = "<div><p>MOOOOOO</p><script>alert(1)</script></div>";
    console.log(4)
    // added to overcome the fact that scripts are not executed when updated with innerHTML - we execute all the scripts recursivly here
    JuliaJS.nodeScriptReplace(container);
    console.log(5)

    console.log("SetHTMLFromJulia", "Done")
}
