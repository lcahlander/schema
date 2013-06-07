xquery version "3.0";

module namespace app="http://exist-db.org/apps/schema/templates";

declare namespace xs="http://www.w3.org/2001/XMLSchema";

import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace config="http://exist-db.org/apps/schema/config" at "config.xqm";
import module namespace s2svg="http://greatlinkup.com/ns/schema2svg" at "schema2svg.xqm";
import module namespace s2svgdim="http://greatlinkup.com/ns/schema2svgdim" at "schema2svgdim.xqm";
import module namespace s2bootstrap="http://greatlinkup.com/ns/schema2bootstrap" at "schema2bootstrap.xqm";

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
                            return s2bootstrap:documentation($note, $doc)
    
    return
    (<h2>{$schema}</h2>,
    $documentation,
    <h3>Imports</h3>,
    for $element in $doc/*/xs:import
    return s2bootstrap:import($element, $doc),
    <h3>Items</h3>,
    for $element in $doc/*/*[@name]
    return s2bootstrap:display-list-item($element, $doc))
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
    
    return (<h2>{$root/local-name()}: {$root/@name/string()}</h2>,
            s2bootstrap:process-node($root, $doc))
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
    
    return s2svg:svg($root, $doc)
};

 (:~
 : This templating function displays the XML Schema item's graphical view dimensions in SVG. It will be called by the templating module if
 : it encounters an HTML element with a class attribute: class="app:svgdim".
 : 
 : @param $node the HTML node with the class attribute which triggered this call
 : @param $model a map containing arbitrary data - used to pass information between template calls
 :)
 declare function  app:svgdim($node as node(), $model as map(*)) {

    let $schema := request:get-parameter('schema', '')
    let $doc:= doc($schema)
    let $root := $doc//*[@name eq request:get-parameter('name', '') and local-name(.) eq request:get-parameter('type', '')]
    let $dim := s2svgdim:process-node($root, 3)
    
    return <div class="alert alert-success">X: {$dim//x/text()} Y: {$dim//y/text()}</div>
};
