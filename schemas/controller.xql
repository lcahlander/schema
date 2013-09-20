xquery version "3.0";

import module namespace request="http://exist-db.org/xquery/request";
import module namespace xdb = "http://exist-db.org/xquery/xmldb";
import module namespace login="http://exist-db.org/xquery/login" at "resource:org/exist/xquery/modules/persistentlogin/login.xql";

import module namespace restxq="http://exist-db.org/xquery/restxq" at "../modules/restxq.xql";
import module namespace demo="http://greatlinkup.com/apps/schema/restxq" at "../modules/restxq-demo.xql";

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
        <redirect url="stable"/>
    </dispatch>

else if (contains($exist:path, "/$shared/")) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="/shared-resources/{substring-after($exist:path, '/$shared/')}">
            <set-header name="Cache-Control" value="max-age=3600, must-revalidate"/>
        </forward>
    </dispatch>

else if (starts-with($exist:path, "/resources")) then
    (: images, css are contained in the top /resources/ collection. :)
    (: Relative path requests from sub-collections are redirected there :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{$exist:controller}/../{$exist:path}"/>
    </dispatch>

else
let $sections := tokenize($exist:path, '/')
let $sprint := if ($sections[2])  then $sections[2] else 'stable'
return if ($sections[3]) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <!-- This forwards the entry to the content page blog.html -->
        <forward url="{$exist:controller}/../search.html">
            <add-parameter name="sprint" value="{$sprint}"/>
            <add-parameter name="q" value="{request:get-parameter('q', '')}"/>
        </forward>
        <!-- This send the page through the templating process -->
        <view>
            <forward url="{$exist:controller}/../modules/view.xql">
                <set-attribute name="$exist:prefix" value="{$exist:prefix}"/>
                <set-attribute name="$exist:controller" value="{$exist:controller}"/>
                <add-parameter name="sprint" value="{$sprint}"/>
            </forward>
        </view>
        <error-handler>
            <forward url="{$exist:controller}/../error-page.html" method="get"/>
            <forward url="{$exist:controller}/../modules/view.xql"/>
        </error-handler>
    </dispatch>
    else
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <!-- This forwards the entry to the content page blog.html -->
        <forward url="{$exist:controller}/../directory.html">
            <add-parameter name="sprint" value="{$sprint}"/>
        </forward>
        <!-- This send the page through the templating process -->
        <view>
            <forward url="{$exist:controller}/../modules/view.xql">
                <set-attribute name="$exist:prefix" value="{$exist:prefix}"/>
                <set-attribute name="$exist:controller" value="{$exist:controller}"/>
                <add-parameter name="sprint" value="{$sprint}"/>
            </forward>
        </view>
        <error-handler>
            <forward url="{$exist:controller}/../error-page.html" method="get"/>
            <forward url="{$exist:controller}/../modules/view.xql"/>
        </error-handler>
    </dispatch>
