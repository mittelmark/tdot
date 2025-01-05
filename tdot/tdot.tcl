#!/usr/bin/env tclsh
##############################################################################
#
#  Author        : Dr. Detlef Groth
#  Created By    : Dr. Detlef Groth
#  Created       : Fri Sep 3 04:27:29 2021
#  Last Modified : <250105.1220>
#
#  Description	 : Literate programming with Tcl/Tk with in Markdown 
#                  embedded Tcl code
#
#  Notes
#
#  History       : 2021 - initial release
#	
##############################################################################
#
#  Copyright (c) 2021-2025 Detlef Groth, University of Potsdam, Germany
# 
#  License:      BDS 3 
# 
##############################################################################


package require Tcl 8.6-
package provide tdot 0.4.0
#' ---
#' author: Detlef Groth, University of Potsdam, Germany
#' title: tdot package documentation 0.4.0
#' date: 2025-01-05
#' ---
#' 
#' ## NAME 
#' 
#' _tdot_ - Graphviz dot file writer - package and application to create Graphviz dot files with a syntax
#'  close to Tcl and to the Dot language using the thingy object system.
#' 
#' ## SYNOPSIS PACKAGE
#' 
#' ```{.tcl}
#' # demo: synopsis
#' package require tdot
#' tdot set type "strict digraph G"
#' tdot graph margin=0.2 
#' tdot node width=1 height=0.7 style=filled fillcolor=salmon shape=box
#' tdot block rank=same A B C
#' tdot addEdge A -> B
#' tdot node A label="Hello"
#' tdot node B label="World" fillcolor=skyblue
#' tdot edge dir=back
#' tdot addEdge B -> C
#' tdot node C label="Powered by\n tdot"
#' tdot write tdot-synopsis.svg
#' ```
#' 
#' > ![](tdot-synopsis.svg)
#' 
#' ## SYNOPSIS APPLICATION
#' 
#' Running the tdot application required the package application runner [tclmain](https://github.com/mittelmark/tclmain).
#'
#' ```
#' tclmain -m tdot --help                            # show the help page
#' tclmain -m tdot --demo                            # gives out some demo code
#' tclmain -m tdot --demo | dot -Tx11                # displays the demo code on X11
#' tclmain -m tdot FILENAME                          # where filename is a Tcl file
#'                                                   # containing tdot code, 
#'                                                   # file extensions: tcl or tdot
#' tclmain -m tdot FILENAME | dot -Tpdf out.pdf      # creates a pdf file out 
#'                                                   # of tdot code in FILENAME
#' ```
#'
#' ## DESCRIPTION
#' 
#' The package provides one command _tdot_ which can hold currently just a dot 
#' file code. All commands will be evaluated within the tdot namespace. 
#' In comparison to the Graphviz [tcldot](https://graphviz.org/pdf/tcldot.3tcl.pdf) 
#' and the [gvtcl](https://graphviz.org/pdf/gv.3tcl.pdf)  packages this package
#' uses directly the Graphviz executables and has a syntax very close to the dot language. So there is no need to consult special API pages for the interfaces. It is therefore enough to consult the few methods below and the
#' standard [dot](https://graphviz.org/pdf/dotguide.pdf) or [neato](https://graphviz.org/pdf/neatoguide.pdf)  documentation.
#' There are a few restrictions because of this, for instance you can't delete nodes and edges, you can only use _shape=invis_ to hide them for instance.
#  There is as well currently no graph information available like number of nodes and edges etc. 
#' 
#' Please note that semikolon and brackets are special Tcl symbols to use them in labels you must escape them with backslashes, an example is given in the [history example](#tdot-history) below.
#' 
# minimal OOP
proc thingy name {
    proc ::$name args "namespace eval ::$name \$args"
} 
    
;# our object
thingy tdot

interp alias {} self {} namespace current 

tdot set type "strict digraph G"
tdot set code ""

#' ## VARIABLES
#' 
#' The following public variables can be modified using the set command like so: _tdot set varname value_:
#' 
#' __code__ - the variable collecting the dot code, usually you will only set this variable by hand to remove all existing dot code after creating a dot file by calling _tdot set code ""_.
#'
#' __type__ - the dot type of graph, default: "strict digraph G", other possible value should be "graph G" for undirected graphs.
#' 
#' ## METHODS
#' 
#' The following methods are implemented:

# self - demo docu {
#' 
#' __self__
#' 
#' > just a shorthand `interp alias` for the longer command `namespace current`
#' 
#' ## TDOT METHODS
#' 
# tdot addEdge docu {
#' __tdot addEdge__ *args* 
#' 
#' > Adds code to the graph creating edges, if the last arguments are edge 
#'   attributes the will be appended as well to the edge.
#' 
#' ```
#' tdot addEdge A -> B color=red
#' # A -> B [color=red];
#' ```
#' 
# }
tdot proc addEdge {args} {
    set self [self]
    set args [$self TagFix $args]
    #$self append code ""
    set flag false
    for {set i 0} {$i < [llength $args]} {incr i 1} {
        if {!$flag && [regexp {=} [lindex $args $i]]} {
            $self append code "\["
            set flag true
        } elseif {$flag && [regexp {=} [lindex $args $i]]} {
            $self append code ","
        } elseif {$flag} {
            $self append code "\]"
            set flag false
        }
        if {$i == 0} {
            $self append code "  "
        } elseif {$i > 0 && !$flag} {
            $self append code " "
        }
        if {[regexp {[/ ]} [lindex $args $i]] && ![regexp {.+=.+} [lindex $args $i]]} {
            $self append code "\"[lindex $args $i]\""
        } else {
            $self append code "[lindex $args $i]"
        }
    }
    if {$flag} {
        $self append code "\]"
    }
    
    $self append code ";\n"

}
# tdot block docu {
#' __tdot block__ *args* 
#' 
#' > Adds code to the graph within curly braces, arguments are separed by semikolons.
#' 
#' ```
#' tdot block rank=same A B C
#' # { rank=same; A; B ; C; }
#' ```
#' 
# }

tdot proc block {args} {
    set self [self]
    set args [$self TagFix $args]
    set txt "{\n"
    set flag false
    set open false
    for {set i 0} {$i < [llength $args]} {incr i 1} {
        # TODO: block rank=same A label="Hello" fillcolor=salmon B label=World!
        if {[regexp {[/ ]} [lindex $args $i]]} {
            set arg "\"[lindex $args $i]\""
            lset args $i $arg
        }
        if {[regexp {^[A-Za-z].+=.+} [lindex $args $i]] && $i > 0} {
            if {$flag} {
                append txt ", [lindex $args $i]"
            } else {
                append txt "\[[lindex $args $i]"
            }
            set flag true
        } else {
            if {$flag} {
                append txt "\]"
                set flag false
            }
            if {$i > 0} {
                if {![regexp -- {-[->]} [lindex $args $i]]} {
                    append txt "; "
                } else {
                    append txt " "
                }
            } 
            if {[regexp { } [lindex $args $i]]} {
                append txt "\"[lindex $args $i]\""
            } else {
                append txt "[lindex $args $i]"
            }
        }
    }
    if {$flag} {
        append txt "\]"
    }
    append txt ";"
    set txt [regsub -all -- {(-[->]);} $txt "\\1"]
    append txt "\n}\n"
    $self append code $txt
}

# tdot demo - docu {
#' 
#' __tdot demo__ 
#' 
#' > Writes a simple "Hello World!" demo to stdout. 
#' 
# }
tdot proc demo {} {
    tdot set code ""
    tdot graph margin=0.4
    tdot node style=filled fillcolor=grey80 width=1.2 height=0.7
    tdot block rank=same E D C F G 
    tdot addEdge A -> B label=" connects"
    tdot addEdge B -> C 
    tdot addEdge B -> D
    tdot addEdge D -> E
    tdot node A label="Hello" style=filled fillcolor=salmon width=2 height=1
    tdot node B label="World!" style=filled shape=box fillcolor=skyblue width=2 height=0.8
    tdot addEdge C -> F -> G
    return [tdot render]
}

# tdot dotstring docu {
#' __tdot dotstring__ *dotstr* 
#' 
#' > Adds complete graph code to the graph starting a new graph from scratch. 
#'   First line and last line should contain opening and closing curly braces. As in the example
#'   below.
#' 
#' ```{.tcl}
#' # demo: synopsis
#' package require tdot
#' tdot dotstring {
#'   digraph G {
#'     dir1 -> CVS;
#'     dir1 -> src -> doc;
#'     dir1 -> vfs-> bin;
#'     vfs -> config -> ps;
#'     config -> pw -> pure;
#'     vfs -> step1 -> substep;
#'     dir1 -> www -> cgi;
#'   }
#' }
#' # make all nodes blue by adding code at the beginning
#' tdot header node style=filled fillcolor=skyblue
#' tdot write tdot-dotstring.svg
#' ```
#' 
#' > ![](tdot-dotstring.svg)
#' 
# }

tdot proc dotstring {dotstr} {
    set lines [split $dotstr "(\n|\r)+"]
    set self [self]
    set header false
    set obrace false
    set code ""
    for {set i 0} {$i < [llength $lines]} {incr i 1} {
        if {!$header && [regexp {graph} [lindex $lines $i]]} {
             if {[regexp {\{} [lindex $lines $i]]} { 
                set type [regsub {^\s*(.+)\{} [lindex $lines $i] "\\1"]
                $self set type $type
                set obrace true
             } else {
                $self set type [regsub {^\s*(.+)} [lindex $lines $i] "\\1"]
            }
            continue
         }
         if {!$obrace && [regexp {^\s*\{} [lindex $lines $i]]} {
            set l [regsub {^\s*\{} [lindex $lines $i] ""]
            lset lines $i $l    
        }
        append code [lindex $lines $i]
        append code "\n"
    }
    set code [regsub {\}[\s\n]*$} $code ""]
    $self set code $code
}
# tdot edge docu {
#' __tdot edge__ *args* 
#' 
#' > Adds code to the graph regarding edge properties which will
#'   affect all subsequently created edges.
#' 
#' ```
#' tdot edge penwidth=2 dir=none color=red
#' # edge[penwidth=2,dir=none,color=red]
#' ```
#' 
# }
tdot proc edge {args} {
    set self [self]
    set args [$self TagFix $args]
    set n [lindex $args 0]
    if {[regexp {=} $n]} {
        # all nodes
        set txt "edge"
    } else {
        set txt ""
    }
    $self append code "\n$txt\["
    for {set i 0} {$i < [llength $args]} {incr i 1} {
        if {$i > 0} {
            $self append code ", "
        }
        $self append code "[lindex $args $i]"
    }
    $self append code "\];\n"
}

# tdot graph docu {
#' __tdot graph__ *args* 
#' 
#' > Changes global graph options.
#' 
#' ```
#' tdot graph margin=0.2
#' # creates: graph[margin=0.2];
#' ```
#' 
# }
tdot proc graph {args} {
    set self [self]

    set args [$self TagFix $args]
    $self append code "graph\["
    for {set i 0} {$i < [llength $args]} {incr i 1} {
        if {$i > 0} {
            $self append code ", "
        }
        $self append code "[lindex $args $i]"
    }
    $self append code "\];\n"
}
# tdot header docu {
#' __tdot header__ *args* 
#' 
#' > Adds code to the beginning of the graph which should affect all nodes and edges
#'   created before and afterwards. This is a workaround for changing global properties
#'   after the first initial nodes and edges were added to the graph code.
#' 
#' ```{.tcl}
#' # demo: synopsis
#' package require tdot
#' tdot dotstring {
#'   graph G {
#'      run -- intr;
#'      intr -- runbl;
#'      runbl -- run;
#'      run -- kernel;
#'      kernel -- zombie;
#'      kernel -- sleep;
#'      kernel -- runmem;
#'      runmem[label="run\nmem"];
#'   }
#' }
#' tdot header node style=filled fillcolor=skyblue
#' tdot write tdot-dotstring-neato.svg
#' ```
#' 
#' > ![](tdot-dotstring-neato.svg)
#' 
# }
tdot proc header {args} {
    set self [self]
    set ocode [$self set code]
    $self set code ""
    $self {*}$args
    $self append code $ocode
}

# tdot node docu {
#' __tdot node__ *args* 
#' 
#' > Adds code to the graph within regarding node properties, first argument can be a list 
#'   of node attributes where the attributes the belong to all nodes which will created
#'   thereafter. If the first argument dies not contain an `=` sign the first argument
#'   will be taken as a node with all subsequent properties attached.
#' 
#' ```
#' tdot node fillcolor=salmon style=filled
#' # node[fillcolor=salmon,style=filled];
#' tdot node A fillcolor=salmon style=filled label="Hello World!"
#' # A[fillcolor=salmon,style=filled,label="Hello World!"];
#' ```
#' 
# }
tdot proc node {args} {
    set self [self]
    set args [$self TagFix $args]
    set n [lindex $args 0]
    if {[regexp {=} $n]} {
        # all nodes
        set txt "  node\["
    } else {
        set txt "  [lindex $args 0]\["
        set args [lrange $args 1 end]
    }
    $self append code "$txt"
    for {set i 0} {$i < [llength $args]} {incr i 1} {
        if {$i > 0} {
            $self append code ", "
        }
        $self append code "[lindex $args $i]"
    }
    $self append code "\];\n"
}
# tdot render docu {
#' __tdot render__  
#' 
#' > Returns the current graph code.
#' 
#' ```
#' puts [tdot render]
#' ```
#' 
# }
tdot proc render {} {
    set self [self]
    return "[$self set type] {\n[$self set code]\n}\n"
}

# tdot subgraph docu {
#' __tdot subgraph__ *name ?args?* 
#' 
#' > Starts a subgraph with the given name. Subsequent arguments are interpreted as
#'   standard dot commands to set global properties of the graph. 
#'   To end a subgraph the special name END has to be used. 
#'   Code is based on this [Graphviz gallery code](https://graphviz.org/Gallery/directed/cluster.html).
#' 
#' > Example:
#' 
#' ```{.tcl}
#' package require tdot
#' tdot set code ""
#' tdot set type "digraph G"
#' tdot graph rankdir=LR
#' tdot subgraph cluster_0 style=filled \
#'                         color=lightgrey \
#'                         label="process #1"
#' tdot node	style=filled color=white
#' tdot addEdge	a0 -> a1 -> a2 -> a3
#' tdot subgraph	END
#' tdot subgraph cluster_1 label="process #2" color=blue
#' tdot node	style=filled
#' tdot addEdge	b0 -> b1 -> b2 -> b3;
#' tdot subgraph	END
#' tdot addEdge	start -> a0
#' tdot addEdge	start -> b0
#' tdot addEdge	a1 -> b3 -> end
#' tdot addEdge	b2 -> a3 -> end
#' tdot addEdge	a3 -> a0;
#' tdot node start shape=Mdiamond
#' tdot node end   shape=Msquare
#' tdot write subgraph-sample.svg
#' ```
#' 
#' > ![](subgraph-sample.svg)
#' 
# }

tdot proc subgraph {name args} { 
    set self [self]
    if {$name eq "END"} {
        $self append code "\}\n"
    } else {
        $self append code "subgraph $name \{\n"
        set args [$self TagFix $args]
        for {set i 0} {$i < [llength $args]} {incr i 1} {
            $self append code "  [lindex $args $i];\n"
        }
    }
}
#tdot proc subgraph {name args} {
#    set self [self]
#    if {$name eq "END"} {
#        $self append code "}\n"
#    } else {
#        $self append code "subgraph $name {\n"
#        set args [$self TagFix $args]
#        for {set i 0} {$i < [llength $args]} {incr i 1} {
#            $self append code "  [lindex $args i]\n"
#        }
#    }
#}

# tdot url docu {
#' __tdot url__ _?-service kroki -filetype svg ?_
#' 
#' > Returns an URL using either the kroki.io or the PlantUML webservice. 
#'   This feature is only available with Tcl 8.6 or higher.
#' 
#' > Arguments:
#'
#' - _service_ : either 'kroki' or 'plantuml', default: 'kroki'
#' - _filetype_: either 'svg', 'png' or 'pdf'
#'
#' > Please note, that using this approach you can display GraphViz images within your documents
#'   by embedding the exising link within your documentaton even without
#'   an existing Graphviz installation.
#' 
#' ```{.tcl}
#' # demo: url
#' package require tdot
#' tdot set code ""
#' tdot set type "strict digraph G"
#' tdot graph margin=0.4
#' tdot node style=filled fillcolor=cornsilk shape=hexagon width=3.0
#' tdot addEdge A -> B
#' tdot node A label="tdot" comment="Hello Kroki"
#' tdot node B label="Hello Kroki!"  
#' set url [tdot url]
#' tdot node B label="Hello PlantUML!"  
#' set url2 [tdot url -service plantuml]
#' puts $url2
#' ```
#' 
#' > ![](`tcl set url`) ![](`tcl set url2`)
#' 
#'
# }

## Helper functions
tdot proc dia2kroki {text {dia graphviz} {ext svg}} {
    set b64 [string map {+ - / _ = ""}  [binary encode base64 [zlib compress $text]]]
    set uri https://kroki.io//$dia/$ext/$b64
}

### file dia2plantuml.tcl
tdot proc dia2plantuml {text {ext svg}} {
    ### plantuml does use a different order in encoding
    set b64 ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/
    set pml 0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-_

    set lmapper [list]
    set i 0
    foreach char [split $b64 ""] {
        lappend lmapper $char
        lappend lmapper [string range $pml $i $i]
        incr i
    }
    set b64 [string map $lmapper [binary encode base64 [zlib compress [encoding convertto utf-8 $text]]]]
    set uri https://www.plantuml.com/plantuml/$ext/~1$b64
    return $uri
}

tdot proc url {args} {
    set self [self]
    array set arg [list -filetype svg -service kroki]
    array set arg $args
    if {$arg(-service) eq "kroki"} {
        set url [$self dia2kroki [$self render] graphviz $arg(-filetype)]
    } else {
        set url [$self dia2plantuml "@startdot\n[$self render]\n@enddot\n" $arg(-filetype)]
    }
    return $url
}

# tdot usage docu {
#' __tdot usage__ 
#' 
#' > Returns the application usage string, usually used on the terminal using help. 
#' 
#' ```
#' tclsh tdot.tcl --help
#' ```
#' 
#' > On a Unix system using X11 or GTK 
#'   you can very likely render the demo code on the terminal if Graphviz is installed either via:
#' 
#' ```
#' # using X11
#' $ tclsh tdot.tcl --demo | dot -Tx11
#' # may be as well gtk works
#' $ tclsh tdot.tcl --demo | dot -Tgtk

#' ```
#' 
# }
tdot proc usage {} {
    set usg ""
    append usg "__APP__ \[OPTIONS\] \[FILENAME\]\n\n"
    append usg "OPTIONS  are --demo, --help or --version\n\n"
    append usg "FILENAME should contain valid tdot code like shown in the SYNOPSIS,\n"
    append usg "         without the final render command.\n"
    append usg "         The file must have either a tdot or a tcl extension.\n\n"
    append usg "------------------------------------------------------------------\n\n"
    append usg "Author:  Detlef Groth, University of Potsdam, Germany\n"
    append usg "License: BSD 3\n"
    append usg "Version: [package present tdot]" 
}

# tdot write docu {
#' __tdot write__ _?device?_
#' 
#' > Writes the current tdot code to the given device. If the argument is empty the function
#'   just returns the tdot code. The following output devices (filenames and the canvas widget) are support:
#' 
#' > Filenames can be:
#' 
#' > - dot files
#'   - png files
#'   - pdf files
#'   - svg files
#'   - tk files (containing Tk canvas code)
#'   - any other file type support by Graphviz
#' 
#' > Please note, that except for the dot file format the other file formats require
#'   an existing Graphviz installation.
#' 
#' > And we can write to a Tk canvas widget, see here an example:
#' 
#' ```{.tcl}
#' # demo: write
#' package require Tk
#' pack [canvas .can -background white] -side top -fill both -expand true
#' package require tdot
#' tdot set code ""
#' tdot set type "strict digraph G"
#' tdot graph margin=0.4
#' tdot node style=filled fillcolor=salmon shape=hexagon 
#' tdot addEdge A -> B
#' tdot node A label="tdot" comment="Hello Canvas"
#' tdot node B label="Hello World!"  
#' tdot write canvas.tk ;# for inspection later
#' tdot write .can
#' # thereafter normal canvas commands can be added
#' .can create rect 10 10 290 250 -outline red 
#' destroy . ;# just to allow automatic document processing
#' ```
#' 
#' > ![](tdot-canvas.png)
#' 
#' > You can thereafter add additional items on the canvas widget using the standard 
#'   commands of the canvas.
# }

tdot proc write {{device ""}} {
    set self [self]
    if {$device eq ""} {
        return [$self render]
    } elseif {[regexp {\.dot$} $device]} {
        set out [open $device w 0644]
        puts $out [$self render]
        close $out
        return
    }
    if {[regexp {digraph} [$self set type]]} {
        set dot "dot"
    } else {
        set dot neato
    }
    if {[file exists "C:/Program Files/GraphViz/bin/$dot.exe"]} {
        set dot "C:/Program Files/GraphViz/bin/dot.exe"
    } elseif {[file exists "C:/Programme/Graphviz/bin/$dot.exe"]} {
        set dot "C:/Programme/Graphviz/bin/$dot.exe"
    } elseif {[auto_execok $dot] ne ""} {
        set dot $dot
    } else {
        set dot ""
    }
    if {$dot eq ""} {
        tk_messageBox -title "Error!" -icon error -message "Graphviz application not found!\nInstall Graphviz!" -type ok
        return
    }
    set tfile [file tempfile]
    #puts $tfile
    set out [open $tfile w 0600]
    puts $out [$self render]
    close $out
    if {[regexp {^\.} $device] && [winfo exists $device]} {
        set c $device
        set res [exec $dot -Ttk $tfile]
        $c delete all
        eval $res
    } else {
        set extension [string range [file extension $device] 1 end]
        exec $dot -T$extension $tfile -o $device
    }

    catch { file delete $tfile }
    return ""
}
    
# private function 
# converting arguments to tdot like:
# label="Hello World!" to {label="Hello World!"}
tdot proc TagFix {args} { 
    set nargs [list]
    set args {*}$args
    set flag false
    for {set i 0} {$i < [llength $args]} {incr i 1} {
        #set arg [regsub -all {;} [lindex $args $i] "\\;"]
        #lset args $i $arg
        if {!$flag && [regexp {=".+"} [lindex $args $i]]} { ;#"
            lappend nargs [lindex $args $i] 
        } elseif {!$flag && [regexp {="} [lindex $args $i]]} { ;#"
            set flag true
            set qarg "[lindex $args $i]"
        } elseif {$flag && [regexp {"} [lindex $args $i]]} { ;#"
            set flag false
            append qarg " [lindex $args $i]"
            lappend nargs $qarg
        } elseif {$flag} {
            append qarg " [lindex $args $i]"
        } else {
            lappend nargs [lindex $args $i]
        }
    }
    return $nargs
}


#'
#' ## EXAMPLES
#' 
#' Obviously we start with the typical "Hello World!" example.
#' 
#' ```{.tcl}
#' package require tdot
#' tdot set code ""
#' tdot node A label="Hello World!\ntdot" shape=box fillcolor=grey90 style=filled
#' tdot write tdot-hello-world.svg
#' ```
#' 
#' > ![](tdot-hello-world.svg)
#' 
#' Here a more extensive example, the demo:
#'
#' ```{.tcl}
#' package require tdot
#' tdot set code ""
#' tdot graph margin=0.4
#' tdot node style=filled fillcolor=grey80 width=1.2 height=0.7
#' tdot block rank=same E D C F G 
#' tdot addEdge A -> B label=" connects"
#' tdot addEdge B -> C 
#' tdot addEdge B -> D
#' tdot addEdge D -> E
#' tdot node A label="Hello" style=filled fillcolor=salmon width=2 height=1
#' tdot node B label="World!" style=filled shape=box fillcolor=skyblue width=2 height=0.8
#' tdot addEdge C -> F -> G
#' tdot write tdot-demo.svg
#' ```
#' 
#' > ![](tdot-demo.svg)
#' 
#' Now an example which uses _neato_ as the layout engine:
#' 
#' ```{.tcl}
#' tdot set code ""
#' tdot set type "graph N" ;# switch to neato as layout engine
#' tdot addEdge n0 -- n1 -- n2 -- n3 -- n0;
#' tdot node n0 color=red style=filled fillcolor=salmon
#' tdot write dot-neato.svg
#' ```
#' > ![](dot-neato.svg)
#' 
#' Alternatively you can as well overwrite the default layout engine using the graph layout option. Here the standard dot engine which is used for digraphs.
#' 
#' ```{.tcl}
#' tdot set code ""
#' tdot set type "strict digraph G" ; # back to dot
#' tdot graph rankdir=LR
#' tdot addEdge A -> B -> C -> D -> A
#' tdot write dot-circle1.svg
#' ```
#' 
#' > ![](dot-circle1.svg)
#' 
#' Now let's switch to circo as the layout engine, still having a digraph:
#' 
#' ```{.tcl}
#' tdot set code ""
#' tdot set type "strict digraph G" ; # back to dot
#' tdot graph layout=circo ;# switch to circo (circular layout engine)
#' tdot addEdge A -> B -> C -> D -> A
#' tdot write dot-circle2.svg
#' ```
#' 
#' > ![](dot-circle2.svg)
#' 
#' Also undirected graphs can be converted:
#' 
#' ```{.tcl}
#' tdot set code ""
#' tdot set type "graph N" ;# switch to neato as layout engine
#' tdot graph layout=circo
#' tdot addEdge n0 -- n1 -- n2 -- n3 -- n0;
#' tdot node n0 color=red style=filled fillcolor=salmon
#' tdot write dot-neato2.svg
#' ```
#' 
#' > ![](dot-neato2.svg)
#' 
#' <a name="tdot-history" />
#' Now a very extended example based on the example _asde91_ 
#' in the [dotguide manual](https://www.graphviz.org/pdf/dotguide.pdf) showing the history of Tcl/Tk and tdot within ...
#' 
#' ```{.tcl}
#' tdot set code ""
#' tdot set type "digraph Tk"
#' tdot graph margin=0.3 
#' tdot graph size="8\;7" ;# semikolon must be backslashed due to thingy
#' tdot node shape=box style=filled fillcolor=grey width=1
#' tdot addEdge 1988  -> 1993 -> 1995 -> 1997 -> 1999 \
#'       -> 2000 -> 2002 -> 2007 -> 2012 -> 2021 -> future
#' tdot node fillcolor="#ff9999"
#' tdot edge style=invis
#' tdot addEdge  Tk -> Bytecode -> Unicode -> TEA -> vfs -> \
#'       Tile -> TclOO -> zipvfs
#' tdot edge style=filled
#' tdot node fillcolor="salmon"
#' tdot addEdge "Tcl/Tk" -> 7.3 -> 7.4 -> 8.0  ->  8.1 ->  8.3 \
#'       -> 8.4  -> 8.5  ->  8.6 -> 8.7 -> 9.0;
#' tdot node fillcolor=cornsilk
#' tdot addEdge  7.3 -> Itcl -> 8.6
#' tdot addEdge  Tk -> 7.4 -> Otcl -> XOTcl -> NX 
#' tdot addEdge  Otcl -> Thingy -> tdot
#' tdot addEdge  Bytecode -> 8.0 
#' tdot addEdge  8.0 -> Namespace dir=back
#' tdot addEdge  Unicode -> 8.1
#' tdot addEdge  8.1 -> Wiki
#' tdot addEdge  TEA -> 8.3 
#' tdot addEdge  8.3 -> Tcllib -> Tklib
#' tdot addEdge  8.4 -> Starkit -> Snit -> Dict -> 8.5 
#' tdot addEdge  vfs -> 8.4
#' tdot addEdge  Tile -> 8.5
#' tdot addEdge  TclOO -> 8.6  -> TDBC
#' tdot addEdge  zipvfs -> 8.7  ;# Null is just a placeholder for the history
#' tdot addEdge  UTF32 -> 9.0   ;# Null is just a placeholder for the history
#' tdot block    rank=same 1988 "Tcl/Tk"  group=g1
#' tdot block    rank=same 1993  7.3      group=g1  Itcl
#' tdot block    rank=same 1995  Tk       group=g0  7.4 group=g1 Otcl group=g2
#' tdot block    rank=same 1997  Bytecode group=g0  8.0 group=g1 Namespace
#' tdot block    rank=same 1999  Unicode  group=g0  8.1 group=g1 Wiki 
#' tdot block    rank=same 2000  TEA      group=g0  8.3 group=g1 Tcllib \
#'                               Tklib Thingy group=g3 XOTcl group=g2 
#' tdot block    rank=same 2002  vfs      group=g0  8.4 group=g1 Starkit Dict Snit
#' tdot block    rank=same 2007  Tile     group=g0  8.5 group=g1 
#' tdot block    rank=same 2012  TclOO    group=g0  8.6 group=g1 TDBC NX group=g2
#' tdot block    rank=same 2021  zipvfs   group=g0  8.7 group=g1 tdot group=g3
#' tdot block    rank=same future UTF32    group=g0 9.0 group=g1 Null group=g3
#' # specific node settings 
#' tdot node     History label="History of Tcl/Tk\nand  tdot" shape=doubleoctagon color="salmon" penwidth=5 \
#'       fillcolor="white" fontsize=26 fontname="Monaco"
#' tdot node     Namespace fillcolor="#ff9999"
#' tdot node     UTF32  fillcolor="#ff9999"
#' tdot node     future label=2024
#' tdot node     8.7    label="\[ 8.7a5 \]"
#' # arranging the History in the middle
#' tdot addEdge  9.0 -> Null style=invis
#' tdot addEdge  Null -> History style=invis
#' tdot node Null style=invis
#' tdot write tdot-history.svg
#' ```
#' 
#' > ![](tdot-history.svg)
#' 
#' ## INSTALLATION
#' 
#' The _tdot_ package requires to create images a running installation of the [Graphviz](https://graphviz.org/download/) command line tools. For only creating the textual dot files there is no installation of these tools reequired.
#' To use the package just download the library folder from [GitHub](https://downgit.github.io/#/home?url=https://github.com/mittelmark/DGTcl/tree/master/lib/tdot) and place it in your Tcl-library path.
#' 
#' ## DOCUMENTATION
#' 
#' The documentation for this HTML file was created using the pandoc-tcl-filter.tapp standalone Tcl script as follows:
#'
#' ```
#'  pandoc-tcl-filter.tapp tdot.tcl tdot.html --css mini.css --toc -s
#'  # for display on github we include all images and styles
#'  htmlark -o tdot.html tdot-ark.html
#'  mv tdot-ark.html tdot.html
#' ```
#' 
#' ## CHANGELOG
#' 
#' * 2021-09-06 Version 0.1 released with docu uploaded to GitHub
#' * 2021-09-14 Version 0.2.0 
#'     * adding dotstring command similar to tcldot's command
#'     * docu fixes, switching from png to svg if possible for filesize
#' * 2021-09-26 Version 0.3.0
#'     * adding header method for code at the beginning
#'     * adding subgraph method with extended example from Graphviz gallery
#'     * adding quoted node names
#'     * fixing spacing issues in label spaces 
#'     * adding semikolon issue as note on top
#' * 2021-09-30 Version 0.3.1
#'     * adding file delete to tdot write procedure
#' * 2021-12-13 - docu fixes
#' * 2025-01-05 Version 0.4.0
#'     * own package repo at Github
#'     * adding url method to render via online services of kroki or plantuml
#'     * documentation fixes
#'     * making it Tcl 9 aware
#'     * adding command line option to process tdot/tcl files
#'
#' ## TODO
#' 
#' - subgraphs (done, 0.3.0)
#' - multi-line string problem (done, 0.3.0)
#' - OSX check
#' - method to get number of nodes or edges using -Tplain command flag
#' - options more close to Tcl arguments (layout=circo == -layout circo, done - see examples)
#' - input as json file, so json2dot to remove edges nodes etc at a later point
#' - converter for tdot files as command line option
#'     
#' ## SEE ALSO
#' 
#' * [Graphviz documentation:](https://www.graphviz.org/documentation/)
#'     - [dotguide (pdf)](https://www.graphviz.org/pdf/dotguide.pdf).
#'     - [neatoguide (pdf)](https://www.graphviz.org/pdf/neatoguide.pdf).
#'     - [dot language (pdf)](https://www.graphviz.org/pdf/dot.1.pdf)
#'     - [tcldot documenation (pdf)](https://www.graphviz.org/pdf/tcldot.3tcl.pdf)
#' * [tmdoc](https://github.com/mittelmark/tmdoc) - document processor used to create this manual
#' * [mkdoc](https://github.com/mittelmark/mkdoc) - document converter used to create this manual
#' * [tclmain](https://github.com/mittelmark/tclmain) - package application runner similar to _python -m pkgname_
#' * [Readme.html](../../Readme.html) - Pandoc Tcl filters which were used to create this manual
#' * [Tclers Wiki page](https://wiki.tcl-lang.org/page/tdot) - place for discussion
#' 
#' ## AUTHOR
#' 
#' Detlef Groth, University of Potsdam, Germany, dgroth(_at_)uni(_minus_)potsdam(_dot_).de
#' 
#' ## LICENSE
#' 
#' ```
#' BSD 3-Clause License
#'
#' Copyright (c) 2021-2025 Detlef Groth, University of Potsdam, Germany
#' 
#' Redistribution and use in source and binary forms, with or without
#' modification, are permitted provided that the following conditions are met:
#' 
#' 1. Redistributions of source code must retain the above copyright notice, this
#'    list of conditions and the following disclaimer.
#' 
#' 2. Redistributions in binary form must reproduce the above copyright notice,
#'    this list of conditions and the following disclaimer in the documentation
#'    and/or other materials provided with the distribution.
#' 
#' 3. Neither the name of the copyright holder nor the names of its
#'    contributors may be used to endorse or promote products derived from
#'    this software without specific prior written permission.
#' 
#' THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
#' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
#' IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
#' DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
#' FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
#' DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
#' SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
#' CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
#' OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
#' OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.   
#' ```
#'

namespace eval ::tdot {
    proc main {argv} {
        global argv0
        if {[regexp {tclmain} $argv0]} {
            set app "tclmain -m tdot"
        } else {
            set app $argv0
        }
        set usg [regsub -all {__APP__} [tdot usage] $app]
        if {[llength $argv] > 0} {
            if {[lindex $argv 0] eq "--help"} {
                puts $usg
            } elseif  {[lindex $argv 0] eq "--version"} {
                puts "[package present tdot]"
            } elseif  {[lindex $argv 0] eq "--demo"} {
                puts [tdot::demo]
            } elseif {[file exists [lindex $argv 0]]} {
                if {[regexp -nocase {.(tcl|tdot)$} [lindex $argv 0]]} {
                    tdot set code ""
                    source [lindex $argv 0]
                    puts [tdot render]
                }
            } else {
                puts $usg
            }
        } else {
            puts $usg
        }
    }
}

if {[info exists argv0] && $argv0 eq [info script] && [regexp ... $argv0]} {
    ::tdot::main $argv
}
