xquery version "3.0";

module namespace app="http://exist-db.org/apps/schema/templates";

declare namespace xs="http://www.w3.org/2001/XMLSchema";

import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace config="http://exist-db.org/apps/schema/config" at "config.xqm";
import module namespace s2svg="http://greatlinkup.com/ns/schema2svg" at "schema2svg.xqm";
import module namespace s2svgdim="http://greatlinkup.com/ns/schema2svgdim" at "schema2svgdim.xqm";
import module namespace s2bootstrap="http://greatlinkup.com/ns/schema2bootstrap" at "schema2bootstrap.xqm";
import module namespace s2instance="http://greatlinkup.com/ns/schema2instance" at "schema2instance.xqm";

 (:~
 : This templating function displays the index to the XML Schema documentation. It will be called by the templating module if
 : it encounters an HTML element with a class attribute: class="app:schema".
 : 
 : @param $node the HTML node with the class attribute which triggered this call
 : @param $model a map containing arbitrary data - used to pass information between template calls
 :)
declare function app:schema($node as node(), $model as map(*)) {
    let $schema := request:get-parameter('schema', '')
    let $doc:= doc($schema)
    let $documentation := for $note in $doc/xs:schema/xs:annotation/xs:documentation
                            return s2bootstrap:documentation($note, $doc, map:new())
    
    return
    (<h2>{$schema}</h2>,
    $documentation,
    <div class="well well-small"><span class="label">Imports</span>{
    for $element in $doc/*/xs:import
    return s2bootstrap:import($element, $doc, map:new())}</div>,
    <div class="well well-small"><span class="label">Items</span>{
    for $element in $doc/*/*[@name]
    order by $element/@name/string()
    return s2bootstrap:display-list-item($element, $doc, map:new())}</div>)
};

 (:~
 : This templating function displays the XML Schema item's documentation. It will be called by the templating module if
 : it encounters an HTML element with a class attribute: class="app:item-detail".
 : 
 : @param $node the HTML node with the class attribute which triggered this call
 : @param $model a map containing arbitrary data - used to pass information between template calls
 :)
declare function app:item-detail($node as node(), $model as map(*)) {

    let $schema := request:get-parameter('schema', '')
    let $doc:= doc($schema)
    let $root := $doc//*[@name eq request:get-parameter('name', '') and local-name(.) eq request:get-parameter('type', '')]
    
    return try { s2bootstrap:process-node($root, $doc, map:new()) } catch * { <div class="alert alert-error">Problem in the processing of this XML Schema</div>}
};
 (:~
 : This templating function displays the XML Schema item's graphical view in SVG. It will be called by the templating module if
 : it encounters an HTML element with a class attribute: class="app:svg".
 : 
 : @param $node the HTML node with the class attribute which triggered this call
 : @param $model a map containing arbitrary data - used to pass information between template calls
 :)
declare function  app:svg($node as node(), $model as map(*)) {

    let $schema := request:get-parameter('schema', '')
    let $doc:= doc($schema)
    let $root := $doc//*[@name eq request:get-parameter('name', '') and local-name(.) eq request:get-parameter('type', '')]
    
    return try { s2svg:svg($root, $doc, 3)  } catch * { <div class="alert alert-error">Problem in the processing of this XML Schema</div>}
};

 (:~
 : This templating function displays the XML Schema item's graphical view dimensions in SVG. It will be called by the templating module if
 : it encounters an HTML element with a class attribute: class="app:svgdim".
 : 
 : @param $node the HTML node with the class attribute which triggered this call
 : @param $model a map containing arbitrary data - used to pass information between template calls
 :)
 declare function  app:svgdim($node as node(), $model as map(*)) {
    try {
    let $schema := request:get-parameter('schema', '')
    let $doc:= doc($schema)
    let $root := $doc//*[@name eq request:get-parameter('name', '') and local-name(.) eq request:get-parameter('type', '')]
    let $dim := s2svgdim:process-node($root, 3)
    let $elem := util:serialize(s2instance:process-node($root, $doc),"method=xml")
    return (<div class="alert alert-success">X: {$dim//x/text()} Y: {$dim//y/text()} -- {($dim//y/number() div 2) - 35}</div>,
    <div class="code" data-language="xml">
            { replace($elem, "^\s+", "") }
            </div>)
    } catch * { <div class="alert alert-error">Problem in the processing of this XML Schema</div>}
 };

 (:~
 : This templating function displays the XML Schema item's graphical view dimensions in SVG. It will be called by the templating module if
 : it encounters an HTML element with a class attribute: class="app:svgdim".
 : 
 : @param $node the HTML node with the class attribute which triggered this call
 : @param $model a map containing arbitrary data - used to pass information between template calls
 :)
 declare function  app:instance($node as node(), $model as map(*)) {
    try {
    let $schema := request:get-parameter('schema', '')
    let $doc:= doc($schema)
    let $root := $doc//*[@name eq request:get-parameter('name', '') and local-name(.) eq request:get-parameter('type', '')]
    let $elem := util:serialize(s2instance:process-node($root, $doc),"method=xml")
    return <div class="code" data-language="xml">
            { replace($elem, "^\s+", "") }
            </div>
 } catch * { <div class="alert alert-error">Problem in the processing of this XML Schema</div>}
 };
