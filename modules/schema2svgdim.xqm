xquery version "3.0";

module namespace s2svgdim="http://greatlinkup.com/ns/schema2svgdim";
import module namespace s2util = "http://greatlinkup.com/ns/schema-util" at "schema-util.xqm";

declare %public function s2svgdim:coordinate($x as xs:integer, $y as xs:integer) {
    <coordinates><x>{$x}</x><y>{$y}</y></coordinates>
};

declare %public function s2svgdim:sum-coordinates($coordinates as node()*) {
    if ($coordinates//x)
    then
        let $x := max($coordinates//x/number())
        let $y := sum($coordinates//y/number())
        return s2svgdim:coordinate($x, $y)
    else s2svgdim:coordinate(0, 0)
};

declare %public function s2svgdim:add-depth($coordinates as node()*) {
    if ($coordinates//x)
    then
        let $x := sum($coordinates//x/number())
        let $y := max($coordinates//y/number())
        return s2svgdim:coordinate($x, $y)
    else s2svgdim:coordinate(0, 0)
};

declare %public function s2svgdim:process-node($node as node(), $depth as xs:integer) {
    if ($node) then 
    typeswitch($node) 
        case text() return $node 
        case element(xs:schema) return s2svgdim:schema($node, $depth)
        case element(xs:group) return s2svgdim:group($node, $depth)
        case element(xs:element) return s2svgdim:element($node, $depth)
        case element(xs:simpleType) return s2svgdim:simpleType($node, $depth)
        case element(xs:attribute) return s2svgdim:attribute($node, $depth)
        case element(xs:attributeGroup) return s2svgdim:attributeGroup($node, $depth)
        case element(xs:anyAttribute) return s2svgdim:anyAttribute($node, $depth)
        case element(xs:complexContent) return s2svgdim:complexContent($node, $depth)
        case element(xs:restriction) return s2svgdim:restriction($node, $depth)
        case element(xs:extension) return s2svgdim:extension($node, $depth)
        case element(xs:simpleContent) return s2svgdim:simpleContent($node, $depth)
        case element(xs:complexType) return s2svgdim:complexType($node, $depth)
        case element(xs:all) return s2svgdim:all($node, $depth)
        case element(xs:choice) return s2svgdim:choice($node, $depth)
        case element(xs:sequence) return s2svgdim:sequence($node, $depth)
        case element(xs:any) return s2svgdim:any($node, $depth)
        case element(xs:include) return s2svgdim:include($node, $depth)
        case element(xs:redefine) return s2svgdim:redefine($node, $depth)
        case element(xs:import) return s2svgdim:import($node, $depth)
        case element(xs:selector) return s2svgdim:selector($node, $depth)
        case element(xs:field) return s2svgdim:field($node, $depth)
        case element(xs:unique) return s2svgdim:unique($node, $depth)
        case element(xs:key) return s2svgdim:key($node, $depth)
        case element(xs:keyref) return s2svgdim:keyref($node, $depth)
        case element(xs:notation) return s2svgdim:notation($node, $depth)
        case element(xs:appinfo) return s2svgdim:appinfo($node, $depth)
        case element(xs:documentation) return s2svgdim:documentation($node, $depth)
        case element(xs:annotation) return s2svgdim:annotation($node, $depth)
        case element(xs:list) return s2svgdim:list($node, $depth)
        case element(xs:union) return s2svgdim:union($node, $depth)
        case element(xs:minExclusive) return s2svgdim:minExclusive($node, $depth)
        case element(xs:minInclusive) return s2svgdim:minInclusive($node, $depth)
        case element(xs:maxExclusive) return s2svgdim:maxExclusive($node, $depth)
        case element(xs:maxInclusive) return s2svgdim:maxInclusive($node, $depth)
        case element(xs:totalDigits) return s2svgdim:totalDigits($node, $depth)
        case element(xs:fractionDigits) return s2svgdim:fractionDigits($node, $depth)
        case element(xs:length) return s2svgdim:length($node, $depth)
        case element(xs:minLength) return s2svgdim:minLength($node, $depth)
        case element(xs:maxLength) return s2svgdim:maxLength($node, $depth)
        case element(xs:enumeration) return s2svgdim:enumeration($node, $depth)
        case element(xs:whiteSpace) return s2svgdim:whiteSpace($node, $depth)
        case element(xs:pattern) return s2svgdim:pattern($node, $depth)
        default return s2svgdim:recurse($node, $depth) 
    else s2svgdim:coordinate(0, 0)
};

declare function s2svgdim:recurse($node as node()?, $depth as xs:integer) as item()* {
    if ($node  and $node/node()) then 
                let $coordinates := for $cnode in $node/node() 
                                    return s2svgdim:process-node($cnode, $depth)
                return s2svgdim:sum-coordinates($coordinates)
               else s2svgdim:coordinate(0, 0)
};

declare %public function s2svgdim:all($node as node(), $depth as xs:integer) {
    if ($depth > 0) 
    then s2svgdim:add-depth((s2svgdim:coordinate(0, 0), s2svgdim:recurse($node, $depth - 1)))
    else s2svgdim:coordinate(0, 0)
};

declare %public function s2svgdim:annotation($node as node(), $depth as xs:integer) {
    if ($depth > 0) 
    then s2svgdim:add-depth((s2svgdim:coordinate(0, 0), s2svgdim:recurse($node, $depth)))
    else s2svgdim:coordinate(0, 0)
};

declare %public function s2svgdim:any($node as node(), $depth as xs:integer) {
    if ($depth > 0) 
    then s2svgdim:coordinate(250, 0)
    else s2svgdim:coordinate(0, 0)
};

declare %public function s2svgdim:anyAttribute($node as node(), $depth as xs:integer) {
    if ($depth > 0) 
    then s2svgdim:coordinate(250, 0)
    else s2svgdim:coordinate(0, 0)
};

declare %public function s2svgdim:appinfo($node as node(), $depth as xs:integer) {
    if ($depth > 0) 
    then s2svgdim:coordinate(250, 0)
    else s2svgdim:coordinate(0, 0)
};

declare %public function s2svgdim:attribute($node as node(), $depth as xs:integer) {
    if ($depth > 0) 
    then s2svgdim:coordinate(250, 0)
    else s2svgdim:coordinate(0, 0)
};

declare %public function s2svgdim:attributeGroup($node as node(), $depth as xs:integer) {
    if ($depth > 0) 
    then s2svgdim:coordinate(250, 0)
    else s2svgdim:coordinate(0, 0)
};

declare %public function s2svgdim:choice($node as node(), $depth as xs:integer) {
    if ($depth > 0) 
    then s2svgdim:add-depth((s2svgdim:coordinate(100, 70), s2svgdim:recurse($node, $depth - 1)))
    else s2svgdim:coordinate(0, 0)
};

declare %public function s2svgdim:complexContent($node as node(), $depth as xs:integer) {
    s2svgdim:recurse($node, $depth)
};

declare %public function s2svgdim:complexType($node as node(), $depth as xs:integer) {
    if ($depth > 0) 
    then if ($node/@name) 
        then s2svgdim:add-depth((s2svgdim:coordinate(250, 70), s2svgdim:recurse($node, $depth - 1)))
        else s2svgdim:add-depth((s2svgdim:coordinate(0, 0), s2svgdim:recurse($node, $depth)))
    else s2svgdim:coordinate(0, 0)
};

declare %public function s2svgdim:documentation($node as node(), $depth as xs:integer) {
    if ($depth > 0) 
    then s2svgdim:coordinate(250, 0)
    else s2svgdim:coordinate(0, 0)
};

declare %public function s2svgdim:element($node as node(), $depth as xs:integer) {
    if ($depth > 0) 
    then s2svgdim:add-depth((s2svgdim:coordinate(250, 70), s2svgdim:recurse($node, $depth - 1)))
    else s2svgdim:coordinate(0, 0)
};

declare %public function s2svgdim:enumeration($node as node(), $depth as xs:integer) {
    if ($depth > 0) 
    then s2svgdim:coordinate(250, 0)
    else s2svgdim:coordinate(0, 0)
};

declare %public function s2svgdim:extension($node as node(), $depth as xs:integer) {
    if ($depth > 0) 
    then s2svgdim:add-depth((s2svgdim:coordinate(250, 70), s2svgdim:recurse($node, $depth - 1)))
    else s2svgdim:coordinate(0, 0)
};

declare %public function s2svgdim:field($node as node(), $depth as xs:integer) {
    if ($depth > 0) 
    then s2svgdim:coordinate(250, 0)
    else s2svgdim:coordinate(0, 0)
};

declare %public function s2svgdim:fractionDigits($node as node(), $depth as xs:integer) {
    if ($depth > 0) 
    then s2svgdim:coordinate(250, 0)
    else s2svgdim:coordinate(0, 0)
};

declare %public function s2svgdim:group($node as node(), $depth as xs:integer) {
    if ($depth > 0) 
    then 
    if ($node/@ref) then
    let $doc := root($node)
    let $base := string($node/@ref)
    let $eDoc := s2util:schema-from-prefix($base, $doc)
    let $matchName := if (contains($base, ':'))
                        then substring-after($base, ':')
                        else $base
    let $extension := $eDoc//*[string(@name) eq $matchName][1]
    return s2svgdim:add-depth((s2svgdim:coordinate(250, 70), s2svgdim:recurse($extension, $depth - 1)))
    else s2svgdim:add-depth((s2svgdim:coordinate(250, 70), s2svgdim:recurse($node, $depth - 1)))
    else s2svgdim:coordinate(0, 0)
};

declare %public function s2svgdim:import($node as node(), $depth as xs:integer) {
    if ($depth > 0) 
    then s2svgdim:coordinate(250, 0)
    else s2svgdim:coordinate(0, 0)
};

declare %public function s2svgdim:include($node as node(), $depth as xs:integer) {
    if ($depth > 0) 
    then s2svgdim:coordinate(250, 0)
    else s2svgdim:coordinate(0, 0)
};

declare %public function s2svgdim:key($node as node(), $depth as xs:integer) {
    if ($depth > 0) 
    then s2svgdim:coordinate(250, 0)
    else s2svgdim:coordinate(0, 0)
};

declare %public function s2svgdim:keyref($node as node(), $depth as xs:integer) {
    if ($depth > 0) 
    then s2svgdim:coordinate(250, 0)
    else s2svgdim:coordinate(0, 0)
};

declare %public function s2svgdim:length($node as node(), $depth as xs:integer) {
    if ($depth > 0) 
    then s2svgdim:coordinate(250, 0)
    else s2svgdim:coordinate(0, 0)
};

declare %public function s2svgdim:list($node as node(), $depth as xs:integer) {
    if ($depth > 0) 
    then s2svgdim:add-depth((s2svgdim:coordinate(250, 70), s2svgdim:recurse($node, $depth - 1)))
    else s2svgdim:coordinate(0, 0)
};

declare %public function s2svgdim:maxExclusive($node as node(), $depth as xs:integer) {
    if ($depth > 0) 
    then s2svgdim:coordinate(250, 0)
    else s2svgdim:coordinate(0, 0)
};

declare %public function s2svgdim:maxInclusive($node as node(), $depth as xs:integer) {
    if ($depth > 0) 
    then s2svgdim:coordinate(250, 0)
    else s2svgdim:coordinate(0, 0)
};

declare %public function s2svgdim:maxLength($node as node(), $depth as xs:integer) {
    if ($depth > 0) 
    then s2svgdim:coordinate(250, 0)
    else s2svgdim:coordinate(0, 0)
};

declare %public function s2svgdim:minExclusive($node as node(), $depth as xs:integer) {
    if ($depth > 0) 
    then s2svgdim:coordinate(250, 0)
    else s2svgdim:coordinate(0, 0)
};

declare %public function s2svgdim:minInclusive($node as node(), $depth as xs:integer) {
    if ($depth > 0) 
    then s2svgdim:coordinate(250, 0)
    else s2svgdim:coordinate(0, 0)
};

declare %public function s2svgdim:minLength($node as node(), $depth as xs:integer) {
    if ($depth > 0) 
    then s2svgdim:coordinate(250, 0)
    else s2svgdim:coordinate(0, 0)
};

declare %public function s2svgdim:notation($node as node(), $depth as xs:integer) {
    if ($depth > 0) 
    then s2svgdim:coordinate(250, 0)
    else s2svgdim:coordinate(0, 0)
};

declare %public function s2svgdim:pattern($node as node(), $depth as xs:integer) {
    if ($depth > 0) 
    then s2svgdim:add-depth((s2svgdim:coordinate(250, 70), s2svgdim:recurse($node, $depth - 1)))
    else s2svgdim:coordinate(0, 0)
};

declare %public function s2svgdim:redefine($node as node(), $depth as xs:integer) {
    if ($depth > 0) 
    then s2svgdim:add-depth((s2svgdim:coordinate(250, 70), s2svgdim:recurse($node, $depth - 1)))
    else s2svgdim:coordinate(0, 0)
};

declare %public function s2svgdim:restriction($node as node(), $depth as xs:integer) {
    if ($depth > 0) 
    then s2svgdim:coordinate(250, 0)
    else s2svgdim:coordinate(0, 0)
};

declare %public function s2svgdim:schema($node as node(), $depth as xs:integer) {
    if ($depth > 0) 
    then s2svgdim:add-depth((s2svgdim:coordinate(250, 70), s2svgdim:recurse($node, $depth - 1)))
    else s2svgdim:coordinate(0, 0)
};

declare %public function s2svgdim:selector($node as node(), $depth as xs:integer) {
    if ($depth > 0) 
    then s2svgdim:coordinate(250, 0)
    else s2svgdim:coordinate(0, 0)
};

declare %public function s2svgdim:sequence($node as node(), $depth as xs:integer) {
    if ($depth > 0) 
    then s2svgdim:add-depth((s2svgdim:coordinate(100, 70), s2svgdim:recurse($node, $depth - 1)))
    else s2svgdim:coordinate(0, 0)
};

declare %public function s2svgdim:simpleContent($node as node(), $depth as xs:integer) {
    if ($depth > 0) 
    then s2svgdim:add-depth((s2svgdim:coordinate(250, 70), s2svgdim:recurse($node, $depth - 1)))
    else s2svgdim:coordinate(0, 0)
};

declare %public function s2svgdim:simpleType($node as node(), $depth as xs:integer) {
    if ($depth > 0) 
    then s2svgdim:coordinate(250, 0)
    else s2svgdim:coordinate(0, 0)
};

declare %public function s2svgdim:totalDigits($node as node(), $depth as xs:integer) {
    if ($depth > 0) 
    then s2svgdim:add-depth((s2svgdim:coordinate(250, 70), s2svgdim:recurse($node, $depth - 1)))
    else s2svgdim:coordinate(0, 0)
};

declare %public function s2svgdim:union($node as node(), $depth as xs:integer) {
    if ($depth > 0) 
    then s2svgdim:add-depth((s2svgdim:coordinate(250, 70), s2svgdim:recurse($node, $depth - 1)))
    else s2svgdim:coordinate(0, 0)
};

declare %public function s2svgdim:unique($node as node(), $depth as xs:integer) {
    if ($depth > 0) 
    then s2svgdim:coordinate(250, 0)
    else s2svgdim:coordinate(0, 0)
};

declare %public function s2svgdim:whiteSpace($node as node(), $depth as xs:integer) {
    if ($depth > 0) 
    then s2svgdim:add-depth((s2svgdim:coordinate(250, 70), s2svgdim:recurse($node, $depth - 1)))
    else s2svgdim:coordinate(0, 0)
};
