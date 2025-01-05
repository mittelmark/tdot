# tdot

[![license](https://img.shields.io/badge/license-BSD-lightgray.svg)](https://opensource.org/license/bsd)
[![Release](https://img.shields.io/github/v/release/mittelmark/tdot.svg?label=current+release)](https://github.com/mittelmark/tdot/releases)
![Downloads](https://img.shields.io/github/downloads/mittelmark/tdot/total)
![Commits](https://img.shields.io/github/commits-since/mittelmark/tdot/latest)
[![Manual](https://img.shields.io/badge/Docu-Manual-blue)](http://htmlpreview.github.io/?https://github.com/mittelmark/mkdoc/blob/master/tdot/tdot/tdot.html)
[![Wiki](https://img.shields.io/badge/Docu-Wiki-blue)](https://wiki.tcl-lang.org/page/tdot)

Tcl/Tk  package and  application  to create  GraphViz  diagrams using Tcl like
syntax.

## Example 

```tcl
package require tdot
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
tdot write tdot-demo.svg
```

![](assets/tdot-demo.svg)

## Links

- [Manual](https://htmlpreview.github.io/?https://raw.githubusercontent.com/mittelmark/tdot/master/tdot/tdot.html)

## Author

Detlef Groth, University of Potsdam, Germany, dgroth(at)uni(minus)potsdam(dot).de

## LICENSE

```
BSD 3-Clause License

Copyright (c) 2021-2025 Detlef Groth, University of Potsdam, Germany

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its
   contributors may be used to endorse or promote products derived from
   this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.  
```
