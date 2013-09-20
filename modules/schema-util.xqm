xquery version "3.0";

module namespace s2util="http://greatlinkup.com/apps/schema/schema-util";

import module namespace config="http://greatlinkup.com/apps/schema/config" at "config.xqm";
import module namespace  functx = "http://www.functx.com" at "functx.xqm";

(:
declare default element namespace "http://www.w3.org/2001/XMLSchema";
:)

declare function s2util:schema-from-prefix($name as xs:string, $doc as node()) as node()
{
    let $qname := resolve-QName($name, $doc/xs:schema)
    let $namespace-uri := namespace-uri-from-QName($qname)
    return if ($doc/namespace-uri() eq $namespace-uri)
            then $doc
            else
    let $import := $doc/*/xs:import[@namespace eq string($namespace-uri)]
    return 
        if ($import) 
        then 
            let $schemaLocation := string($import/@schemaLocation)
            let $fullURI := resolve-uri($schemaLocation, base-uri($doc))
            return doc($fullURI)
        else $doc
};

declare function s2util:item-from-qname($name as xs:string, $doc as node()) as node()
{
    let $qname := resolve-QName($name, $doc/xs:schema)
    let $eDoc := s2util:schema-from-prefix($name, $doc)
    return $eDoc//*[string(@name) eq local-name-from-QName($qname)][1]
};

declare function s2util:generate-lorumipsum($length as xs:integer) as xs:string
{
    let $test := doc(concat($config:data-root, '/Latin-Lipsum.xml'))/body/p
    let $pos := util:random(103)
    return functx:left-trim(if ($length) 
                            then 
                                let $half := $length div 2
                            return substring($test[$pos]/text(), 1, (util:random($half) + $half)) 
                            else $test[$pos]/text())
};

declare %private function s2util:child-names($node as node()) as xs:string*
{
    for $child in $node//element
        return if ($child/@ref) then substring-after($child/string(@ref), ':') else $child/string(@name)
};

(:~
 :  This function takes an XML Schema and generates the source 
 :  to an XQuery function module to run a typeswitch transform  
 :  on all of the elements of an XML fragment that adheres to
 :  the specified XML Schemas.
 :   
 : @author  Loren Cahlander, GreatLinkUp, LLC 
 : @version 1.0 
 : @param   $schemaPath the URI to the XML Schema to be processed 
 : @param   $schemaPrefix an xs:string with the prefix used for the schema elements
 : @param   $schemaNamespace The namespace of the schema 
 : @param   $modulePrefix an xs:string with the prefix used for the function module
 : @param   $moduleNamespace The namespace to be given to the generated XQuery function module 
 :)
declare function s2util:generate-typeswitch-transform($schemaPath as xs:anyURI, $schemaPrefix as xs:string, $schemaNamespace as xs:string, $modulePrefix as xs:string, $moduleNamespace as xs:string) as xs:string {
    let $nl := "&#10;"
    let $doc := doc($schemaPath)
    let $names := distinct-values($doc//element/@name/string())
    let $cnames := string-join(for $cname in $names
                                order by $cname
                    return concat('        case element(', $schemaPrefix, ':', $cname, ') return ', $modulePrefix, ':', $cname, '($node, $model)', $nl))
    let $main := concat('xquery version "3.0";', $nl, $nl,
     'module namespace ', $modulePrefix, '="', $moduleNamespace ,'";', $nl, $nl,
     'declare namespace ', $schemaPrefix, '="', $schemaNamespace, '";', $nl, $nl,
     'declare %public function ', $modulePrefix, ':process-node($node as node()?, $model as map()) {', $nl,
    '    if ($node) then ', $nl,
    '    typeswitch($node) ', $nl,
    '        case text() return $node ', $nl, $cnames,
    '        default return ', $modulePrefix, ':recurse($node, $model) ', $nl,
    '    else () ', $nl,
     '};', $nl, $nl,
    'declare function ', $modulePrefix, ':recurse($node as node()?, $model as map()) as item()* {', $nl,
    '    if ($node) then for $cnode in $node/node() return ', $modulePrefix, ':process-node($cnode, $model) else ()', $nl,
    '};', $nl, $nl
     )
    let $enames := for $name in $names
                        let $child-names := for $element in $doc//element[@name eq $name]
                                return s2util:child-names( if ($element/@type)
                                        then s2util:item-from-qname($element/@type/string(), $doc)
                                        else $element)
                             let $subelements := concat("(: Child Elements:", $nl, string-join(for $child-name in distinct-values($child-names)
                                                            order by $child-name
                                                            return concat('        ', $child-name), $nl), $nl,
                                                        " :)", $nl)
                        order by $name
                        return if (count($child-names) > 0)
                                then concat('declare %public function ', $modulePrefix, ':', $name, '($node as node(), $model as map()) {', $nl, "    ", $subelements, $modulePrefix, ":recurse($node, $model)", $nl, '};', $nl)
                                else concat('declare %public function ', $modulePrefix, ':', $name, '($node as node(), $model as map()) {', $nl, "    ()", $nl, '};', $nl)
    return
        concat($main, string-join($enames, $nl))
};