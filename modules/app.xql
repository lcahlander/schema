xquery version "3.0";

module namespace app="http://exist-db.org/apps/schema/templates";

declare namespace xs="http://www.w3.org/2001/XMLSchema";

import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace config="http://exist-db.org/apps/schema/config" at "config.xqm";
import module namespace s2svg="http://greatlinkup.com/ns/schema2svg" at "schema2svg.xqm";

declare function local:escape-for-regex 
  ( $arg as xs:string? )  as xs:string {
       
   replace($arg,
           '(\.|\[|\]|\\|\||\-|\^|\$|\?|\*|\+|\{|\}|\(|\))','\\$1')
 } ;
 
declare function local:substring-before-last 
  ( $arg as xs:string? ,
    $delim as xs:string )  as xs:string {
       
   if (matches($arg, local:escape-for-regex($delim)))
   then replace($arg,
            concat('^(.*)', local:escape-for-regex($delim),'.*'),
            '$1')
   else ''
 } ;
 
 declare function  app:svg($node as node(), $model as map(*)) {

    let $schema := request:get-parameter('schema', '')
    let $doc:= doc($schema)
    let $root := $doc//*[@name eq request:get-parameter('name', '') and local-name(.) eq request:get-parameter('type', '')]
    
    return s2svg:svg($root, $doc)
};
 (:~
 : This is a sample templating function. It will be called by the templating module if
 : it encounters an HTML element with a class attribute: class="app:test". The function
 : has to take exactly 3 parameters.
 : 
 : @param $node the HTML node with the class attribute which triggered this call
 : @param $model a map containing arbitrary data - used to pass information between template calls
 :)
declare function app:test($node as node(), $model as map(*)) {

    let $schema := request:get-parameter('schema', '')
    let $doc:= doc($schema)
    
    return
    (<div class="alert alert-success">{$doc/*/xs:annotation/xs:documentation}</div>,
<table class="table table-striped">{
        for $element in $doc/*/xs:import
        let $namespace := string($element/@namespace)
        let $schemaLoc := string($element/@schemaLocation)
        let $absURI := resolve-uri($schemaLoc, $schema)
        return <tr>
                    <td>{$namespace}</td>
                    <td><a href="index.html?schema={$absURI}">{$absURI}</a></td>
               </tr>
}</table>,
<table class="table table-striped">{
        for $element in $doc/*/*[@name]
        return <tr>
                    <td>{string($element/local-name())}</td>
                    <td><a href="item.html?schema={request:get-parameter('schema', '')}&amp;type={string($element/local-name())}&amp;name={string($element/@name)}">{string($element/@name)}</a></td>
                    <td>{$element/xs:annotation/xs:documentation}</td>
                </tr>
}</table>)
};

declare %private function app:schema-from-prefix($name as xs:string, $doc as node()) as node()
{
    let $namespace-uri := namespace-uri-from-QName(resolve-QName($name, $doc/xs:schema))
    let $import := $doc/*/xs:import[@namespace eq string($namespace-uri)]
    return if ($import) then 
    let $schemaLocation := string($import/@schemaLocation)
    let $fullURI := concat(local:substring-before-last(base-uri($doc), '/'), '/', $schemaLocation)
    return doc($fullURI)
     else $doc
};

declare function app:extension($doc as node(), $node as node()) as item()* {
    let $base := string($node/@base)
    let $eDoc := app:schema-from-prefix($base, $doc)
    let $extension := $eDoc//*[string(@name) eq substring-after($base, ':')]
    return
        <div class="well">Extension: {$base}
        {app:display-attributes(($node, $extension))}
        {app:display-node($eDoc, $extension)}
        {app:recurse($doc, $node)}
        </div>
};

declare function app:restriction($doc as node(), $node as node()) as item()* {
    let $base := string($node/@base)
    let $eDoc := app:schema-from-prefix($base, $doc)
    let $extension := $eDoc//*[string(@name) eq substring-after($base, ':')]
    return
        <div class="well">Restriction: {$base}
        {app:display-attributes(($node, $extension))}
        {app:display-node($eDoc, $extension)}
        {app:recurse($doc, $node)}
        </div>
};

declare function app:general($doc as node(), $node as node()) as item()* {
    let $base := string($node/@base)
    return
        <div class="well">{$node/local-name()}: {$base}
        {app:display-attributes(($node))}
        {app:recurse($doc, $node)}
        </div>
};

declare function app:display-attributes($nodes as node()*) as item()* {
    for $node in $nodes
    return for $attr in $node/@*
            where ($attr/name() ne 'ref' or $attr/name() ne 'name' or $attr/name() ne 'base')
            return if ($attr/name() eq 'ref') then ()
            else if ($attr/name() eq 'name') then ()
            else if ($attr/name() eq 'base') then ()
            else if ($attr/name() eq 'type') then ()
            else (' ',<span>{$attr/name()}:{string($attr)}</span>)
};

declare function app:displayType($doc as node(), $node as node()) as item()* {
    if ($node/@type)
    then if (contains(string($node/@type), ':'))
        then
            let $base := string($node/@type)
            let $eDoc := app:schema-from-prefix($base, $doc)
            let $extension := $eDoc//*[string(@name) eq substring-after($base, ':')]
            return
                (' ', <span>Type: <a href="#">{$base}</a></span>)
        else (' ',<span>Type:{string($node/@type)}</span>)
    else ()
};

declare function app:simpleType($doc as node(), $node as node()) as item()* {
    if ($node/@ref) then
    let $base := string($node/@ref)
    let $eDoc := app:schema-from-prefix($base, $doc)
    let $extension := $eDoc//*[string(@name) eq substring-after($base, ':')]
    return
        <div class="well">SimpleType: {$base}
        {app:display-attributes(($node, $extension))}
        {app:displayType($doc, $extension)}
        {app:recurse($eDoc, $extension)}
        {app:recurse($doc, $node)}
        </div>
    else 
    let $base := string($node/@name)
    return
        <div class="well">SimpleType: {$base}
        {app:display-attributes(($node))}
        {app:displayType($doc, $node)}
        {app:recurse($doc, $node)}
        </div>
};

declare function app:complexType($doc as node(), $node as node()) as item()* {
    if ($node/@ref) then
    let $base := string($node/@ref)
    let $eDoc := app:schema-from-prefix($base, $doc)
    let $extension := $eDoc//*[string(@name) eq substring-after($base, ':')]
    return
        <div class="well">ComplexType: {$base}
        {app:display-attributes(($node, $extension))}
        {app:displayType($doc, $extension)}
        {app:recurse($eDoc, $extension)}
        {app:recurse($doc, $node)}
        </div>
    else 
    let $base := string($node/@name)
    return
        <div class="well">ComplexType: {$base}
        {app:display-attributes(($node))}
        {app:displayType($doc, $node)}
        {app:recurse($doc, $node)}
        </div>
};

declare function app:group($doc as node(), $node as node()) as item()* {
    if ($node/@ref) then
    let $base := string($node/@ref)
    let $eDoc := app:schema-from-prefix($base, $doc)
    let $extension := $eDoc//*[string(@name) eq substring-after($base, ':')]
    return
        <div class="well">Group: {$base}
        {app:display-attributes(($node, $extension))}
        {app:displayType($doc, $extension)}
        {app:recurse($eDoc, $extension)}
        {app:recurse($doc, $node)}
        </div>
    else 
    let $base := string($node/@name)
    return
        <div class="well">Group: {$base}
        {app:display-attributes(($node))}
        {app:displayType($doc, $node)}
        {app:recurse($doc, $node)}
        </div>
};

declare function app:element($doc as node(), $node as node()) as item()* {
    if ($node/@ref) then
    let $base := string($node/@ref)
    let $eDoc := app:schema-from-prefix($base, $doc)
    let $extension := $eDoc//*[string(@name) eq substring-after($base, ':')][1]
    return
        <div class="well">Element: {$base}
        {app:display-attributes(($node, $extension))}
        {app:displayType($doc, $extension)}
        {app:recurse($eDoc, $extension)}
        {app:recurse($doc, $node)}
        </div>
    else 
    let $base := string($node/@name)
    return
        <div class="well">Element: {$base}
        {app:display-attributes(($node))}
        {app:displayType($doc, $node)}
        {app:recurse($doc, $node)}
        </div>
};

declare function app:attribute($doc as node(), $node as node()) as item()* {
    if ($node/@ref) then
    let $base := string($node/@ref)
    let $eDoc := app:schema-from-prefix($base, $doc)
    let $extension := $eDoc//*[string(@name) eq substring-after($base, ':')]
    return
        <div class="well">Attribute: {$base}
        {app:display-attributes(($node, $extension))}
        {app:displayType($doc, $extension)}
        {app:recurse($eDoc, $extension)}
        {app:recurse($doc, $node)}
        </div>
    else 
    let $base := string($node/@name)
    return
        <div class="well">Attribute: {$base}
        {app:display-attributes(($node))}
        {app:displayType($doc, $node)}
        {app:recurse($doc, $node)}
        </div>
};

declare function app:display-node($doc as node(), $node as node()?) as item()* {
    if ($node) then
    typeswitch($node)
        case text() return $node
        case element(xs:documentation) return <div class="alert alert-success">{$node/text()}</div> 
        case element(xs:appinfo) return ()
        case element(xs:extension) return app:extension($doc, $node)
        case element(xs:choice) return <div class="well">Choice{app:recurse($doc, $node)}</div>
        case element(xs:sequence) return <div class="well">Sequence{app:recurse($doc, $node)}</div>
        case element(xs:complexType) return app:complexType($doc, $node)
        case element(xs:simpleType) return app:simpleType($doc, $node)
        case element(xs:restriction) return app:restriction($doc, $node)
        case element(xs:minInclusive) return app:general($doc, $node)
        case element(xs:maxExclusive) return app:general($doc, $node)
        case element(xs:element) return app:element($doc, $node)
        case element(xs:group) return app:group($doc, $node)
        case element(xs:attribute) return app:attribute($doc, $node)
        default return app:recurse($doc, $node)
    else ()
};

declare function app:display-node-content($doc as node(), $content as node()*) as item()* {
    for $node in $content
    return
        app:display-node($doc, $node)
};

declare function app:recurse($doc as node(),$node as node()?) as item()* {
    if ($node) then app:display-node-content($doc, $node/node()) else ()
};

(:~
 : This is a sample templating function. It will be called by the templating module if
 : it encounters an HTML element with a class attribute: class="app:test". The function
 : has to take exactly 3 parameters.
 : 
 : @param $node the HTML node with the class attribute which triggered this call
 : @param $model a map containing arbitrary data - used to pass information between template calls
 :)
declare function app:item-detail($node as node(), $model as map(*)) {

    let $schema := request:get-parameter('schema', '')
    let $doc:= doc($schema)
    let $root := $doc//*[@name eq request:get-parameter('name', '') and local-name(.) eq request:get-parameter('type', '')]
    
    return app:display-node($doc, $root)
};
