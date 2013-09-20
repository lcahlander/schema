xquery version "3.0";

import module namespace request="http://exist-db.org/xquery/request";
import module namespace xdb = "http://exist-db.org/xquery/xmldb";
import module namespace login="http://exist-db.org/xquery/login" at "resource:org/exist/xquery/modules/persistentlogin/login.xql";

import module namespace restxq="http://exist-db.org/xquery/restxq" at "modules/restxq.xql";
import module namespace demo="http://greatlinkup.com/apps/schema/restxq" at "modules/restxq-demo.xql";

declare variable $exist:path external;
declare variable $exist:resource external;
declare variable $exist:controller external;
declare variable $exist:prefix external;
declare variable $exist:root external;

declare variable $local:login_domain := "com.greatlinkup.schema";
declare variable $local:user := $local:login_domain || '.user';

let $logout := request:get-parameter("logout", ())
let $set-user := login:set-user($local:login_domain, (), false())

return
if ($exist:path eq "") then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="{concat(request:get-uri(), '/')}"/>
    </dispatch>

else if (($exist:path eq "/") or ($exist:path eq "/index.html")) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="schemas/stable"/>
    </dispatch>

else if ($exist:path eq "/schemas") then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="schemas/stable"/>
    </dispatch>
else if (starts-with($exist:path, '/resources')) then
    (: everything else is passed through :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <cache-control cache="yes"/>
    </dispatch>
else if (index-of(('upload.html', 'filter2.html', 'start-sprint.html'), $exist:resource)) then
    if (request:get-attribute("com.greatlinkup.schema.user")) then
    (: the html page is run through view.xql to expand templates :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <view>
            <forward url="{$exist:controller}/modules/view.xql"/>
        </view>
		<error-handler>
			<forward url="{$exist:controller}/error-page.html" method="get"/>
			<forward url="{$exist:controller}/modules/view.xql"/>
		</error-handler>
    </dispatch>
    else
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <!-- This forwards the entry to the content page blog.html -->
        <forward url="{$exist:controller}/restricted.html"/>
        <!-- This send the page through the templating process -->
        <view>
            <forward url="{$exist:controller}/modules/view.xql">
                <set-attribute name="$exist:prefix" value="{$exist:prefix}"/>
                <set-attribute name="$exist:controller" value="{$exist:controller}"/>
            </forward>
        </view>
        <error-handler>
            <forward url="{$exist:controller}/error-page.html" method="get"/>
            <forward url="{$exist:controller}/modules/view.xql"/>
        </error-handler>
    </dispatch>
else if (ends-with($exist:resource, ".html")) then
    (: the html page is run through view.xql to expand templates :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <view>
            <forward url="{$exist:controller}/modules/view.xql">
                <set-attribute name="$exist:path" value="{$exist:path}"/>
                <set-attribute name="$exist:resource" value="{$exist:resource}"/>
                <set-attribute name="$exist:root" value="{$exist:root}"/>
                <set-attribute name="$exist:prefix" value="{$exist:prefix}"/>
                <set-attribute name="$exist:controller" value="{$exist:controller}"/>
            </forward>
        </view>
		<error-handler>
			<forward url="{$exist:controller}/error-page.html" method="get"/>
			<forward url="{$exist:controller}/modules/view.xql"/>
		</error-handler>
    </dispatch>
else if (starts-with($exist:path, ("/upload", "/data-set", "/data-sets", "/xforms", "/schema/", "/start-sprint", "/filter", '/changelog', '/cl-search'))) then
    let $functions := util:list-functions("http://greatlinkup.com/apps/schema/restxq")
    return
        (: All URL paths are processed by the restxq module :)
        restxq:process($exist:path, $functions)
else if (contains($exist:path, '/doc')) then
let $sections := tokenize($exist:path, '/')
let $sprint := if ($sections[3])  then $sections[3] else 'stable'
let $schema := if ($sections[4])  then $sections[4] else 'CDXF_EIM.xsd'
return if ($sections[5]) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <!-- This forwards the entry to the content page blog.html -->
        <forward url="{$exist:controller}/documentation2.html">
            <add-parameter name="sprint" value="{$sprint}"/>
            <add-parameter name="schema" value="{$schema}"/>
            <add-parameter name="type" value="{$sections[5]}"/>
            <add-parameter name="entity" value="{$sections[6]}"/>
        </forward>
        <!-- This send the page through the templating process -->
        <view>
            <forward url="{$exist:controller}/modules/view.xql">
                <set-attribute name="$exist:prefix" value="{$exist:prefix}"/>
                <set-attribute name="$exist:controller" value="{$exist:controller}"/>
                <add-parameter name="sprint" value="{$sprint}"/>
                <add-parameter name="schema" value="{$schema}"/>
            <add-parameter name="type" value="{$sections[5]}"/>
            <add-parameter name="entity" value="{$sections[6]}"/>
            </forward>
        </view>
        <error-handler>
            <forward url="{$exist:controller}/error-page.html" method="get"/>
            <forward url="{$exist:controller}/modules/view.xql"/>
        </error-handler>
    </dispatch>
    else
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <!-- This forwards the entry to the content page blog.html -->
        <forward url="{$exist:controller}/documentation.html">
            <add-parameter name="sprint" value="{$sprint}"/>
            <add-parameter name="schema" value="{$schema}"/>
        </forward>
        <!-- This send the page through the templating process -->
        <view>
            <forward url="{$exist:controller}/modules/view.xql">
                <set-attribute name="$exist:prefix" value="{$exist:prefix}"/>
                <set-attribute name="$exist:controller" value="{$exist:controller}"/>
                <add-parameter name="sprint" value="{$sprint}"/>
                <add-parameter name="schema" value="{$schema}"/>
            </forward>
        </view>
        <error-handler>
            <forward url="{$exist:controller}/error-page.html" method="get"/>
            <forward url="{$exist:controller}/modules/view.xql"/>
        </error-handler>
    </dispatch>
(: Resource paths starting with $shared are loaded from the shared-resources app :)
else if (contains($exist:path, "/$shared/")) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="/shared-resources/{substring-after($exist:path, '/$shared/')}">
            <set-header name="Cache-Control" value="max-age=3600, must-revalidate"/>
        </forward>
    </dispatch>
else
    (: everything else is passed through :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <cache-control cache="yes"/>
    </dispatch>
