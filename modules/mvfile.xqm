xquery version "3.0";

module namespace f="http://greatlinkup.com/apps/schema/file";

import module namespace config="http://greatlinkup.com/apps/schema/config" at "config.xqm";
import module namespace file="http://exist-db.org/xquery/file";

declare function f:meta-doc($collection as xs:string) as node()
{
    let $file-path := concat($config:data-root, '/', $collection, '/config.xml')
    return if (doc-available($file-path))
            then doc($file-path)
            else 
                let $foo:= xmldb:store(concat($config:data-root, '/', $collection), 'config.xml', <schemas/>)
                return doc($file-path)
};

declare function f:add-schema($collection as xs:string, $schema as node()) as node()
{
    let $doc := f:meta-doc($collection)
    let $prefixes := in-scope-prefixes($schema)
    let $namespace := $schema/@targetNamespace/string()
    let $foo := for $prefix in $prefixes
                    let $namespaceURI := namespace-uri-for-prefix($prefix, $schema)
                    let $import := $schema//xs:import[@namespace/string() = $namespaceURI]
                    return if ($doc//schema-entry[schema/namespace/text() = $namespaceURI])
                    then if (not($doc//schema-entry/schema[namespace/text() = $namespaceURI]/prefix/node()))
                        then update replace $doc//schema-entry/schema[namespace/text() = $namespaceURI]/prefix with <prefix>{$prefix}</prefix>
                        else ()
                    else 
                    let $bar := update insert
                <schema-entry used="false">
                    <module>
                        <prefix></prefix>
                        <namespace></namespace>
                    </module>
                    <schema>
                        <prefix>{$prefix}</prefix>
                        <namespace>{$namespaceURI}</namespace>
                        <location>{$import/@schemaLocation/string()}</location>
                        <include></include>
                        <import></import>
                    </schema>
                </schema-entry>
            into $doc/schemas
            return ()
    return $doc
};

declare function f:move-to-db($collection as xs:string, $path as xs:string) as xs:boolean
{
    let $foo := util:log-app('info', 'xfupload', concat('moved file ', $path))
     let $segment := substring-after($path, 'upload/')
    return system:as-user('admin', 'FOO',
     try {
     let $file-path := concat(system:get-exist-home(), '/webapp/upload/', $segment)
    let $foo := util:log-app('info', 'xfupload', concat('moved file ', $file-path))
        let $exists := file:exists($file-path)
        let $vv := util:log-app('info', 'xfupload', concat('exists:  ', $exists))
        return if ($exists) 
                then if (ends-with($file-path, ".xsd"))
                    then 
                        let $contents := util:parse(file:read($file-path))
                        let $stored := xmldb:store($collection, substring-after($segment, '/'), $contents)
                        let $deleted := file:delete($file-path)
                        return true()
                    else
                        let $deleted := file:delete($file-path)
                        return true()
                else true()
    } catch * {
        true()
    })
};
