xquery version "3.0";

module namespace s2bootstrap="http://greatlinkup.com/ns/schema2bootstrap";
import module namespace  functx = "http://www.functx.com" at "functx.xqm";
import module namespace s2util = "http://greatlinkup.com/ns/schema-util" at "schema-util.xqm";

declare %public function s2bootstrap:process-node($node as node()?, $doc as node(), $model as map(*)) {
    if ($node) then 
    typeswitch($node) 
        case text() return $node 
        case element(xs:schema) return s2bootstrap:schema($node, $doc, $model)
        case element(xs:group) return s2bootstrap:group($node, $doc, $model)
        case element(xs:element) return s2bootstrap:element($node, $doc, $model)
        case element(xs:simpleType) return s2bootstrap:simpleType($node, $doc, $model)
        case element(xs:attribute) return s2bootstrap:attribute($node, $doc, $model)
        case element(xs:attributeGroup) return s2bootstrap:attributeGroup($node, $doc, $model)
        case element(xs:anyAttribute) return s2bootstrap:anyAttribute($node, $doc, $model)
        case element(xs:complexContent) return s2bootstrap:complexContent($node, $doc, $model)
        case element(xs:restriction) return s2bootstrap:restriction($node, $doc, $model)
        case element(xs:extension) return s2bootstrap:extension($node, $doc, $model)
        case element(xs:simpleContent) return s2bootstrap:simpleContent($node, $doc, $model)
        case element(xs:complexType) return s2bootstrap:complexType($node, $doc, $model)
        case element(xs:all) return s2bootstrap:all($node, $doc, $model)
        case element(xs:choice) return s2bootstrap:choice($node, $doc, $model)
        case element(xs:sequence) return s2bootstrap:sequence($node, $doc, $model)
        case element(xs:any) return s2bootstrap:any($node, $doc, $model)
        case element(xs:include) return s2bootstrap:include($node, $doc, $model)
        case element(xs:redefine) return s2bootstrap:redefine($node, $doc, $model)
        case element(xs:import) return s2bootstrap:import($node, $doc, $model)
        case element(xs:selector) return s2bootstrap:selector($node, $doc, $model)
        case element(xs:field) return s2bootstrap:field($node, $doc, $model)
        case element(xs:unique) return s2bootstrap:unique($node, $doc, $model)
        case element(xs:key) return s2bootstrap:key($node, $doc, $model)
        case element(xs:keyref) return s2bootstrap:keyref($node, $doc, $model)
        case element(xs:notation) return s2bootstrap:notation($node, $doc, $model)
        case element(xs:appinfo) return s2bootstrap:appinfo($node, $doc, $model)
        case element(xs:documentation) return s2bootstrap:documentation($node, $doc, $model)
        case element(xs:annotation) return s2bootstrap:annotation($node, $doc, $model)
        case element(xs:list) return s2bootstrap:list($node, $doc, $model)
        case element(xs:union) return s2bootstrap:union($node, $doc, $model)
        case element(xs:minExclusive) return s2bootstrap:minExclusive($node, $doc, $model)
        case element(xs:minInclusive) return s2bootstrap:minInclusive($node, $doc, $model)
        case element(xs:maxExclusive) return s2bootstrap:maxExclusive($node, $doc, $model)
        case element(xs:maxInclusive) return s2bootstrap:maxInclusive($node, $doc, $model)
        case element(xs:totalDigits) return s2bootstrap:totalDigits($node, $doc, $model)
        case element(xs:fractionDigits) return s2bootstrap:fractionDigits($node, $doc, $model)
        case element(xs:length) return s2bootstrap:length($node, $doc, $model)
        case element(xs:minLength) return s2bootstrap:minLength($node, $doc, $model)
        case element(xs:maxLength) return s2bootstrap:maxLength($node, $doc, $model)
        case element(xs:enumeration) return s2bootstrap:enumeration($node, $doc, $model)
        case element(xs:whiteSpace) return s2bootstrap:whiteSpace($node, $doc, $model)
        case element(xs:pattern) return s2bootstrap:pattern($node, $doc, $model)
        default return s2bootstrap:recurse($node, $doc, $model) 
    else () 
};

declare function s2bootstrap:recurse($node as node()?, $doc as node(), $model as map(*)) as item()* {
    if ($node) 
    then for $cnode in $node/node() 
        return s2bootstrap:process-node($cnode, $doc, $model) 
    else ()
};

declare function s2bootstrap:display-attributes($nodes as node()*) as item()* {
    for $node in $nodes
    return for $attr in $node/@*
            where ($attr/name() ne 'ref' or $attr/name() ne 'name' or $attr/name() ne 'base')
            return if ($attr/name() eq 'ref') then ()
            else if ($attr/name() eq 'name') then ()
            else if ($attr/name() eq 'base') then ()
            else if ($attr/name() eq 'type') then ()
            else (' ',<span>{$attr/name()}:{string($attr)}</span>)
};

declare function s2bootstrap:display-list-item($element as node(), $doc as node(), $model as map(*)) {
    <div class="container schema-border">
        <div class="span2">{string($element/local-name())}</div>
        <div class="span4"><a href="item.html?schema={request:get-parameter('schema', '')}&amp;type={string($element/local-name())}&amp;name={string($element/@name)}">{string($element/@name)}</a></div>
        {if ($element/xs:annotation/xs:documentation) then <div class="span6">{$element/xs:annotation/xs:documentation[1]}</div> else ()}
    </div>
};

declare function s2bootstrap:displayType($doc as node(), $node as node()?) as item()* {
    if ($node/@type)
    then if (contains(string($node/@type), ':'))
        then
            let $base := string($node/@type)
            let $eDoc := s2util:schema-from-prefix($base, $doc)
            let $matchName := if (contains($base, ':'))
                                then substring-after($base, ':')
                                else $base
            let $extension := $eDoc//*[string(@name) eq $matchName][1]
            return
                (' ', <span>Type: <a href="#">{$base}</a></span>)
        else if ($doc//xs:simpleType[string(@name) eq string($node/@type)])
                then 
                    let $type := $doc//xs:simpleType[string(@name) eq string($node/@type)]
                    return (' ',<span>Type: <a href="item.html?schema={request:get-parameter('schema', '')}&amp;type={string($type/local-name())}&amp;name={string($type/@name)}">{string($type/@name)}</a></span>)
                else (' ',<span>Type:{string($node/@type)}</span>)
    else ()
};

declare function s2bootstrap:general($node as node(), $doc as node(), $model as map(*)) as item()* {
    let $base := string($node/@base)
    return
        <div class="well">{$node/local-name()}: {$base}
        {s2bootstrap:display-attributes(($node))}
        {s2bootstrap:recurse($node, $doc, $model)}
        </div>
};

declare %public function s2bootstrap:all($node as node(), $doc as node(), $model as map(*)) {
    ()
};

declare %public function s2bootstrap:annotation($node as node(), $doc as node(), $model as map(*)) {
    s2bootstrap:recurse($node, $doc, $model)
};

declare %public function s2bootstrap:any($node as node(), $doc as node(), $model as map(*)) {
    ()
};

declare %public function s2bootstrap:anyAttribute($node as node(), $doc as node(), $model as map(*)) {
    <div class="well">anyAttribute<br/>{s2bootstrap:display-attributes($node)}</div>
};

declare %public function s2bootstrap:appinfo($node as node(), $doc as node(), $model as map(*)) {
    s2bootstrap:recurse($node, $doc, $model)
};

declare %public function s2bootstrap:attribute($node as node(), $doc as node(), $model as map(*)) {
    if ($node/@ref) then
    let $base := string($node/@ref)
    let $eDoc := s2util:schema-from-prefix($base, $doc)
    let $matchName := if (contains($base, ':'))
                        then substring-after($base, ':')
                        else $base
    let $extension := $eDoc//*[string(@name) eq $matchName][1]
    return
        <div class="well">Attribute: {$base}
        {s2bootstrap:display-attributes(($node, $extension))}
        {s2bootstrap:displayType($doc, $extension)}
        {s2bootstrap:recurse($extension, $eDoc, $model)}
        {s2bootstrap:recurse($node, $doc, $model)}
        </div>
    else 
    let $base := string($node/@name)
    return
        <div class="well">Attribute: {$base}
        {s2bootstrap:display-attributes(($node))}
        {s2bootstrap:displayType($doc, $node)}
        {s2bootstrap:recurse($node, $doc, $model)}
        </div>
};

declare %public function s2bootstrap:attributeGroup($node as node(), $doc as node(), $model as map(*)) {
    <div class="well">
        Attribute Group: {$node/@name/string()}
        {s2bootstrap:recurse($node, $doc, $model)}
    </div>
};

declare %public function s2bootstrap:choice($node as node(), $doc as node(), $model as map(*)) {
    <div class="well">Choice
        {s2bootstrap:display-attributes(($node))}
        {s2bootstrap:recurse($node, $doc, $model)}
    </div>
};

declare %public function s2bootstrap:complexContent($node as node(), $doc as node(), $model as map(*)) {
    s2bootstrap:recurse($node, $doc, $model)
};

declare %public function s2bootstrap:complexType($node as node(), $doc as node(), $model as map(*)) {
    if ($node/@name) then
    let $base := string($node/@name)
    let $eDoc := s2util:schema-from-prefix($base, $doc)
    let $matchName := if (contains($base, ':'))
                        then substring-after($base, ':')
                        else $base
    let $extension := $eDoc//*[string(@name) eq $matchName][1]
    return
        <div class="well">ComplexType: {$base}
        {s2bootstrap:display-attributes(($node, $extension))}
        {s2bootstrap:displayType($doc, $extension)}
        {s2bootstrap:recurse($node, $doc, $model)}
        </div>
    else if (request:get-parameter('detail', ''))
    then
        <div class="well">ComplexType
        {s2bootstrap:display-attributes(($node))}
        {s2bootstrap:displayType($doc, $node)}
        {s2bootstrap:recurse($node, $doc, $model)}
        </div>
    else
        <div>
        {s2bootstrap:display-attributes(($node))}
        {s2bootstrap:displayType($doc, $node)}
        {s2bootstrap:recurse($node, $doc, $model)}
        </div>
};

declare %public function s2bootstrap:documentation($node as node(), $doc as node(), $model as map(*)) {
    let $nl := "&#10;"
    let $nbsp := "&#160;"
    let $content := if (functx:has-simple-content($node)) then for $foo in tokenize($node/text(), "\n") return <p>{replace($foo, "^\s+", $nbsp)}</p> else $node/*
    return <div class="alert alert-success">{$content}</div>
};

declare %public function s2bootstrap:element($node as node(), $doc as node(), $model as map(*)) {
    let $model := if (exists($model)) then $model else map:new()
    return 
    if ($node/@ref) then
    let $base := string($node/@ref)
    let $eDoc := s2util:schema-from-prefix($base, $doc)
    let $matchName := if (contains($base, ':'))
                        then substring-after($base, ':')
                        else $base
    let $extension := $eDoc//*[string(@name) eq $matchName][1]
    return
        <div class="well">Element: {$base}
        {s2bootstrap:display-attributes(($node, $extension))}
        {s2bootstrap:displayType($doc, $extension)} 
        {if (map:contains($model, $extension/@name))
        then ()
        else
            let $model := map:new(($model, map:entry($extension/@name, true())))
            return
                (s2bootstrap:recurse($extension, $eDoc, $model),
                 s2bootstrap:recurse($node, $doc, $model))}
        </div>
    else 
    let $base := string($node/@name)
    return
        <div class="well">Element: {$base}
        {s2bootstrap:display-attributes(($node))}
        {s2bootstrap:displayType($doc, $node)}
        {if (map:contains($model, $node/@name))
        then ()
        else
            let $model := map:new(($model, map:entry($node/@name, true())))
            return
                 s2bootstrap:recurse($node, $doc, $model)}
        </div>
};

declare %public function s2bootstrap:enumeration($node as node(), $doc as node(), $model as map(*)) {
    <div class="well">Enumeration {s2bootstrap:display-attributes(($node))}</div>
};

declare %public function s2bootstrap:extension($node as node(), $doc as node(), $model as map(*)) {
    let $base := string($node/@base)
    let $eDoc := s2util:schema-from-prefix($base, $doc)
    let $matchName := if (contains($base, ':'))
                        then substring-after($base, ':')
                        else $base
    let $extension := $eDoc//*[string(@name) eq $matchName][1]
    return
        <div class="well">Extension: {$base}
        {s2bootstrap:display-attributes(($node, $extension))}
        {s2bootstrap:process-node($extension, $eDoc, $model)}
        {s2bootstrap:recurse($node, $doc, $model)}
        </div>
};

declare %public function s2bootstrap:field($node as node(), $doc as node(), $model as map(*)) {
    ()
};

declare %public function s2bootstrap:fractionDigits($node as node(), $doc as node(), $model as map(*)) {
    ()
};

declare %public function s2bootstrap:group($node as node(), $doc as node(), $model as map(*)) {
    if ($node/@ref) then
    let $base := string($node/@ref)
    let $eDoc := s2util:schema-from-prefix($base, $doc)
    let $matchName := if (contains($base, ':'))
                        then substring-after($base, ':')
                        else $base
    let $extension := $eDoc//*[string(@name) eq $matchName][1]
    return
        <div class="well">Group: {$base}
        {s2bootstrap:display-attributes(($node, $extension))}
        {s2bootstrap:displayType($doc, $extension)}
        {s2bootstrap:recurse($extension, $eDoc, $model)}
        {s2bootstrap:recurse($node, $doc, $model)}
        </div>
    else 
    let $base := string($node/@name)
    return
        <div class="well">Group: {$base}
        {s2bootstrap:display-attributes(($node))}
        {s2bootstrap:displayType($doc, $node)}
        {s2bootstrap:recurse($node, $doc, $model)}
        </div>
};

declare %public function s2bootstrap:import($node as node(), $doc as node(), $model as map(*)) {
    let $namespace := string($node/@namespace)
    let $schemaLoc := string($node/@schemaLocation)
    let $absURI := resolve-uri($schemaLoc, base-uri($doc))
    return <div class="container schema-border">
                <div class="span4"><a href="schema.html?schema={$absURI}">{functx:substring-after-last($absURI, "/")}</a></div>
                <div class="span8"><dl>
                    <dt>Target Namespace</dt><dd>{$namespace}</dd>
                    <dt>Schema Location:</dt><dd><a href="{$absURI}">{$absURI}</a></dd>
                    </dl>
                </div>
           </div>
};

declare %public function s2bootstrap:include($node as node(), $doc as node(), $model as map(*)) {
    let $namespace := string($node/@namespace)
    let $schemaLoc := string($node/@schemaLocation)
    let $absURI := resolve-uri($schemaLoc, base-uri($doc))
    return <tr>
                <td>{$namespace}</td>
                <td><a href="index.html?schema={$absURI}">{$absURI}</a></td>
           </tr>
};

declare %public function s2bootstrap:key($node as node(), $doc as node(), $model as map(*)) {
    ()
};

declare %public function s2bootstrap:keyref($node as node(), $doc as node(), $model as map(*)) {
    ()
};

declare %public function s2bootstrap:length($node as node(), $doc as node(), $model as map(*)) {
    ()
};

declare %public function s2bootstrap:list($node as node(), $doc as node(), $model as map(*)) {
    s2bootstrap:recurse($node, $doc, $model)
};

declare %public function s2bootstrap:maxExclusive($node as node(), $doc as node(), $model as map(*)) {
    s2bootstrap:general($node, $doc, $model)
};

declare %public function s2bootstrap:maxInclusive($node as node(), $doc as node(), $model as map(*)) {
    s2bootstrap:general($node, $doc, $model)
};

declare %public function s2bootstrap:maxLength($node as node(), $doc as node(), $model as map(*)) {
    ()
};

declare %public function s2bootstrap:minExclusive($node as node(), $doc as node(), $model as map(*)) {
    s2bootstrap:general($node, $doc, $model)
};

declare %public function s2bootstrap:minInclusive($node as node(), $doc as node(), $model as map(*)) {
    s2bootstrap:general($node, $doc, $model)
};

declare %public function s2bootstrap:minLength($node as node(), $doc as node(), $model as map(*)) {
    ()
};

declare %public function s2bootstrap:notation($node as node(), $doc as node(), $model as map(*)) {
    ()
};

declare %public function s2bootstrap:pattern($node as node(), $doc as node(), $model as map(*)) {
    s2bootstrap:recurse($node, $doc, $model)
};

declare %public function s2bootstrap:redefine($node as node(), $doc as node(), $model as map(*)) {
    s2bootstrap:recurse($node, $doc, $model)
};

declare %public function s2bootstrap:restriction($node as node(), $doc as node(), $model as map(*)) {
    let $base := string($node/@base)
    let $eDoc := s2util:schema-from-prefix($base, $doc)
    let $matchName := if (contains($base, ':'))
                        then substring-after($base, ':')
                        else $base
    let $extension := $eDoc//*[string(@name) eq $matchName][1]
    return
        <div class="well">Restriction: {$base}
        {s2bootstrap:display-attributes(($node, $extension))}
        {s2bootstrap:process-node($extension, $eDoc, $model)}
        {s2bootstrap:recurse($node, $doc, $model)}
        </div>
};

declare %public function s2bootstrap:schema($node as node(), $doc as node(), $model as map(*)) {
    s2bootstrap:recurse($node, $doc, $model)
};

declare %public function s2bootstrap:selector($node as node(), $doc as node(), $model as map(*)) {
    ()
};

declare %public function s2bootstrap:sequence($node as node(), $doc as node(), $model as map(*)) {
    <div class="well">Sequence{s2bootstrap:recurse($node, $doc, $model)}</div>
};

declare %public function s2bootstrap:simpleContent($node as node(), $doc as node(), $model as map(*)) {
    s2bootstrap:recurse($node, $doc, $model)
};

declare %public function s2bootstrap:simpleType($node as node(), $doc as node(), $model as map(*)) {
    if ($node/@ref) then
    let $base := string($node/@ref)
    let $eDoc := s2util:schema-from-prefix($base, $doc)
    let $matchName := if (contains($base, ':'))
                        then substring-after($base, ':')
                        else $base
    let $extension := $eDoc//*[string(@name) eq $matchName][1]
    return
        <div class="well">SimpleType: {$base}
        {s2bootstrap:display-attributes(($node, $extension))}
        {s2bootstrap:displayType($doc, $extension)}
        {s2bootstrap:recurse($extension, $eDoc, $model)}
        {s2bootstrap:recurse($node, $doc, $model)}
        </div>
    else if ($node/@name) then
    let $base := string($node/@name)
    return
        <div class="well">SimpleType: {$base}
        {s2bootstrap:display-attributes(($node))}
        {s2bootstrap:displayType($doc, $node)}
        {s2bootstrap:recurse($node, $doc, $model)}
        </div>
    else
        <div class="well">SimpleType
        {s2bootstrap:display-attributes(($node))}
        {s2bootstrap:displayType($doc, $node)}
        {s2bootstrap:recurse($node, $doc, $model)}
        </div>
};

declare %public function s2bootstrap:totalDigits($node as node(), $doc as node(), $model as map(*)) {
    s2bootstrap:general($node, $doc, $model)
};

declare %public function s2bootstrap:union($node as node(), $doc as node(), $model as map(*)) {
    s2bootstrap:recurse($node, $doc, $model)
};

declare %public function s2bootstrap:unique($node as node(), $doc as node(), $model as map(*)) {
    ()
};

declare %public function s2bootstrap:whiteSpace($node as node(), $doc as node(), $model as map(*)) {
    s2bootstrap:recurse($node, $doc, $model)
};
