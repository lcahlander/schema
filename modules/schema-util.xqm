xquery version "3.0";

module namespace s2util="http://greatlinkup.com/ns/schema-util";

import module namespace config="http://exist-db.org/apps/schema/config" at "config.xqm";
import module namespace  functx = "http://www.functx.com" at "functx.xqm";

(:
declare default element namespace "http://www.w3.org/2001/XMLSchema";
:)

declare function s2util:schema-from-prefix($name as xs:string, $doc as node()) as node()
{
    if ($name and contains($name, ':'))
    then try {
        let $namespace-uri := namespace-uri-from-QName(resolve-QName($name, $doc/xs:schema))
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
            } catch * { $doc }
     else $doc
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

(:~
 :  This function takes an XML Schema and generates the source 
 :  to an XQuery function module to run a typeswitch transform  
 :  on all of the elements of an XML fragment that adheres to
 :  the specified XML Schemas.
 :   
 : @author  Loren Cahlander, GreatLinkUp, LLC 
 : @version 1.0 
 : @param   schema-path the URI to the XML Schema to be processed 
 : @param   $prefix an xs:string with the prefix used for the function module
 : @param   $moduleNamespace The namespace to be given to the generated XQuery function module 
 :)
declare function s2util:generate-typeswitch-transform($schema-path as xs:anyURI, $prefix as xs:string, $moduleNamespace as xs:string) as xs:string {
    let $nl := "&#10;"
    let $doc := doc($schema-path)
    let $names := distinct-values($doc//xs:element/@name/string())
    let $cnames := string-join(for $cname in $names
                    return concat('        case element(xs:', $cname, ') return ', $prefix, ':', $cname, '($node, $doc)', $nl))
    let $main := concat('xquery version "3.0";', $nl, $nl,
     'module namespace ', $prefix, '="', $moduleNamespace ,'";', $nl, $nl,
     'declare %public function ', $prefix, ':process-node($node as node(), $doc as node()) {', $nl,
    '    if ($node) then ', $nl,
    '    typeswitch($node) ', $nl,
    '        case text() return $node ', $nl, $cnames,
    '        default return ', $prefix, ':recurse($node, $doc) ', $nl,
    '    else () ', $nl,
     '};', $nl, $nl,
    'declare function ', $prefix, ':recurse($node as node()?, $doc as node()) as item()* {', $nl,
    '    if ($node) then for $cnode in $node/node() return ', $prefix, ':process-node($cnode, $doc) else ()', $nl,
    '};', $nl, $nl
     )
    let $enames := for $name in $names
                        let $child-names := for $element in $doc//xs:element[@name eq $name]
                                    return
                                        for $child in $element//xs:element
                                                                return if ($child/@ref) then substring-after($child/string(@ref), ':') else $child/string(@name)
                             let $subelements := string-join(for $child-name in distinct-values($child-names)
                                                            order by $child-name
                                                            return concat('case element(', $child-name ,') return ', $prefix, ':', $child-name, '($node, $doc)', $nl))
                        order by $name
                        return if ($subelements)
                                then concat('declare %public function ', $prefix, ':', $name, '($node as node(), $doc as node()) {', $nl, "    ', $prefix, ':recurse($node, $doc)", $nl, '};', $nl)
                                else concat('declare %public function ', $prefix, ':', $name, '($node as node(), $doc as node()) {', $nl, "    ()", $nl, '};', $nl)
    return
        concat($main, string-join($enames, $nl))
};