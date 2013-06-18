xquery version "3.0";

module namespace s2instance="http://greatlinkup.com/ns/schema2instance";
import module namespace s2util = "http://greatlinkup.com/ns/schema-util" at "schema-util.xqm";

declare function s2instance:process-node($node as node()?, $doc as node()) {
    if ($node) then 
    typeswitch($node) 
        case text() return () 
        case element(xs:schema) return s2instance:schema($node, $doc)
        case element(xs:group) return s2instance:group($node, $doc)
        case element(xs:element) return s2instance:element($node, $doc)
        case element(xs:simpleType) return s2instance:simpleType($node, $doc)
        case element(xs:attribute) return s2instance:attribute($node, $doc)
        case element(xs:attributeGroup) return s2instance:attributeGroup($node, $doc)
        case element(xs:anyAttribute) return s2instance:anyAttribute($node, $doc)
        case element(xs:complexContent) return s2instance:complexContent($node, $doc)
        case element(xs:restriction) return s2instance:restriction($node, $doc)
        case element(xs:extension) return s2instance:extension($node, $doc)
        case element(xs:simpleContent) return s2instance:simpleContent($node, $doc)
        case element(xs:complexType) return s2instance:complexType($node, $doc)
        case element(xs:all) return s2instance:all($node, $doc)
        case element(xs:choice) return s2instance:choice($node, $doc)
        case element(xs:sequence) return s2instance:sequence($node, $doc)
        case element(xs:any) return s2instance:any($node, $doc)
        case element(xs:include) return s2instance:include($node, $doc)
        case element(xs:redefine) return s2instance:redefine($node, $doc)
        case element(xs:import) return s2instance:import($node, $doc)
        case element(xs:selector) return s2instance:selector($node, $doc)
        case element(xs:field) return s2instance:field($node, $doc)
        case element(xs:unique) return s2instance:unique($node, $doc)
        case element(xs:key) return s2instance:key($node, $doc)
        case element(xs:keyref) return s2instance:keyref($node, $doc)
        case element(xs:notation) return s2instance:notation($node, $doc)
        case element(xs:appinfo) return s2instance:appinfo($node, $doc)
        case element(xs:documentation) return s2instance:documentation($node, $doc)
        case element(xs:annotation) return s2instance:annotation($node, $doc)
        case element(xs:list) return s2instance:list($node, $doc)
        case element(xs:union) return s2instance:union($node, $doc)
        case element(xs:minExclusive) return s2instance:minExclusive($node, $doc)
        case element(xs:minInclusive) return s2instance:minInclusive($node, $doc)
        case element(xs:maxExclusive) return s2instance:maxExclusive($node, $doc)
        case element(xs:maxInclusive) return s2instance:maxInclusive($node, $doc)
        case element(xs:totalDigits) return s2instance:totalDigits($node, $doc)
        case element(xs:fractionDigits) return s2instance:fractionDigits($node, $doc)
        case element(xs:length) return s2instance:length($node, $doc)
        case element(xs:minLength) return s2instance:minLength($node, $doc)
        case element(xs:maxLength) return s2instance:maxLength($node, $doc)
        case element(xs:enumeration) return s2instance:enumeration($node, $doc)
        case element(xs:whiteSpace) return s2instance:whiteSpace($node, $doc)
        case element(xs:pattern) return s2instance:pattern($node, $doc)
        default return s2instance:recurse($node, $doc) 
    else () 
};

declare function s2instance:recurse($node as node()?, $doc as node()) as item()* {
    if ($node) then for $cnode in $node/node() return s2instance:process-node($cnode, $doc) else ()
};

declare function s2instance:all($node as node(), $doc as node()) {
    ()
};

declare function s2instance:annotation($node as node(), $doc as node()) {
    s2instance:recurse($node, $doc)
};

declare function s2instance:any($node as node(), $doc as node()) {
    ()
};

declare function s2instance:anyAttribute($node as node(), $doc as node()) {
    ()
};

declare function s2instance:appinfo($node as node(), $doc as node()) {
    ()
};

declare function s2instance:attribute($node as node(), $doc as node()) {
    ()
};

declare function s2instance:attributeGroup($node as node(), $doc as node()) {
    ()
};

declare function s2instance:choice($node as node(), $doc as node()) {
    let $subelements := $node/*
    let $xsd-node-max-occurs := xs:string ($node/@maxOccurs)
    return if ($xsd-node-max-occurs eq "unbounded")
            then 

            for $i in subsequence((1, 2, 3, 4, 5, 6, 7, 8, 9, 10), 0, util:random(8) + 1)
                let $position := util:random(count($subelements)) + 1
                let $choice := $subelements[$position]
                return
                    s2instance:process-node($choice, $doc)
            else
                let $position := util:random(count($subelements)) + 1
                let $choice := $subelements[$position]
                return
                    s2instance:process-node($choice, $doc)

    
};

declare function s2instance:complexContent($node as node(), $doc as node()) {
    s2instance:recurse($node, $doc)
};

declare function s2instance:complexType($node as node(), $doc as node()) {
    s2instance:recurse($node, $doc)
};

declare function s2instance:documentation($node as node(), $doc as node()) {
    ()
};

declare %private function s2instance:required($node) as xs:boolean {
    let $xsd-node-min-occurs := xs:string ($node/@minOccurs)
    let $xsd-node-nillable := xs:string ($node/@nillable)
return if (
        (
            (string-length ($xsd-node-min-occurs) = 0) or
            ($xsd-node-min-occurs ne "0")
        )
            and
        (
            string-length ($xsd-node-nillable) = 0
        )
    ) then true() else false()
};

declare function s2instance:generate-xsd-content($type as xs:string, $restrictions as node()*) {
    switch ($type) 
      case "xs:string" return if ($restrictions/xs:maxLength) then s2util:generate-lorumipsum($restrictions/xs:maxLength/@value/number())
                                                              else  s2util:generate-lorumipsum(30)
      case "xs:decimal" return "1"
      case "xs:float" return "1.0"
      case "xs:base64Binary" return "1"
      case "xs:short" return "1"
      case "xs:date" return string(current-date())
      case "xs:time" return string(current-time())
      case "xs:integer" return "1"
      case "xs:dateTime" return string(current-dateTime())
      case "xs:boolean" return "true"
      case "xs:Name" return  if ($restrictions/xs:maxLength) then s2util:generate-lorumipsum($restrictions/xs:maxLength/@value/number())
                                                              else  s2util:generate-lorumipsum(30)
      default return "Type {$type} sample instance has not been implemented"
};

declare function s2instance:generate-content($node as node(), $doc as node()) {
    if ($node/@type)
    then if (starts-with($node/@type/string(), "xs:"))
            then s2instance:generate-xsd-content($node/@type/string(), ())
            else 
                let $base := string($node/@type)
                let $eDoc := s2util:schema-from-prefix($base, $doc)
                let $matchName := if (contains($base, ':'))
                                    then substring-after($base, ':')
                                    else $base
                let $extension := $eDoc//*[string(@name) eq $matchName][1]
                return s2instance:process-node($extension, $eDoc)
    else if ($node/@default)
    then xs:string ($node/@default)
    else ""
};

declare function s2instance:element($node as node(), $doc as node()) {
    let $pair := if ($node/@ref) then
    let $base := string($node/@ref)
    let $eDoc := s2util:schema-from-prefix($base, $doc)
    let $matchName := if (contains($base, ':'))
                        then substring-after($base, ':')
                        else $base
    let $extension := $eDoc//*[string(@name) eq $matchName][1]
    return ($extension, $eDoc)
    else ($node, $doc)
    
    let $xsd-node-name := xs:string ($pair[1]/@name)
    let $xsd-node-default := s2instance:generate-content($pair[1], $pair[2])
    let $xsd-node-max-occurs := xs:string ($pair[1]/@maxOccurs)
    let $instance-node := if (s2instance:required($pair[1])) then
                    if ($xsd-node-max-occurs eq "unbounded")
                    then for $i in subsequence((1, 2, 3, 4, 5, 6, 7, 8, 9, 10), 0, util:random(8) + 1)
                        return
                        element { $xsd-node-name } { 
                            s2instance:recurse($pair[1], $pair[2]),
                            $xsd-node-default
                        }
                    else
                        element { $xsd-node-name } { 
                            s2instance:recurse($pair[1], $pair[2]),
                            $xsd-node-default
                        }
    
    else if (util:random(10) < 5)
                        then
                        element { $xsd-node-name } { 
                            s2instance:recurse($pair[1], $pair[2]),
                            $xsd-node-default
                        }
        else ()
        
    return $instance-node
};

declare function s2instance:enumeration($node as node(), $doc as node()) {
    ()
};

declare function s2instance:extension($node as node(), $doc as node()) {
    let $base := string($node/@base)
    let $eDoc := s2util:schema-from-prefix($base, $doc)
    let $matchName := if (contains($base, ':'))
                        then substring-after($base, ':')
                        else $base
    let $extension := $eDoc//*[string(@name) eq $matchName][1]
    return s2instance:process-node($extension, $eDoc)
};

declare function s2instance:field($node as node(), $doc as node()) {
    ()
};

declare function s2instance:fractionDigits($node as node(), $doc as node()) {
    ()
};

declare function s2instance:group($node as node(), $doc as node()) {
    if ($node/@ref) then
    let $base := string($node/@ref)
    let $eDoc := s2util:schema-from-prefix($base, $doc)
    let $matchName := if (contains($base, ':'))
                        then substring-after($base, ':')
                        else $base
    let $extension := $eDoc//*[string(@name) eq $matchName][1]
    return s2instance:recurse($extension, $eDoc)
    else s2instance:recurse($node, $doc)
};

declare function s2instance:import($node as node(), $doc as node()) {
    ()
};

declare function s2instance:include($node as node(), $doc as node()) {
    ()
};

declare function s2instance:key($node as node(), $doc as node()) {
    ()
};

declare function s2instance:keyref($node as node(), $doc as node()) {
    ()
};

declare function s2instance:length($node as node(), $doc as node()) {
    ()
};

declare function s2instance:list($node as node(), $doc as node()) {
    s2instance:recurse($node, $doc)
};

declare function s2instance:maxExclusive($node as node(), $doc as node()) {
    ()
};

declare function s2instance:maxInclusive($node as node(), $doc as node()) {
    ()
};

declare function s2instance:maxLength($node as node(), $doc as node()) {
    ()
};

declare function s2instance:minExclusive($node as node(), $doc as node()) {
    ()
};

declare function s2instance:minInclusive($node as node(), $doc as node()) {
    ()
};

declare function s2instance:minLength($node as node(), $doc as node()) {
    ()
};

declare function s2instance:notation($node as node(), $doc as node()) {
    ()
};

declare function s2instance:pattern($node as node(), $doc as node()) {
    s2instance:recurse($node, $doc)
};

declare function s2instance:redefine($node as node(), $doc as node()) {
    s2instance:recurse($node, $doc)
};

declare function s2instance:restriction($node as node(), $doc as node()) {
    if ($node//xs:enumeration) 
    then
        let $enum-list := $node//xs:enumeration/@value/string()
        let $item-number := util:random(count($enum-list)) + 1
        return $enum-list[$item-number]
    else 
        let $base := $node/@base/string()
        return
            if (starts-with($base, "xs:"))
            then s2instance:generate-xsd-content($base, $node/node())
            else s2instance:recurse($node, $doc)
};

declare function s2instance:schema($node as node(), $doc as node()) {
    s2instance:recurse($node, $doc)
};

declare function s2instance:selector($node as node(), $doc as node()) {
    ()
};

declare function s2instance:sequence($node as node(), $doc as node()) {
    s2instance:recurse($node, $doc)
};

declare function s2instance:simpleContent($node as node(), $doc as node()) {
    s2instance:recurse($node, $doc)
};

declare function s2instance:simpleType($node as node(), $doc as node()) {
    if ($node/@ref) then
    let $base := string($node/@ref)
    let $eDoc := s2util:schema-from-prefix($base, $doc)
    let $matchName := if (contains($base, ':'))
                        then substring-after($base, ':')
                        else $base
    let $extension := $eDoc//*[string(@name) eq $matchName][1]
    return
        s2instance:recurse($extension, $eDoc)
    else 
        s2instance:recurse($node, $doc)
};

declare function s2instance:totalDigits($node as node(), $doc as node()) {
    s2instance:recurse($node, $doc)
};

declare function s2instance:union($node as node(), $doc as node()) {
    s2instance:recurse($node, $doc)
};

declare function s2instance:unique($node as node(), $doc as node()) {
    ()
};

declare function s2instance:whiteSpace($node as node(), $doc as node()) {
    s2instance:recurse($node, $doc)
};
