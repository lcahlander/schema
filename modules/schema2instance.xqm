xquery version "3.0";

module namespace s2instance="http://greatlinkup.com/apps/schema/schema2instance";
import module namespace s2util = "http://greatlinkup.com/apps/schema/schema-util" at "schema-util.xqm";
import module namespace sutil="http://greatlinkup.com/apps/schema/sprint-util" at 'sprint-utils.xqm';

declare namespace xs="http://www.w3.org/2001/XMLSchema";

declare %public function s2instance:process-node($node as node()?, $model as map()) {
    if ($node) then 
    typeswitch($node) 
        case text() return () 
        case element(xs:all) return s2instance:all($node, $model)
        case element(xs:annotation) return s2instance:annotation($node, $model)
        case element(xs:any) return s2instance:any($node, $model)
        case element(xs:anyAttribute) return s2instance:anyAttribute($node, $model)
        case element(xs:appinfo) return s2instance:appinfo($node, $model)
        case element(xs:attribute) return s2instance:attribute($node, $model)
        case element(xs:attributeGroup) return s2instance:attributeGroup($node, $model)
        case element(xs:choice) return s2instance:choice($node, $model)
        case element(xs:complexContent) return s2instance:complexContent($node, $model)
        case element(xs:complexType) return s2instance:complexType($node, $model)
        case element(xs:documentation) return s2instance:documentation($node, $model)
        case element(xs:element) return s2instance:element($node, $model)
        case element(xs:enumeration) return s2instance:enumeration($node, $model)
        case element(xs:extension) return s2instance:extension($node, $model)
        case element(xs:field) return s2instance:field($node, $model)
        case element(xs:fractionDigits) return s2instance:fractionDigits($node, $model)
        case element(xs:group) return s2instance:group($node, $model)
        case element(xs:import) return s2instance:import($node, $model)
        case element(xs:include) return s2instance:include($node, $model)
        case element(xs:key) return s2instance:key($node, $model)
        case element(xs:keyref) return s2instance:keyref($node, $model)
        case element(xs:length) return s2instance:length($node, $model)
        case element(xs:list) return s2instance:list($node, $model)
        case element(xs:maxExclusive) return s2instance:maxExclusive($node, $model)
        case element(xs:maxInclusive) return s2instance:maxInclusive($node, $model)
        case element(xs:maxLength) return s2instance:maxLength($node, $model)
        case element(xs:minExclusive) return s2instance:minExclusive($node, $model)
        case element(xs:minInclusive) return s2instance:minInclusive($node, $model)
        case element(xs:minLength) return s2instance:minLength($node, $model)
        case element(xs:notation) return s2instance:notation($node, $model)
        case element(xs:pattern) return s2instance:pattern($node, $model)
        case element(xs:redefine) return s2instance:redefine($node, $model)
        case element(xs:restriction) return s2instance:restriction($node, $model)
        case element(xs:schema) return s2instance:schema($node, $model)
        case element(xs:selector) return s2instance:selector($node, $model)
        case element(xs:sequence) return s2instance:sequence($node, $model)
        case element(xs:simpleContent) return s2instance:simpleContent($node, $model)
        case element(xs:simpleType) return s2instance:simpleType($node, $model)
        case element(xs:totalDigits) return s2instance:totalDigits($node, $model)
        case element(xs:union) return s2instance:union($node, $model)
        case element(xs:unique) return s2instance:unique($node, $model)
        case element(xs:whiteSpace) return s2instance:whiteSpace($node, $model)
        default return s2instance:recurse($node, $model) 
    else () 
};

declare function s2instance:recurse($node as node()?, $model as map()) as item()* {
    if ($node) then for $cnode in $node/node() return s2instance:process-node($cnode, $model) else ()
};

declare %public function s2instance:all($node as node(), $model as map()) {
    (: Attributes:
        maxOccurs
        minOccurs
   Child Elements:

 :)
s2instance:recurse($node, $model)
};

declare %public function s2instance:annotation($node as node(), $model as map()) {
    (: Attributes:
        id
   Child Elements:
        appinfo
        documentation
 :)
s2instance:recurse($node, $model)
};

declare %public function s2instance:any($node as node(), $model as map()) {
    (: Attributes:
        maxOccurs
        minOccurs
   Child Elements:

 :)
s2instance:recurse($node, $model)
};

declare %public function s2instance:anyAttribute($node as node(), $model as map()) {
    ()
};

declare %public function s2instance:appinfo($node as node(), $model as map()) {
    (: Attributes:
        source
   Child Elements:

 :)
s2instance:recurse($node, $model)
};

declare %public function s2instance:attribute($node as node(), $model as map()) {
    (: Attributes:

   Child Elements:
        annotation
        simpleType
 :)
s2instance:recurse($node, $model)
};

declare %public function s2instance:attributeGroup($node as node(), $model as map()) {
    (: Attributes:

   Child Elements:
        annotation
 :)
s2instance:recurse($node, $model)
};

declare %public function s2instance:choice($node as node(), $model as map()) {
    (: Attributes:

   Child Elements:
        annotation
 :)
    let $subelements := $node/*
    let $xsd-node-max-occurs := xs:string ($node/@maxOccurs)
    return if ($xsd-node-max-occurs eq "unbounded")
            then 

            for $i in subsequence((1, 2, 3, 4, 5, 6, 7, 8, 9, 10), 0, util:random(8) + 1)
                let $position := util:random(count($subelements)) + 1
                let $choice := $subelements[$position]
                return
                    s2instance:process-node($choice, $model)
            else
                let $position := util:random(count($subelements)) + 1
                let $choice := $subelements[$position]
                return
                    s2instance:process-node($choice, $model)
};

declare %public function s2instance:complexContent($node as node(), $model as map()) {
    (: Attributes:
        mixed
   Child Elements:
        extension
        restriction
 :)
s2instance:recurse($node, $model)
};

declare %public function s2instance:complexType($node as node(), $model as map()) {
    (: Attributes:

   Child Elements:
        annotation
 :)
s2instance:recurse($node, $model)
};

declare %public function s2instance:documentation($node as node(), $model as map()) {
    (: Attributes:
        lang
        source
   Child Elements:

 :)
s2instance:recurse($node, $model)
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

declare function s2instance:generate-content($node as node(), $model as map()) {
    let $group := $model('group')
    return
    if ($node/@type)
    then if (starts-with($node/@type/string(), "xs:"))
            then if ($group) then ($group/*[local-name(.) eq $node/@name/string()]/text()) else s2instance:generate-xsd-content($node/@type/string(), ())
            else 
                let $base := string($node/@type)
                let $eDoc := s2util:schema-from-prefix($base, $node/root())
                let $matchName := if (contains($base, ':'))
                                    then substring-after($base, ':')
                                    else $base
                let $extension := $eDoc//*[string(@name) eq $matchName][1]
                return s2instance:process-node($extension, $model)
    else if ($node/@default)
    then xs:string ($node/@default)
    else ""
};

declare %public function s2instance:element($node as node(), $model as map()) {
    (: Attributes:

   Child Elements:
        annotation
        complexType
        simpleType
 :)
    let $pair := if ($node/@ref) then
    let $base := string($node/@ref)
    let $eDoc := s2util:schema-from-prefix($base, $node/root())
    let $matchName := if (contains($base, ':'))
                        then substring-after($base, ':')
                        else $base
    let $extension := $eDoc//*[string(@name) eq $matchName][1]
    return ($extension, $eDoc)
    else ($node, $node/root())
    
    let $xsd-node-name := xs:string ($pair[1]/@name)
    let $xsd-node-default := s2instance:generate-content($pair[1], $model)
    let $xsd-node-max-occurs := xs:string ($pair[1]/@maxOccurs)
    let $instance-node := if (s2instance:required($pair[1])) then
                    if ($xsd-node-max-occurs eq "unbounded")
                    then for $i in subsequence((1, 2, 3, 4, 5, 6, 7, 8, 9, 10), 0, util:random(8) + 1)
                        return
                        element { $xsd-node-name } { 
                            s2instance:recurse($pair[1], $model),
                            $xsd-node-default
                        }
                    else
                        element { $xsd-node-name } { 
                            s2instance:recurse($pair[1], $model),
                            $xsd-node-default
                        }
    
    else if (util:random(10) < 5)
                        then
                        element { $xsd-node-name } { 
                            s2instance:recurse($pair[1], $model),
                            $xsd-node-default
                        }
        else ()
        
    return $instance-node
};

declare %public function s2instance:enumeration($node as node(), $model as map()) {
    (: Attributes:

   Child Elements:
        annotation
 :)
s2instance:recurse($node, $model)
};

declare %public function s2instance:extension($node as node(), $model as map()) {
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
    return s2instance:process-node($extension, $model)
};

declare %public function s2instance:field($node as node(), $model as map()) {
    (: Attributes:
        xpath
   Child Elements:

 :)
s2instance:recurse($node, $model)
};

declare %public function s2instance:fractionDigits($node as node(), $model as map()) {
    (: Attributes:

   Child Elements:
        annotation
 :)
s2instance:recurse($node, $model)
};

declare %public function s2instance:group($node as node(), $model as map()) {
    (: Attributes:

   Child Elements:
        all
        annotation
        choice
        sequence
 :)
    if ($node/@ref) then
    let $base := string($node/@ref)
    let $eDoc := s2util:schema-from-prefix($base, $node/root())
    let $matchName := if (contains($base, ':'))
                        then substring-after($base, ':')
                        else $base
    let $extension := $eDoc//*[string(@name) eq $matchName][1]
    let $group := collection(sutil:examples-dir('stable'))/data-set[@name/string() eq $matchName]
    return s2instance:recurse($extension, map:new(($model, map:entry('group', $group))))
    else 
    let $group := collection(sutil:examples-dir('stable'))/data-set[@name/string() eq $node/@name/string()]
    return if (count($group)) then
    s2instance:recurse($node, map:new(($model, map:entry('group', $group[util:random(count($group) + 1) + 1]))))
    else
    s2instance:recurse($node, $model)
};

declare %public function s2instance:import($node as node(), $model as map()) {
    (: Attributes:
        namespace
        schemaLocation
   Child Elements:

 :)
s2instance:recurse($node, $model)
};

declare %public function s2instance:include($node as node(), $model as map()) {
    (: Attributes:
        schemaLocation
   Child Elements:

 :)
s2instance:recurse($node, $model)
};

declare %public function s2instance:key($node as node(), $model as map()) {
    (: Attributes:

   Child Elements:
        field
        selector
 :)
s2instance:recurse($node, $model)
};

declare %public function s2instance:keyref($node as node(), $model as map()) {
    (: Attributes:
        refer
   Child Elements:

 :)
s2instance:recurse($node, $model)
};

declare %public function s2instance:length($node as node(), $model as map()) {
    (: Attributes:

   Child Elements:
        annotation
 :)
s2instance:recurse($node, $model)
};

declare %public function s2instance:list($node as node(), $model as map()) {
    (: Attributes:
        itemType
   Child Elements:
        simpleType
 :)
s2instance:recurse($node, $model)
};

declare %public function s2instance:maxExclusive($node as node(), $model as map()) {
    ()
};

declare %public function s2instance:maxInclusive($node as node(), $model as map()) {
    ()
};

declare %public function s2instance:maxLength($node as node(), $model as map()) {
    (: Attributes:

   Child Elements:
        annotation
 :)
s2instance:recurse($node, $model)
};

declare %public function s2instance:minExclusive($node as node(), $model as map()) {
    ()
};

declare %public function s2instance:minInclusive($node as node(), $model as map()) {
    ()
};

declare %public function s2instance:minLength($node as node(), $model as map()) {
    (: Attributes:

   Child Elements:
        annotation
 :)
s2instance:recurse($node, $model)
};

declare %public function s2instance:notation($node as node(), $model as map()) {
    (: Attributes:
        name
        public
        system
   Child Elements:

 :)
s2instance:recurse($node, $model)
};

declare %public function s2instance:pattern($node as node(), $model as map()) {
    (: Attributes:
        value
   Child Elements:
        annotation
 :)
s2instance:recurse($node, $model)
};

declare %public function s2instance:redefine($node as node(), $model as map()) {
    (: Attributes:
        id
        schemaLocation
   Child Elements:
        annotation
 :)
s2instance:recurse($node, $model)
};

declare %public function s2instance:restriction($node as node(), $model as map()) {
    (: Attributes:
        base
   Child Elements:
        annotation
 :)
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
            else s2instance:recurse($node, $model)
};

declare %public function s2instance:schema($node as node(), $model as map()) {
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
s2instance:recurse($node, $model)
};

declare %public function s2instance:selector($node as node(), $model as map()) {
    (: Attributes:
        xpath
   Child Elements:

 :)
s2instance:recurse($node, $model)
};

declare %public function s2instance:sequence($node as node(), $model as map()) {
    (: Attributes:

   Child Elements:
        annotation
 :)
s2instance:recurse($node, $model)
};

declare %public function s2instance:simpleContent($node as node(), $model as map()) {
    (: Attributes:

   Child Elements:
        extension
        restriction
 :)
s2instance:recurse($node, $model)
};

declare %public function s2instance:simpleType($node as node(), $model as map()) {
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
        s2instance:recurse($extension, $model)
    else 
        s2instance:recurse($node, $model)
};

declare %public function s2instance:totalDigits($node as node(), $model as map()) {
    (: Attributes:
        value
   Child Elements:
        annotation
 :)
s2instance:recurse($node, $model)
};

declare %public function s2instance:union($node as node(), $model as map()) {
    (: Attributes:
        memberTypes
   Child Elements:
        simpleType
 :)
s2instance:recurse($node, $model)
};

declare %public function s2instance:unique($node as node(), $model as map()) {
    (: Attributes:

   Child Elements:
        field
        selector
 :)
s2instance:recurse($node, $model)
};

declare %public function s2instance:whiteSpace($node as node(), $model as map()) {
    (: Attributes:
        value
   Child Elements:
        annotation
 :)
s2instance:recurse($node, $model)
};
