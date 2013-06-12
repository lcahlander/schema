(:~
 : This is the main XQuery which will (by default) be called by controller.xql
 : to process any URI ending with ".html". It receives the HTML from
 : the controller and passes it to the templating system.
 :)
xquery version "3.0";

import module namespace s2svg="http://greatlinkup.com/ns/schema2svg" at "schema2svg.xqm";

declare option exist:serialize "method=xml media-type=image/svg+xml indent=yes omit-xml-declaration=no";

let $schema := request:get-parameter('schema', '')
let $name := request:get-parameter('name', '')
let $type := request:get-parameter('type', '')
let $doc:= doc($schema[1])
let $root := $doc//*[@name eq $name[1] and local-name(.) eq $type[1]]
let $ret-code := util:declare-option("exist:serialize", "media-type=image/svg+xml")
return s2svg:svg($root, $doc, 3)
