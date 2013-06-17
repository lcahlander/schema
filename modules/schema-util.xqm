xquery version "3.0";

module namespace s2util="http://greatlinkup.com/ns/schema-util";

import module namespace config="http://exist-db.org/apps/schema/config" at "config.xqm";

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
    return if ($length) then substring($test[$pos]/text(), 1, util:random($length)) else $test[$pos]/text()
};