xquery version "3.0";

(: 
 : Defines all the RestXQ endpoints used by the XForms.
 :)
module namespace eim="http://greatlinkup.com/apps/schema/restxq";

import module namespace mvf="http://greatlinkup.com/apps/schema/file" at "mvfile.xqm";
import module namespace config="http://greatlinkup.com/apps/schema/config" at "config.xqm";
import module namespace s2abs="http://greatlinkup.com/apps/schema/schema2abs" at "schema-abs.xqm";
import module namespace sutil="http://greatlinkup.com/apps/schema/sprint-util" at 'sprint-utils.xqm';
import module namespace functx="http://www.functx.com" at "functx.xqm";

declare namespace rest="http://exquery.org/ns/restxq";
declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace xs="http://www.w3.org/2001/XMLSchema";
declare namespace xf="http://www.w3.org/2002/xforms";
declare namespace ev="http://www.w3.org/2001/xml-events";
declare namespace bfc="http://betterform.sourceforge.net/xforms/controls";
declare namespace bf="http://betterform.sourceforge.net/xforms";
declare namespace w="http://niem.gov/niem/wantlist/1";

declare variable $exist:path external;
declare variable $exist:resource external;
declare variable $exist:controller external;
declare variable $exist:prefix external;
declare variable $exist:root external;

(:~
 : List all addresses and return them as XML.
 :)
declare
    %rest:PUT("{$content}")
    %rest:path("/upload")
    %rest:produces("application/xml", "text/xml")
function eim:upload-document($content as node()*) {
    let $foo := util:log-app('info', 'eim', concat('uploaded ', util:unescape-uri($content/data/file/text(), "UTF-8")))
    let $bar := mvf:move-to-db(sutil:control-dir('working'), util:unescape-uri($content/data/file/text(), "UTF-8"))
(:    let $baz := e2b:generate-canonical-bases()
:)    return <foo/>
};

(:~
 : List all addresses and return them as XML.
 :)
declare
    %rest:GET
    %rest:path("/start-sprint")
function eim:start-sprint() {
    let $foo := util:log-app('info', 'eim', 'starting new sprint')
    let $sprints :=  sutil:sprint-sequence-descending()
    let $next-sprint :=  sutil:next-sprint($sprints[1])
    let $aaa := xmldb:create-collection($config:data-root, $next-sprint)
    let $baz := xmldb:copy(sutil:control-dir($sprints[1]), $config:data-root || '/' || $next-sprint )
    let $baz := xmldb:copy(sutil:examples-dir($sprints[1]), $config:data-root || '/' || $next-sprint )
    let $baz := xmldb:copy(sutil:schema-dir($sprints[1]), $config:data-root || '/' || $next-sprint )
    let $bar := response:redirect-to(xs:anyURI('index.html'))
    return <foo/>
};

declare
    %rest:GET
    %rest:path("/filter-load")
    %rest:produces("application/xml", "text/xml")
function eim:get-filter() {
    let $filtered-items := doc(sutil:control-dir('working') || '/EIMFilteredList.xml')//w:Element/@w:name/string()
    let $full-items := doc(sutil:control-dir('working') || '/CDXF_EIM_Full.xsd')/xs:schema/xs:element/@name/string()
    let $remaining-items := distinct-values($full-items[not(.=$filtered-items)])
    return 
        <data>
            <code-table-id/>
            <available-id/>
            <left-list>{
                for $item in $filtered-items
                order by lower-case($item)
                return <item>{$item}</item>
            }</left-list>
            <right-list>{
                for $item in $remaining-items
                order by lower-case($item)
                return <item>{$item}</item>
            }</right-list>
        </data>

};

(:~
 : Update an existing address or store a new one. The address XML is read
 : from the request body.
 :)
declare
    %rest:PUT("{$content}")
    %rest:path("/filter-save")
function eim:filter-save($content as node()*) {
    let $items := $content//left-list/item/text()
    let $data := <w:wantlist xmlns:w="http://niem.gov/niem/wantlist/1" w:release="6.3" w:product="CDXF">{
                    for $item in $items
                    order by lower-case($item)
                    return <w:Element w:name="{$item}"/>
                }</w:wantlist>
    let $stored := xmldb:store(sutil:control-dir('working'), "EIMFilteredList.xml", $data)
    return
        eim:get-filter()
};

(:~
 : List all addresses and return them as XML.
 :)
declare
    %rest:GET
    %rest:path("/data-sets/{$group}")
    %rest:produces("application/xml", "text/xml")
function eim:data-sets($group as xs:string?) {
    let $foo := util:log-app('info', 'eim', concat('data-sets ', util:unescape-uri(sutil:examples-dir('stable') || ":" || $group, "UTF-8")))
    return
    <data-sets>
    {
        for $data-set in collection(sutil:examples-dir('stable'))/data-set[string(@name) = $group]
        return
            $data-set
    }
    </data-sets>
};

(:~
 : List all addresses and return them as XML.
 :)
declare
    %rest:GET
    %rest:path("/schema/{$sprint}/{$schema}")
    %rest:produces("application/xml", "text/xml")
function eim:schema($sprint as xs:string?, $schema as xs:string?) {
    if (($sprint = 'working') or ($sprint = 'stable'))
    then
        let $doc := doc(sutil:schema-dir($sprint) || '/' || $schema)
        return s2abs:process-node($doc/xs:schema, map:entry('base', 'http://localhost:8080/exist/apps/eim/schema/' || $sprint || '/' ))
    else 
        let $response := response:set-status-code(403)
        return ()
};

declare function eim:get-bind($node as node())
{
    if ($node/@type)
    then if (starts-with($node/@type, 'xs'))
    then
        element { "xf:bind" } {
            attribute { 'nodeset' } { "//data-set/" || $node/@name },
            attribute { 'type' } {$node/@type}
        }
    else
        element { "xf:bind" } {
            attribute { 'nodeset' } { "//data-set/" || $node/@name },
            attribute { 'type' } {$node/root()//xs:simpleType[@name eq $node/@type]/xs:restriction/@base}
        }
    else
        element { "xf:bind" } {
            attribute { 'nodeset' } { "//data-set/" || $node/@name },
            attribute { 'type' } {$node/xs:simpleType/xs:restriction/@base}
        }
};


declare
    %rest:GET
    %rest:path("/xforms/{$group}")
    %rest:produces("application/xml", "text/xml")
function eim:manage-data-set($group as xs:string?) {
    let $groupData := doc(sutil:examples-dir('stable') || '/CDXF_EIM.xsd')/xs:schema/xs:group[string(@name) eq $group]
    let $groupNames := $groupData/xs:sequence/xs:element/@name/string()    
    return
<div xmlns="http://www.w3.org/1999/xhtml" xmlns:ev="http://www.w3.org/2001/xml-events" xmlns:xf="http://www.w3.org/2002/xforms" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    <xf:model>
        <xf:instance xmlns="" id="all">
            <data-sets>
            </data-sets>
        </xf:instance>
        <xf:instance xmlns="" id="template">
            <data-set name="{$group}">
            {for $element-name in $groupData/xs:sequence/xs:element/@name/string()
                return element { $element-name } {}
                }
            </data-set>
        </xf:instance>
        {for $element in $groupData/xs:sequence/xs:element[@name] return eim:get-bind($element)}
        <xf:bind id="data-id" nodeset="//data-set/@id" relevant="true()"/>
        <xf:submission id="load" resource="data-sets/{$group}" method="get" replace="instance">
            <xf:message ev:event="xforms-submit-done" level="ephemeral">Address list loaded.</xf:message>
        </xf:submission>
        <xf:submission id="save" resource="data-set" method="put" replace="instance" ref="//data-set[index('data-set-repeat')]">
            <xf:message ev:event="xforms-submit-done" level="ephemeral">Address saved.</xf:message>
            <xf:message ev:event="xforms-submit-error" level="ephemeral">An error occurred.</xf:message>
        </xf:submission>
        <xf:action ev:event="xforms-ready">
            <xf:send submission="load"/>
        </xf:action>
    </xf:model>
    <div class="row-fluid">
        <div class="col-lg-12">
            <div class="page-header">
                <h1 data-template="config:app-title">Generated page</h1>
            </div>
            <div class="row-fluid">
                <h2>Manage <span data-template="app:group-name"/></h2>
                <table class="table">
                <thead>
                    <th>{$groupNames[1]}</th>
                    <th>{$groupNames[2]}</th>
                    <th>{$groupNames[3]}</th>
                </thead>
                <tbody id="data-set-repeat" xf:repeat-nodeset="//data-set">
                    <tr>
                        <td>
                            <xf:output ref="{$groupNames[1]}"/>
                        </td>
                        <td>
                            <xf:output ref="{$groupNames[2]}"/>
                        </td>
                        <td>
                            <xf:output ref="{$groupNames[3]}"/>
                        </td>
                    </tr>
                </tbody>
            </table>
            <xf:group appearance="minimal" class="action-buttons">
                <xf:submit submission="delete">
                    <xf:label>Delete</xf:label>
                </xf:submit>
                <xf:trigger>
                    <xf:label>New</xf:label>
                    <xf:action>
                        <xf:insert nodeset="instance('all')//data-set" at="last()"
                            position="after" origin="instance('template')"/>
                    </xf:action>
                </xf:trigger>
            </xf:group>
            <xf:group ref="//data-set[index('data-set-repeat')]" appearance="full" class="edit">
            {for $name in $groupNames
            return
                element { "xf:input" } {
                            attribute { "ref" } { $name },
                            element { 'xf:label' } { $name || ": " }
                            }}
            </xf:group>
            <xf:submit submission="save">
                <xf:label>Save</xf:label>
            </xf:submit>
            </div>
        </div>
    </div>
</div>
};

(:~
 : Retrieve an address identified by uuid.
 :)
declare 
    %rest:GET
    %rest:path("/data-set/{$id}")
function eim:get-data-set($id as xs:string*) {
    collection(sutil:examples-dir('stable'))/data-set[@id = $id]
};

(:~
 : Update an existing address or store a new one. The address XML is read
 : from the request body.
 :)
declare
    %rest:PUT("{$content}")
    %rest:path("/data-set")
function eim:create-or-edit-data-set($content as node()*) {
    let $id := ($content/data-set/@id, util:uuid())[1]
    let $group := $content/data-set/@name
    let $data :=
        <data-set name="{$group}" id="{$id}">
        { $content/data-set/* }
        </data-set>
    let $log := util:log("DEBUG", "Storing data into /db/apps/eim/data/S-6-3/examples")
    let $stored := xmldb:store(sutil:examples-dir('stable'), $id || ".xml", $data)
    return
        eim:data-sets($group)
};

(:~
 : Delete an address identified by its uuid.
 :)
declare
    %rest:DELETE
    %rest:path("/data-set/{$id}")
function eim:delete-data-set($id as xs:string*) {
    let $path := sutil:examples-dir('stable') || '/' || $id || ".xml"
    let $group := doc($path)/@name/string()
    let $deleted := xmldb:remove(sutil:examples-dir('stable'), $id || ".xml")
    return eim:data-sets($group)
};

(:~
 : List all changelogs and return them as XML.
 :)
declare
    %rest:GET
    %rest:path("/changelog")
    %rest:produces("application/xml", "text/xml")
function eim:changelog() {
    <log-entries>
    {
        for $address in collection($config:data-root || "/changelog")/changelog
        return
            $address
    }
    </log-entries>
};

(:~
 : Retrieve an changelog identified by uuid.
 :)
declare 
    %rest:GET
    %rest:path("/changelog/{$id}")
function eim:get-changelog($id as xs:string*) {
    collection($config:data-root || "/changelog")/changelog[@id = $id]
};

(:~
 : Search changelog using a given field and a (lucene) query string.
 :)
declare 
    %rest:GET
    %rest:path("/cl-search")
    %rest:form-param("query", "{$query}", "")
    %rest:form-param("field", "{$field}", "name")
function eim:search-changelog($query as xs:string*, $field as xs:string*) {
    <log-entries>
    {
        if ($query != "") then
            switch ($field)
                case "name" return
                    collection($config:data-root || "/changelog")/changelog[ngram:contains(name, $query)]
                case "street" return
                    collection($config:data-root || "/changelog")/changelog[ngram:contains(street, $query)]
                case "city" return
                    collection($config:data-root || "/changelog")/changelog[ngram:contains(city, $query)]
                default return
                    collection($config:data-root || "/changelog")/changelog[ngram:contains(., $query)]
        else
            collection($config:data-root || "/changelog")/changelog
    }
    </log-entries>
};

(:~
 : Update an existing changelog or store a new one. The changelog XML is read
 : from the request body.
 :)
declare
    %rest:PUT("{$content}")
    %rest:path("/changelog")
function eim:create-or-edit-changelog($content as node()*) {
    
    let $id := ($content/changelog/@id, util:uuid())[1]
    let $data := if ($content/changelog/@id)
        then $content/changelog
        else element { "changelog" } {
            attribute { 'id' } { $id },
            $content/changelog/schema,
            element { 'timestamp' } { util:system-dateTime() },
            element { 'user' } { if (request:get-attribute("com.greatlinkup.schema.user")) then request:get-attribute("com.greatlinkup.schema.user") else 'guest' },
            $content/changelog/div
            }
    let $log := util:log("DEBUG", "Storing data into " || $config:data-root || "/changelog")
    let $stored := system:as-user('admin', 'FOO',xmldb:store($config:data-root || "/changelog", $id || ".xml", $data))
    return
        eim:changelog()
};

(:~
 : Delete an changelog identified by its uuid.
 :)
declare
    %rest:DELETE
    %rest:path("/changelog/{$id}")
function eim:delete-changelog($id as xs:string*) {
    system:as-user('admin', 'hen3ry',xmldb:remove($config:data-root || "/changelog", $id || ".xml")),
    eim:changelog()
};
