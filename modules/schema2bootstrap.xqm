xquery version "3.0";

module namespace s2bootstrap="http://greatlinkup.com/apps/schema/schema2bootstrap";
import module namespace  functx = "http://www.functx.com" at "functx.xqm";
import module namespace s2util = "http://greatlinkup.com/apps/schema/schema-util" at "schema-util.xqm";
import module namespace sutil="http://greatlinkup.com/apps/schema/sprint-util" at 'sprint-utils.xqm';

declare namespace xs="http://www.w3.org/2001/XMLSchema";

declare function s2bootstrap:process-node($node as node()?, $model as map()) {
    if ($node) then 
    let $nl := "&#10;"
    let $log := util:log-app("info", "s2bootstrap", concat('Node: ', $nl, util:serialize($node,"method=xml")))
    return
    typeswitch($node) 
        case text() return $node 
        case element(xs:all) return s2bootstrap:all($node, $model)
        case element(xs:annotation) return s2bootstrap:annotation($node, $model)
        case element(xs:any) return s2bootstrap:any($node, $model)
        case element(xs:anyAttribute) return s2bootstrap:anyAttribute($node, $model)
        case element(xs:appinfo) return s2bootstrap:appinfo($node, $model)
        case element(xs:attribute) return s2bootstrap:attribute($node, $model)
        case element(xs:attributeGroup) return s2bootstrap:attributeGroup($node, $model)
        case element(xs:choice) return s2bootstrap:choice($node, $model)
        case element(xs:complexContent) return s2bootstrap:complexContent($node, $model)
        case element(xs:complexType) return s2bootstrap:complexType($node, $model)
        case element(xs:documentation) return s2bootstrap:documentation($node, $model)
        case element(xs:element) return s2bootstrap:element($node, $model)
        case element(xs:enumeration) return s2bootstrap:enumeration($node, $model)
        case element(xs:extension) return s2bootstrap:extension($node, $model)
        case element(xs:field) return s2bootstrap:field($node, $model)
        case element(xs:fractionDigits) return s2bootstrap:fractionDigits($node, $model)
        case element(xs:group) return s2bootstrap:group($node, $model)
        case element(xs:import) return s2bootstrap:import($node, $model)
        case element(xs:include) return s2bootstrap:include($node, $model)
        case element(xs:key) return s2bootstrap:key($node, $model)
        case element(xs:keyref) return s2bootstrap:keyref($node, $model)
        case element(xs:length) return s2bootstrap:length($node, $model)
        case element(xs:list) return s2bootstrap:list($node, $model)
        case element(xs:maxExclusive) return s2bootstrap:maxExclusive($node, $model)
        case element(xs:maxInclusive) return s2bootstrap:maxInclusive($node, $model)
        case element(xs:maxLength) return s2bootstrap:maxLength($node, $model)
        case element(xs:minExclusive) return s2bootstrap:minExclusive($node, $model)
        case element(xs:minInclusive) return s2bootstrap:minInclusive($node, $model)
        case element(xs:minLength) return s2bootstrap:minLength($node, $model)
        case element(xs:notation) return s2bootstrap:notation($node, $model)
        case element(xs:pattern) return s2bootstrap:pattern($node, $model)
        case element(xs:redefine) return s2bootstrap:redefine($node, $model)
        case element(xs:restriction) return s2bootstrap:restriction($node, $model)
        case element(xs:schema) return s2bootstrap:schema($node, $model)
        case element(xs:selector) return s2bootstrap:selector($node, $model)
        case element(xs:sequence) return s2bootstrap:sequence($node, $model)
        case element(xs:simpleContent) return s2bootstrap:simpleContent($node, $model)
        case element(xs:simpleType) return s2bootstrap:simpleType($node, $model)
        case element(xs:totalDigits) return s2bootstrap:totalDigits($node, $model)
        case element(xs:union) return s2bootstrap:union($node, $model)
        case element(xs:unique) return s2bootstrap:unique($node, $model)
        case element(xs:whiteSpace) return s2bootstrap:whiteSpace($node, $model)
        default return s2bootstrap:recurse($node, $model) 
    else () 
};

declare function s2bootstrap:recurse($node as node()?, $model as map()) as item()* {
    if ($node) then for $cnode in $node/node() return s2bootstrap:process-node($cnode, $model) else ()
};

declare function s2bootstrap:display-attributes($nodes as node()*) as item()* {
    for $node in $nodes
    return for $attr in $node/@*
            return switch ($attr/name())
                        case('ref') return ()
                        case('name') return ()
                        case('base') return ()
                        case('type') return ()
                        default return <span>{$attr/name()}:{string($attr)}</span>
};

declare function s2bootstrap:display-list-item($element as node(), $model as map(*)) {
    let $sprint := request:get-parameter('sprint', '')
    let $schema := request:get-parameter('schema', '')
    let $type := string($element/local-name())
    return if ($schema = 'CDXF_EIM')
    then
    <tr>
        <td>{string($element/local-name())}</td>
        <td>{if ($type = 'group') then <a href="../../examples/{string($element/@name)}.html"><span class="glyphicon glyphicon-edit"></span></a> else ()}</td>
        <td class="col-lg-4"><a href="{$schema}/{$type}/{string($element/@name)}">{string($element/@name)}</a></td>
        <td>{$element/xs:annotation/xs:documentation[1]}</td>
    </tr>
    else if ($element/@name)
    then
    <tr>
        <td>{string($element/local-name())}</td>
        <td><a href="{$schema}/{$type}/{string($element/@name)}">{string($element/@name)}</a></td>
        <td>{$element/xs:annotation/xs:documentation[1]}</td>
    </tr>
    else if ($element/@ref)
    then
    let $refElement := s2util:item-from-qname(string($element/@ref), $element/root())
    let $refSchemaName := substring-before(functx:substring-after-last(base-uri($refElement), '/'), '.xsd')
    return
    <tr>
        <td>{string($refElement/local-name())}</td>
        <td><a href="{$refSchemaName}/{$type}/{string($refElement/@name)}">{string($refElement/@name)}</a></td>
        <td>{$refElement/xs:annotation/xs:documentation[1]}</td>
    </tr>
    else
    ()
};

declare function s2bootstrap:displayType($node as node()?, $model as map(*)) as item()* {
    let $nl := "&#10;"
    let $log := util:log-app("info", "s2bootstrap", concat('Node: ', $nl, util:serialize($node,"method=xml")))
    return
        if ($node/@type)
        then 
            if (contains(string($node/@type), ':')) 
            then
                let $base := string($node/@type)
                let $eDoc := s2util:schema-from-prefix($base, $node/root())
                let $matchName := if (contains($base, ':'))
                                    then substring-after($base, ':')
                                    else $base
                let $extension := $eDoc//*[string(@name) eq $matchName][1]
                let $nl := "&#10;"
                let $log := util:log-app("info", "s2bootstrap", concat('displayType extension: ', $nl, util:serialize($extension,"method=xml")))
                return
                    <span>Type: {$base}</span>
            else if ($node/root()//xs:simpleType[string(@name) eq string($node/@type)]) 
            then 
                let $type := $node/root()//xs:simpleType[string(@name) eq string($node/@type)]
                return <span>Type: <a href="item.html?schema={request:get-parameter('schema', '')}&amp;type={string($type/local-name())}&amp;name={string($type/@name)}">{string($type/@name)}</a></span>
            else if ($node/root()//xs:complexType[string(@name) eq string($node/@type)]) 
            then 
                let $type := $node/root()//xs:complexType[string(@name) eq string($node/@type)]
                return <span>Type: <a href="item.html?schema={request:get-parameter('schema', '')}&amp;type={string($type/local-name())}&amp;name={string($type/@name)}">{string($type/@name)}</a></span>
            else <span>Type:{string($node/@type)}</span>
        else ()
};

declare function s2bootstrap:general($node as node(), $model as map(*)) as item()* {
    let $base := string($node/@base)
    return
        <div class="well">{$node/local-name()}: {$base}
        {s2bootstrap:display-attributes(($node))}
        {s2bootstrap:recurse($node, $model)}
        </div>
};

declare function s2bootstrap:all($node as node(), $model as map()) {
    (: Attributes:
        maxOccurs
        minOccurs
   Child Elements:

 :)
s2bootstrap:recurse($node, $model)
};

declare function s2bootstrap:annotation($node as node(), $model as map()) {
    (: Attributes:
        id
   Child Elements:
        appinfo
        documentation
 :)
    <div class="schema-annotation">{s2bootstrap:recurse($node, $model)}</div>
};

declare function s2bootstrap:any($node as node(), $model as map()) {
    (: Attributes:
        maxOccurs
        minOccurs
   Child Elements:

 :)
s2bootstrap:recurse($node, $model)
};

declare function s2bootstrap:anyAttribute($node as node(), $model as map()) {
    <div class="well">anyAttribute<br/>{s2bootstrap:display-attributes($node)}</div>
};

declare function s2bootstrap:appinfo($node as node(), $model as map()) {
    (: Attributes:
        source
   Child Elements:

 :)
(:    <div class="btn-group">
        <button type="button" class="btn btn-default btn-xs"> ERWin Name </button>
        <button type="button" class="btn btn-info btn-xs">{s2bootstrap:recurse($node, $model)}</button>
    </div>
:)()};

declare function s2bootstrap:attribute($node as node(), $model as map()) {
    (: Attributes:

   Child Elements:
        annotation
        simpleType
 :)
    if ($node/@ref) then
    let $base := string($node/@ref)
    let $eDoc := s2util:schema-from-prefix($base, $node/root())
    let $matchName := if (contains($base, ':'))
                        then substring-after($base, ':')
                        else $base
    let $extension := $eDoc//*[string(@name) eq $matchName][1]
    return
        <div class="well">Attribute: {$base}
        {s2bootstrap:display-attributes(($node, $extension))}
        {s2bootstrap:displayType($extension, $model)}
        {s2bootstrap:recurse($extension, $model)}
        {s2bootstrap:recurse($node, $model)}
        </div>
    else 
    let $base := string($node/@name)
    return
        <div class="well">Attribute: {$base}
        {s2bootstrap:display-attributes(($node))}
        {s2bootstrap:displayType($node, $model)}
        {s2bootstrap:recurse($node, $model)}
        </div>
};

declare function s2bootstrap:attributeGroup($node as node(), $model as map()) {
    (: Attributes:

   Child Elements:
        annotation
 :)
   <div class="well">
        Attribute Group: {$node/@name/string()}
        {s2bootstrap:recurse($node, $model)}
    </div>
};

declare function s2bootstrap:choice($node as node(), $model as map()) {
    (: Attributes:

   Child Elements:
        annotation
 :)
<div class="panel panel-default">
  <div class="panel-heading">Choice {s2bootstrap:display-attributes(($node))}</div>
  {if ($node/xs:annotation)
  then
    <div class="panel-body">{for $cnode in $node/xs:annotation return s2bootstrap:process-node($cnode, $model)}
    </div>
    else ()}
  <ul class="list-group">{
    for $cnode in $node/node()
        where ($cnode/name() != 'xs:annotation')
        return <li class="list-group-item">{s2bootstrap:process-node($cnode, $model)}</li>
    }</ul>
</div>
};

declare function s2bootstrap:complexContent($node as node(), $model as map()) {
    (: Attributes:
        mixed
   Child Elements:
        extension
        restriction
 :)
s2bootstrap:recurse($node, $model)
};

declare function s2bootstrap:complexType($node as node(), $model as map()) {
    (: Attributes:

   Child Elements:
        annotation
 :)
    let $nl := "&#10;"
    let $log := util:log-app("info", "s2bootstrap", concat('complexType Node: ', $nl, util:serialize($node,"method=xml")))
    return
    if ($node/@ref) then
        let $base := string($node/@ref)
        let $eDoc := s2util:schema-from-prefix($base, $node/root())
        let $matchName := if (contains($base, ':'))
                            then substring-after($base, ':')
                            else $base
        let $extension := $eDoc//*[string(@name) eq $matchName][1]
        return
            <div class="well">ComplexType: {$base}
            {s2bootstrap:display-attributes(($node, $extension))}
            {s2bootstrap:displayType($extension, $model)}
            {s2bootstrap:recurse($node, $model)}
            </div>
    else
         s2bootstrap:recurse($node, $model)
};

declare function s2bootstrap:documentation($node as node(), $model as map()) {
    (: Attributes:
        lang
        source
   Child Elements:

 :)
    let $nl := "&#10;"
    let $nbsp := "&#160;"
    let $content := if (functx:has-simple-content($node)) then for $foo in tokenize($node/text(), "\n") return <p>{replace($foo, "^\s+", $nbsp)}</p> else $node/*
    return <div class="alert alert-success">{$content}</div>
};

declare function s2bootstrap:element($node as node(), $model as map()) {
    (: Attributes:

   Child Elements:
        annotation
        complexType
        simpleType
 :)
    let $nl := "&#10;"
    let $model := if (exists($model)) then $model else map:new()
    return 
    if ($node/@ref) then
        let $log1 := util:log-app('info', 's2bootstrap', 'ref: ' || string($node/@ref))
        let $base := string($node/@ref)
        let $eDoc := s2util:schema-from-prefix($base, $node/root())
        let $matchName := if (contains($base, ':')) then substring-after($base, ':') else $base
        let $extension := $eDoc//xs:element[string(@name) eq $matchName][1]
        let $heading := 
                <div class="panel-heading">
                    <ul class="list-inline">
                        <li>Element: {$base}</li>
                        {for $item in (s2bootstrap:display-attributes(($node, $extension)), s2bootstrap:displayType($extension, $model))
                        return <li>{$item}</li>}
                    </ul>
                </div>
        let $annotation := if ($extension/xs:annotation/xs:documentation)
                            then <div class="panel-body">{for $cnode in $extension/xs:annotation return s2bootstrap:process-node($cnode, $model)}</div>
                            else ()
        let $body := if ($extension/node()) then <ul class="list-group">{
                        for $cnode in ($extension/node(), $node/node())
                        where ($cnode/name() != 'xs:annotation')
                        return <li class="list-group-item">{s2bootstrap:process-node($cnode, $model)}</li>
                    }</ul> else ()
                            
            return
            <div class="panel panel-default">{$heading}{$annotation}{$body}</div>
    else 
        let $base := string($node/@name)
        let $log1 := util:log-app('info', 's2bootstrap', 'name: ' || $base)
        let $heading := 
                <div class="panel-heading">
                    <ul class="list-inline">
                        <li>Element: {$base}</li>
                        {for $item in (s2bootstrap:display-attributes(($node)), s2bootstrap:displayType($node, $model))
                            return <li>{$item}</li>}
                    </ul>
                </div>
        let $annotation := if ($node/xs:annotation/xs:documentation)
                            then <div class="panel-body">{for $cnode in $node/xs:annotation return s2bootstrap:process-node($cnode, $model)}</div>
                            else ()
        let $body :=        if ($node/node()) then
                            <ul class="list-group">{
                            for $cnode in $node/node()
                            let $logc := util:log-app('info', 's2bootstrap', concat('Child: ', $nl, util:serialize($cnode,"method=xml")))
                            where ($cnode/name() != 'xs:annotation')
                            return <li class="list-group-item">{s2bootstrap:process-node($cnode, $model)}</li>
                            }</ul> else ()
        return 
            <div class="panel panel-default">{$heading}{$annotation}{$body}</div>
};

declare function s2bootstrap:enumeration($node as node(), $model as map()) {
    (: Attributes:

   Child Elements:
        annotation
 :)
    <div class="well">Enumeration {s2bootstrap:display-attributes(($node))}</div>
};

declare function s2bootstrap:extension($node as node(), $model as map()) {
    (: Attributes:

   Child Elements:
        annotation
 :)
    let $base := string($node/@base)
    let $eDoc := s2util:schema-from-prefix($base, $node/root())
    let $matchName := if (contains($base, ':'))
                        then substring-after($base, ':')
                        else $base
    let $extension := $eDoc//*[string(@name) eq $matchName][1]
    return
        <div class="well">Extension: {$base}
        {s2bootstrap:display-attributes(($node, $extension))}
        {s2bootstrap:process-node($extension, $model)}
        {s2bootstrap:recurse($node, $model)}
        </div>
};

declare function s2bootstrap:field($node as node(), $model as map()) {
    (: Attributes:
        xpath
   Child Elements:

 :)
s2bootstrap:recurse($node, $model)
};

declare function s2bootstrap:fractionDigits($node as node(), $model as map()) {
    (: Attributes:

   Child Elements:
        annotation
 :)
s2bootstrap:recurse($node, $model)
};

declare function s2bootstrap:group($node as node(), $model as map()) {
    (: Attributes:

   Child Elements:
        all
        annotation
        choice
        sequence
 :)
    if ($node/@ref) 
    then
        let $base := string($node/@ref)
        let $log1 := util:log-app('info', 's2bootstrap', 'group Reference: ' || $base)
        let $matchName := if (contains($base, ':'))
                            then substring-after($base, ':')
                            else $base
        let $log1 := util:log-app('info', 'schema', 'group matchName: ' || $matchName)
        let $eDoc := s2util:schema-from-prefix($base, $node/root())
        let $extension := $eDoc//xs:group[string(@name) eq $matchName]
        let $log2 := util:log-app('info', 'schema', 'group Extension: ' || util:serialize($extension,"method=xml"))
        let $heading := 
                <div class="panel-heading">
                    <ul class="list-inline">
                        <li>Group: {$base}</li>
                        {for $item in (s2bootstrap:display-attributes(($node, $extension)), s2bootstrap:displayType($extension, $model))
                        return <li>{$item}</li>}
                    </ul>
                </div>
        let $annotation := if ($extension/xs:annotation)
                            then <div class="panel-body">{for $cnode in $extension/xs:annotation return s2bootstrap:process-node($cnode, $model)}</div>
                            else ()
        let $body := if (($extension/node(), $node/node())) then <ul class="list-group">{
                        for $cnode in ($extension/node(), $node/node())
                        where ($cnode/name() != 'xs:annotation')
                        return <li class="list-group-item">{s2bootstrap:process-node($cnode, $model)}</li>
                    }</ul> else ()
                            
            return
            <div class="panel panel-default">{$heading}{$annotation}{$body}</div>
    else 
    let $base := string($node/@name)
    return
        <div class="panel panel-default">
            <div class="panel-heading">
                Group: {$base}
                {s2bootstrap:display-attributes(($node))}
                {s2bootstrap:displayType($node, $model)}
            </div>
            <div class="panel-body">
                {s2bootstrap:recurse($node, $model)}
             </div>
        </div>
};

declare function s2bootstrap:import($node as node(), $model as map()) {
    (: Attributes:
        namespace
        schemaLocation
   Child Elements:

 :)
    let $namespace := string($node/@namespace)
    let $schemaLoc := string($node/@schemaLocation)
    let $sprints := sutil:sprint-sequence-descending()
    let $absURI := switch($model('sprint'))
                        case 'working' return replace(resolve-uri($schemaLoc, base-uri($node/root())), $sprints[1], 'working')
                        case 'stable' return replace(resolve-uri($schemaLoc, base-uri($node/root())), $sprints[2], 'stable')
                        default return resolve-uri($schemaLoc, base-uri($node/root()))
    let $fullURI := '/exist' || replace(replace(replace($absURI, '/schemas/', '/'), '/db/', '/'), '/data/', '/schema/')
    return <div class="container schema-border">
                <div class="col-lg-4"><a href="{functx:substring-after-last($absURI, "/")}">{functx:substring-after-last($absURI, "/")}</a></div>
                <div class="col-lg-8"><dl>
                    <dt>Target Namespace</dt><dd>{$namespace}</dd>
                    <dt>Schema Location:</dt><dd><a href="{$fullURI}">{$fullURI}</a></dd>
                    </dl>
                </div>
           </div>
};

declare function s2bootstrap:include($node as node(), $model as map()) {
    (: Attributes:
        schemaLocation
   Child Elements:

 :)
    let $namespace := string($node/@namespace)
    let $schemaLoc := string($node/@schemaLocation)
    let $absURI := resolve-uri($schemaLoc, base-uri($node/root()))
    return <tr>
                <td>{$namespace}</td>
                <td><a href="index.html?schema={$absURI}">{$absURI}</a></td>
           </tr>
};

declare function s2bootstrap:key($node as node(), $model as map()) {
    (: Attributes:

   Child Elements:
        field
        selector
 :)
s2bootstrap:recurse($node, $model)
};

declare function s2bootstrap:keyref($node as node(), $model as map()) {
    (: Attributes:
        refer
   Child Elements:

 :)
s2bootstrap:recurse($node, $model)
};

declare function s2bootstrap:length($node as node(), $model as map()) {
    (: Attributes:

   Child Elements:
        annotation
 :)
s2bootstrap:recurse($node, $model)
};

declare function s2bootstrap:list($node as node(), $model as map()) {
    (: Attributes:
        itemType
   Child Elements:
        simpleType
 :)
s2bootstrap:recurse($node, $model)
};

declare function s2bootstrap:maxExclusive($node as node(), $model as map()) {
    s2bootstrap:general($node, $model)
};

declare function s2bootstrap:maxInclusive($node as node(), $model as map()) {
    s2bootstrap:general($node, $model)
};

declare function s2bootstrap:maxLength($node as node(), $model as map()) {
    (: Attributes:

   Child Elements:
        annotation
 :)
s2bootstrap:recurse($node, $model)
};

declare function s2bootstrap:minExclusive($node as node(), $model as map()) {
    s2bootstrap:general($node, $model)
};

declare function s2bootstrap:minInclusive($node as node(), $model as map()) {
    s2bootstrap:general($node, $model)
};

declare function s2bootstrap:minLength($node as node(), $model as map()) {
    (: Attributes:

   Child Elements:
        annotation
 :)
s2bootstrap:recurse($node, $model)
};

declare function s2bootstrap:notation($node as node(), $model as map()) {
    (: Attributes:
        name
        public
        system
   Child Elements:

 :)
s2bootstrap:recurse($node, $model)
};

declare function s2bootstrap:pattern($node as node(), $model as map()) {
    (: Attributes:
        value
   Child Elements:
        annotation
 :)
s2bootstrap:recurse($node, $model)
};

declare function s2bootstrap:redefine($node as node(), $model as map()) {
    (: Attributes:
        id
        schemaLocation
   Child Elements:
        annotation
 :)
s2bootstrap:recurse($node, $model)
};

declare function s2bootstrap:restriction($node as node(), $model as map()) {
    (: Attributes:
        base
   Child Elements:
        annotation
 :)
    let $base := string($node/@base)
    let $eDoc := s2util:schema-from-prefix($base, $node/root())
    let $matchName := if (contains($base, ':'))
                        then substring-after($base, ':')
                        else $base
    let $extension := $eDoc//*[string(@name) eq $matchName][1]
    let $nl := "&#10;"
    let $log := util:log-app("info", "s2bootstrap", concat('Restriction: ',$base, $nl,
                        $matchName, $nl, $nl, util:serialize($extension,"method=xml")))
    return
        <div class="well">Restriction: {$base}
        {if ($extension//xs:enumeration or $node//xs:enumeration)
         then
            <div class="well">
                <span class="label">Enumeration</span>
                <table>
                {for $enum in ($extension//xs:enumeration, $node//xs:enumeration)
                    return <tr>
                            <td>{$enum/@value/string()}</td>
                            {if ($enum//xs:annotation) 
                                then 
                                    let $nl := "&#10;"
                                    let $nbsp := "&#160;"
                                    let $content := if (functx:has-simple-content($enum/xs:annotation/xs:documentation)) 
                                                    then for $foo in tokenize($enum/xs:annotation/xs:documentation/text(), "\n") 
                                                            return <p>{replace($foo, "^\s+", $nbsp)}</p> 
                                                    else $node/*
                                    return <td>{$content}</td>
                                else ()}
                           </tr>}
                </table>
            </div>
          else
         (s2bootstrap:process-node($extension, $model),
          s2bootstrap:recurse($node, $model))
         }
        </div>
};

declare function s2bootstrap:schema($node as node(), $model as map()) {
    (: Attributes:
        attributeFormDefault
        blockDefault
        elementFormDefault
        finalDefault
        id
        lang
        targetNamespace
        version
   Child Elements:
        annotation
        import
        include
        redefine
 :)
s2bootstrap:recurse($node, $model)
};

declare function s2bootstrap:selector($node as node(), $model as map()) {
    (: Attributes:
        xpath
   Child Elements:

 :)
s2bootstrap:recurse($node, $model)
};

declare function s2bootstrap:sequence($node as node(), $model as map()) {
    (: Attributes:

   Child Elements:
        annotation
 :)
(:<div class="panel panel-default">
  <div class="panel-heading">Sequence {s2bootstrap:display-attributes(($node))}</div>
  {if ($node/xs:annotation)
  then
    <div class="panel-body">{for $cnode in $node/xs:annotation return s2bootstrap:process-node($cnode, $model)}
    </div>
    else ()}
:)  <ul class="list-group">{
    for $cnode in $node/node()
        where ($cnode/name() != 'xs:annotation')
        return <li class="list-group-item">{s2bootstrap:process-node($cnode, $model)}</li>
    }</ul>
(:</div>
:)};

declare function s2bootstrap:simpleContent($node as node(), $model as map()) {
    (: Attributes:

   Child Elements:
        extension
        restriction
 :)
s2bootstrap:recurse($node, $model)
};

declare function s2bootstrap:simpleType($node as node(), $model as map()) {
    (: Attributes:

   Child Elements:
        annotation
 :)
    if ($node/@ref) then
    let $base := string($node/@ref)
    let $eDoc := s2util:schema-from-prefix($base, $node/root())
    let $matchName := if (contains($base, ':'))
                        then substring-after($base, ':')
                        else $base
    let $extension := $eDoc//*[string(@name) eq $matchName][1]
    return
        <div class="well">SimpleType: {$base}
        {s2bootstrap:display-attributes(($node, $extension))}
        {s2bootstrap:displayType($extension, $model)}
        {s2bootstrap:recurse($extension, $model)}
        {s2bootstrap:recurse($node, $model)}
        </div>
    else if ($node/@name) then
    let $base := string($node/@name)
    return
        <div class="well">SimpleType: {$base}
        {s2bootstrap:display-attributes(($node))}
        {s2bootstrap:displayType($node, $model)}
        {s2bootstrap:recurse($node, $model)}
        </div>
    else
        <div class="well">SimpleType
        {s2bootstrap:display-attributes(($node))}
        {s2bootstrap:displayType($node, $model)}
        {s2bootstrap:recurse($node, $model)}
        </div>
};

declare function s2bootstrap:totalDigits($node as node(), $model as map()) {
    (: Attributes:
        value
   Child Elements:
        annotation
 :)
s2bootstrap:general($node, $model)
};

declare function s2bootstrap:union($node as node(), $model as map()) {
    (: Attributes:
        memberTypes
   Child Elements:
        simpleType
 :)
s2bootstrap:recurse($node, $model)
};

declare function s2bootstrap:unique($node as node(), $model as map()) {
    (: Attributes:

   Child Elements:
        field
        selector
 :)
s2bootstrap:recurse($node, $model)
};

declare function s2bootstrap:whiteSpace($node as node(), $model as map()) {
    (: Attributes:
        value
   Child Elements:
        annotation
 :)
s2bootstrap:recurse($node, $model)
};
