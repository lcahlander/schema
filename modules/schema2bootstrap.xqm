xquery version "3.0";

module namespace s2bootstrap="http://greatlinkup.com/ns/schema2bootstrap";
import module namespace  functx = "http://www.functx.com" at "functx.xqm";

declare %private function s2bootstrap:schema-from-prefix($name as xs:string, $doc as node()) as node()
{
    if ($name)
    then
        let $namespace-uri := namespace-uri-from-QName(resolve-QName($name, $doc/xs:schema))
        let $import := $doc/*/xs:import[@namespace eq string($namespace-uri)]
        return if ($import) then 
        let $schemaLocation := string($import/@schemaLocation)
        let $fullURI := resolve-uri($schemaLocation, base-uri($doc))
        return doc($fullURI)
         else $doc
     else $doc
};

declare %public function s2bootstrap:process-node($node as node()?, $doc as node()) {
    if ($node) then 
    typeswitch($node) 
        case text() return $node 
        case element(xs:schema) return s2bootstrap:schema($node, $doc)
        case element(xs:group) return s2bootstrap:group($node, $doc)
        case element(xs:element) return s2bootstrap:element($node, $doc)
        case element(xs:simpleType) return s2bootstrap:simpleType($node, $doc)
        case element(xs:attribute) return s2bootstrap:attribute($node, $doc)
        case element(xs:attributeGroup) return s2bootstrap:attributeGroup($node, $doc)
        case element(xs:anyAttribute) return s2bootstrap:anyAttribute($node, $doc)
        case element(xs:complexContent) return s2bootstrap:complexContent($node, $doc)
        case element(xs:restriction) return s2bootstrap:restriction($node, $doc)
        case element(xs:extension) return s2bootstrap:extension($node, $doc)
        case element(xs:simpleContent) return s2bootstrap:simpleContent($node, $doc)
        case element(xs:complexType) return s2bootstrap:complexType($node, $doc)
        case element(xs:all) return s2bootstrap:all($node, $doc)
        case element(xs:choice) return s2bootstrap:choice($node, $doc)
        case element(xs:sequence) return s2bootstrap:sequence($node, $doc)
        case element(xs:any) return s2bootstrap:any($node, $doc)
        case element(xs:include) return s2bootstrap:include($node, $doc)
        case element(xs:redefine) return s2bootstrap:redefine($node, $doc)
        case element(xs:import) return s2bootstrap:import($node, $doc)
        case element(xs:selector) return s2bootstrap:selector($node, $doc)
        case element(xs:field) return s2bootstrap:field($node, $doc)
        case element(xs:unique) return s2bootstrap:unique($node, $doc)
        case element(xs:key) return s2bootstrap:key($node, $doc)
        case element(xs:keyref) return s2bootstrap:keyref($node, $doc)
        case element(xs:notation) return s2bootstrap:notation($node, $doc)
        case element(xs:appinfo) return s2bootstrap:appinfo($node, $doc)
        case element(xs:documentation) return s2bootstrap:documentation($node, $doc)
        case element(xs:annotation) return s2bootstrap:annotation($node, $doc)
        case element(xs:list) return s2bootstrap:list($node, $doc)
        case element(xs:union) return s2bootstrap:union($node, $doc)
        case element(xs:minExclusive) return s2bootstrap:minExclusive($node, $doc)
        case element(xs:minInclusive) return s2bootstrap:minInclusive($node, $doc)
        case element(xs:maxExclusive) return s2bootstrap:maxExclusive($node, $doc)
        case element(xs:maxInclusive) return s2bootstrap:maxInclusive($node, $doc)
        case element(xs:totalDigits) return s2bootstrap:totalDigits($node, $doc)
        case element(xs:fractionDigits) return s2bootstrap:fractionDigits($node, $doc)
        case element(xs:length) return s2bootstrap:length($node, $doc)
        case element(xs:minLength) return s2bootstrap:minLength($node, $doc)
        case element(xs:maxLength) return s2bootstrap:maxLength($node, $doc)
        case element(xs:enumeration) return s2bootstrap:enumeration($node, $doc)
        case element(xs:whiteSpace) return s2bootstrap:whiteSpace($node, $doc)
        case element(xs:pattern) return s2bootstrap:pattern($node, $doc)
        default return s2bootstrap:recurse($node, $doc) 
    else () 
};

declare function s2bootstrap:recurse($node as node()?, $doc as node()) as item()* {
    if ($node) 
    then for $cnode in $node/node() 
        return s2bootstrap:process-node($cnode, $doc) 
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

declare function s2bootstrap:display-list-item($element as node(), $doc as node()) {
    <div class="well">
        <div class="span2">{string($element/local-name())}</div>
        <div class="span4"><a href="item.html?schema={request:get-parameter('schema', '')}&amp;type={string($element/local-name())}&amp;name={string($element/@name)}">{string($element/@name)}</a></div>
        {if ($element/xs:annotation/xs:documentation) then <div class="span6">{$element/xs:annotation/xs:documentation[1]}</div> else ()}
    </div>
};

declare function s2bootstrap:displayType($doc as node(), $node as node()) as item()* {
    if ($node/@type)
    then if (contains(string($node/@type), ':'))
        then
            let $base := string($node/@type)
            let $eDoc := s2bootstrap:schema-from-prefix($base, $doc)
            let $extension := $eDoc//*[string(@name) eq substring-after($base, ':')]
            return
                (' ', <span>Type: <a href="#">{$base}</a></span>)
        else (' ',<span>Type:{string($node/@type)}</span>)
    else ()
};

declare function s2bootstrap:general($node as node(), $doc as node()) as item()* {
    let $base := string($node/@base)
    return
        <div class="well">{$node/local-name()}: {$base}
        {s2bootstrap:display-attributes(($node))}
        {s2bootstrap:recurse($node, $doc)}
        </div>
};

declare %public function s2bootstrap:all($node as node(), $doc as node()) {
    ()
};

declare %public function s2bootstrap:annotation($node as node(), $doc as node()) {
    s2bootstrap:recurse($node, $doc)
};

declare %public function s2bootstrap:any($node as node(), $doc as node()) {
    ()
};

declare %public function s2bootstrap:anyAttribute($node as node(), $doc as node()) {
    <div class="well">anyAttribute<br/>{s2bootstrap:display-attributes($node)}</div>
};

declare %public function s2bootstrap:appinfo($node as node(), $doc as node()) {
    s2bootstrap:recurse($node, $doc)
};

declare %public function s2bootstrap:attribute($node as node(), $doc as node()) {
    if ($node/@ref) then
    let $base := string($node/@ref)
    let $eDoc := s2bootstrap:schema-from-prefix($base, $doc)
    let $extension := $eDoc//*[string(@name) eq substring-after($base, ':')][1]
    return
        <div class="well">Attribute: {$base}
        {s2bootstrap:display-attributes(($node, $extension))}
        {s2bootstrap:displayType($doc, $extension)}
        {s2bootstrap:recurse($extension, $eDoc)}
        {s2bootstrap:recurse($node, $doc)}
        </div>
    else 
    let $base := string($node/@name)
    return
        <div class="well">Attribute: {$base}
        {s2bootstrap:display-attributes(($node))}
        {s2bootstrap:displayType($doc, $node)}
        {s2bootstrap:recurse($node, $doc)}
        </div>
};

declare %public function s2bootstrap:attributeGroup($node as node(), $doc as node()) {
    <div class="well">
        Attribute Group: {$node/@name/string()}
        {s2bootstrap:recurse($node, $doc)}
    </div>
};

declare %public function s2bootstrap:choice($node as node(), $doc as node()) {
    <div class="well">Choice{s2bootstrap:recurse($node, $doc)}</div>
};

declare %public function s2bootstrap:complexContent($node as node(), $doc as node()) {
    s2bootstrap:recurse($node, $doc)
};

declare %public function s2bootstrap:complexType($node as node(), $doc as node()) {
    if ($node/@ref) then
    let $base := string($node/@ref)
    let $eDoc := s2bootstrap:schema-from-prefix($base, $doc)
    let $extension := $eDoc//*[string(@name) eq substring-after($base, ':')]
    return
        <div class="well">ComplexType: {$base}
        {s2bootstrap:display-attributes(($node, $extension))}
        {s2bootstrap:displayType($doc, $extension)}
        {s2bootstrap:recurse($extension, $eDoc)}
        {s2bootstrap:recurse($node, $doc)}
        </div>
    else 
    let $base := string($node/@name)
    return
        <div class="well">ComplexType: {$base}
        {s2bootstrap:display-attributes(($node))}
        {s2bootstrap:displayType($doc, $node)}
        {s2bootstrap:recurse($node, $doc)}
        </div>
};

declare %public function s2bootstrap:documentation($node as node(), $doc as node()) {
    let $nl := "&#10;"
    let $nbsp := "&#160;"
    let $content := if (functx:has-simple-content($node)) then for $foo in tokenize($node/text(), "\n") return <p>{replace($foo, "^\s+", $nbsp)}</p> else $node/*
    return <div class="alert alert-success">{$content}</div>
};

declare %public function s2bootstrap:element($node as node(), $doc as node()) {
    if ($node/@ref) then
    let $base := string($node/@ref)
    let $eDoc := s2bootstrap:schema-from-prefix($base, $doc)
    let $extension := $eDoc//*[string(@name) eq substring-after($base, ':')][1]
    return
        <div class="well">Element: {$base}
        {s2bootstrap:display-attributes(($node, $extension))}
        {s2bootstrap:displayType($doc, $extension)}
        {s2bootstrap:recurse($extension, $eDoc)}
        {s2bootstrap:recurse($node, $doc)}
        </div>
    else 
    let $base := string($node/@name)
    return
        <div class="well">Element: {$base}
        {s2bootstrap:display-attributes(($node))}
        {s2bootstrap:displayType($doc, $node)}
        {s2bootstrap:recurse($node, $doc)}
        </div>
};

declare %public function s2bootstrap:enumeration($node as node(), $doc as node()) {
    <div class="well">Enumeration {s2bootstrap:display-attributes(($node))}</div>
};

declare %public function s2bootstrap:extension($node as node(), $doc as node()) {
    let $base := string($node/@base)
    let $eDoc := s2bootstrap:schema-from-prefix($base, $doc)
    let $extension := $eDoc//*[string(@name) eq substring-after($base, ':')]
    return
        <div class="well">Extension: {$base}
        {s2bootstrap:display-attributes(($node, $extension))}
        {s2bootstrap:process-node($extension, $eDoc)}
        {s2bootstrap:recurse($node, $doc)}
        </div>
};

declare %public function s2bootstrap:field($node as node(), $doc as node()) {
    ()
};

declare %public function s2bootstrap:fractionDigits($node as node(), $doc as node()) {
    ()
};

declare %public function s2bootstrap:group($node as node(), $doc as node()) {
    if ($node/@ref) then
    let $base := string($node/@ref)
    let $eDoc := s2bootstrap:schema-from-prefix($base, $doc)
    let $extension := $eDoc//*[string(@name) eq substring-after($base, ':')]
    return
        <div class="well">Group: {$base}
        {s2bootstrap:display-attributes(($node, $extension))}
        {s2bootstrap:displayType($doc, $extension)}
        {s2bootstrap:recurse($extension, $eDoc)}
        {s2bootstrap:recurse($node, $doc)}
        </div>
    else 
    let $base := string($node/@name)
    return
        <div class="well">Group: {$base}
        {s2bootstrap:display-attributes(($node))}
        {s2bootstrap:displayType($doc, $node)}
        {s2bootstrap:recurse($node, $doc)}
        </div>
};

declare %public function s2bootstrap:import($node as node(), $doc as node()) {
    let $namespace := string($node/@namespace)
    let $schemaLoc := string($node/@schemaLocation)
    let $absURI := resolve-uri($schemaLoc, base-uri($doc))
    return <div class="well">
                <div class="span6">{$namespace}</div>
                <div class="span6"><a href="index.html?schema={$absURI}">{$absURI}</a></div>
           </div>
};

declare %public function s2bootstrap:include($node as node(), $doc as node()) {
    let $namespace := string($node/@namespace)
    let $schemaLoc := string($node/@schemaLocation)
    let $absURI := resolve-uri($schemaLoc, base-uri($doc))
    return <tr>
                <td>{$namespace}</td>
                <td><a href="index.html?schema={$absURI}">{$absURI}</a></td>
           </tr>
};

declare %public function s2bootstrap:key($node as node(), $doc as node()) {
    ()
};

declare %public function s2bootstrap:keyref($node as node(), $doc as node()) {
    ()
};

declare %public function s2bootstrap:length($node as node(), $doc as node()) {
    ()
};

declare %public function s2bootstrap:list($node as node(), $doc as node()) {
    s2bootstrap:recurse($node, $doc)
};

declare %public function s2bootstrap:maxExclusive($node as node(), $doc as node()) {
    s2bootstrap:general($node, $doc)
};

declare %public function s2bootstrap:maxInclusive($node as node(), $doc as node()) {
    s2bootstrap:general($node, $doc)
};

declare %public function s2bootstrap:maxLength($node as node(), $doc as node()) {
    ()
};

declare %public function s2bootstrap:minExclusive($node as node(), $doc as node()) {
    s2bootstrap:general($node, $doc)
};

declare %public function s2bootstrap:minInclusive($node as node(), $doc as node()) {
    s2bootstrap:general($node, $doc)
};

declare %public function s2bootstrap:minLength($node as node(), $doc as node()) {
    ()
};

declare %public function s2bootstrap:notation($node as node(), $doc as node()) {
    ()
};

declare %public function s2bootstrap:pattern($node as node(), $doc as node()) {
    s2bootstrap:recurse($node, $doc)
};

declare %public function s2bootstrap:redefine($node as node(), $doc as node()) {
    s2bootstrap:recurse($node, $doc)
};

declare %public function s2bootstrap:restriction($node as node(), $doc as node()) {
    let $base := string($node/@base)
    let $eDoc := s2bootstrap:schema-from-prefix($base, $doc)
    let $extension := $eDoc//*[string(@name) eq substring-after($base, ':')]
    return
        <div class="well">Restriction: {$base}
        {s2bootstrap:display-attributes(($node, $extension))}
        {s2bootstrap:process-node($extension, $eDoc)}
        {s2bootstrap:recurse($node, $doc)}
        </div>
};

declare %public function s2bootstrap:schema($node as node(), $doc as node()) {
    s2bootstrap:recurse($node, $doc)
};

declare %public function s2bootstrap:selector($node as node(), $doc as node()) {
    ()
};

declare %public function s2bootstrap:sequence($node as node(), $doc as node()) {
    <div class="well">Sequence{s2bootstrap:recurse($node, $doc)}</div>
};

declare %public function s2bootstrap:simpleContent($node as node(), $doc as node()) {
    s2bootstrap:recurse($node, $doc)
};

declare %public function s2bootstrap:simpleType($node as node(), $doc as node()) {
    if ($node/@ref) then
    let $base := string($node/@ref)
    let $eDoc := s2bootstrap:schema-from-prefix($base, $doc)
    let $extension := $eDoc//*[string(@name) eq substring-after($base, ':')]
    return
        <div class="well">SimpleType: {$base}
        {s2bootstrap:display-attributes(($node, $extension))}
        {s2bootstrap:displayType($doc, $extension)}
        {s2bootstrap:recurse($extension, $eDoc)}
        {s2bootstrap:recurse($node, $doc)}
        </div>
    else if ($node/@name) then
    let $base := string($node/@name)
    return
        <div class="well">SimpleType: {$base}
        {s2bootstrap:display-attributes(($node))}
        {s2bootstrap:displayType($doc, $node)}
        {s2bootstrap:recurse($node, $doc)}
        </div>
    else
        <div class="well">SimpleType
        {s2bootstrap:display-attributes(($node))}
        {s2bootstrap:displayType($doc, $node)}
        {s2bootstrap:recurse($node, $doc)}
        </div>
};

declare %public function s2bootstrap:totalDigits($node as node(), $doc as node()) {
    s2bootstrap:general($node, $doc)
};

declare %public function s2bootstrap:union($node as node(), $doc as node()) {
    s2bootstrap:recurse($node, $doc)
};

declare %public function s2bootstrap:unique($node as node(), $doc as node()) {
    ()
};

declare %public function s2bootstrap:whiteSpace($node as node(), $doc as node()) {
    s2bootstrap:recurse($node, $doc)
};
