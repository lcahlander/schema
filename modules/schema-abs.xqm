xquery version "3.0";

module namespace s2abs="http://greatlinkup.com/apps/schema/schema2abs";

declare namespace xs="http://www.w3.org/2001/XMLSchema";

declare function s2abs:process-node($node as node()?, $model as map()) {
    if ($node) then 
    typeswitch($node) 
        case text() return $node
        case element(xs:import) return s2abs:import($node, $model)
        case element(xs:include) return s2abs:import($node, $model)
        default return element { $node/name() } { $node/@*, s2abs:recurse($node, $model) }
 
    else () 
};

declare function s2abs:recurse($node as node()?, $model as map()) as item()* {
    if ($node) then for $cnode in $node/node() return s2abs:process-node($cnode, $model) else ()
};

declare function s2abs:import($node as node(), $model as map()) {
    (: Attributes:
        namespace
        schemaLocation
   Child Elements:

 :)
element { $node/name() } { 
                for $attr in $node/@*
                return typeswitch($attr)
                    case $sloc as attribute(schemaLocation) return attribute { 'schemaLocation' } { $model('base') || $sloc }
                    default return $attr, 
                    s2abs:recurse($node, $model) }
};

declare function s2abs:include($node as node(), $model as map()) {
    (: Attributes:
        schemaLocation
   Child Elements:

 :)
element { $node/name() } { $node/@*, s2abs:recurse($node, $model) } 
};
