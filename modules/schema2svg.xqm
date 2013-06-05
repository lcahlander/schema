xquery version "3.0";

module namespace s2svg="http://greatlinkup.com/ns/schema2svg";

declare namespace xs = "http://www.w3.org/2001/XMLSchema";

declare %public function s2svg:svg($node as node(), $doc as node()) {
<svg width="100%" height="100%" version="1.1"
    xmlns="http://www.w3.org/2000/svg">
    <style type="text/css"><![CDATA[
        .xsd-text {font-size: 14pt;
              font-family: Arial, Helvetica, sans-serif;
         }
         
         .xsd-required, .xsd-optional {
              fill:yellow;
              stroke:black;
              stroke-width:2;
              opacity:0.8;
          }
          
          .xsd-required {
          }
          
          /* five pixels on and five off */
          .xsd-optional {
            stroke-dasharray: 10, 10;
            stroke-width:2;
          }
          
          .card-text {
            font-size: 10pt;
            font-family: Arial, Helvetica, sans-serif;
          }
          
          .annotation-text {
            font-size: 10pt;
            font-family: Arial, Helvetica, sans-serif;
          }
          
          
    ]]></style>
    {s2svg:process-node($node, $doc)}
</svg>
};

declare %public function s2svg:process-node($node as node(), $doc as node()) {
    if ($node) then 
    typeswitch($node) 
        case text() return $node 
        case element(xs:schema) return s2svg:schema($node, $doc)
        case element(xs:group) return s2svg:group($node, $doc)
        case element(xs:element) return s2svg:element($node, $doc)
        case element(xs:simpleType) return s2svg:simpleType($node, $doc)
        case element(xs:attribute) return s2svg:attribute($node, $doc)
        case element(xs:attributeGroup) return s2svg:attributeGroup($node, $doc)
        case element(xs:anyAttribute) return s2svg:anyAttribute($node, $doc)
        case element(xs:complexContent) return s2svg:complexContent($node, $doc)
        case element(xs:restriction) return s2svg:restriction($node, $doc)
        case element(xs:extension) return s2svg:extension($node, $doc)
        case element(xs:simpleContent) return s2svg:simpleContent($node, $doc)
        case element(xs:complexType) return s2svg:complexType($node, $doc)
        case element(xs:all) return s2svg:all($node, $doc)
        case element(xs:choice) return s2svg:choice($node, $doc)
        case element(xs:sequence) return s2svg:sequence($node, $doc)
        case element(xs:any) return s2svg:any($node, $doc)
        case element(xs:include) return s2svg:include($node, $doc)
        case element(xs:redefine) return s2svg:redefine($node, $doc)
        case element(xs:import) return s2svg:import($node, $doc)
        case element(xs:selector) return s2svg:selector($node, $doc)
        case element(xs:field) return s2svg:field($node, $doc)
        case element(xs:unique) return s2svg:unique($node, $doc)
        case element(xs:key) return s2svg:key($node, $doc)
        case element(xs:keyref) return s2svg:keyref($node, $doc)
        case element(xs:notation) return s2svg:notation($node, $doc)
        case element(xs:appinfo) return s2svg:appinfo($node, $doc)
        case element(xs:documentation) return s2svg:documentation($node, $doc)
        case element(xs:annotation) return s2svg:annotation($node, $doc)
        case element(xs:list) return s2svg:list($node, $doc)
        case element(xs:union) return s2svg:union($node, $doc)
        case element(xs:minExclusive) return s2svg:minExclusive($node, $doc)
        case element(xs:minInclusive) return s2svg:minInclusive($node, $doc)
        case element(xs:maxExclusive) return s2svg:maxExclusive($node, $doc)
        case element(xs:maxInclusive) return s2svg:maxInclusive($node, $doc)
        case element(xs:totalDigits) return s2svg:totalDigits($node, $doc)
        case element(xs:fractionDigits) return s2svg:fractionDigits($node, $doc)
        case element(xs:length) return s2svg:length($node, $doc)
        case element(xs:minLength) return s2svg:minLength($node, $doc)
        case element(xs:maxLength) return s2svg:maxLength($node, $doc)
        case element(xs:enumeration) return s2svg:enumeration($node, $doc)
        case element(xs:whiteSpace) return s2svg:whiteSpace($node, $doc)
        case element(xs:pattern) return s2svg:pattern($node, $doc)
        default return s2svg:recurse($node, $doc) 
    else () 
};

declare function s2svg:recurse($node as node()?, $doc as node()) as item()* {
    if ($node) then for $cnode in $node/node() return s2svg:process-node($cnode, $doc) else ()
};

declare %public function s2svg:all($node as node(), $doc as node()) {
    ()
};

declare %public function s2svg:annotation($node as node(), $doc as node()) {
    s2svg:recurse($node, $doc)
};

declare %public function s2svg:any($node as node(), $doc as node()) {
    ()
};

declare %public function s2svg:anyAttribute($node as node(), $doc as node()) {
    ()
};

declare %public function s2svg:appinfo($node as node(), $doc as node()) {
    ()
};

declare %public function s2svg:attribute($node as node(), $doc as node()) {
    ()
};

declare %public function s2svg:attributeGroup($node as node(), $doc as node()) {
    ()
};

declare %public function s2svg:choice($node as node(), $doc as node()) {
<g transform="translate(50, 105)" class="choice">
    <polygon points="0,10 10,0 50,0 60,10  60,40 50,50  10,50 0,40" fill="none" stroke="black" stroke-width="2"/>
    <circle fill="black" r="5" cx="30" cy="12"/>
    <circle fill="black" r="5" cx="30" cy="25"/>
    <circle fill="black" r="5" cx="30" cy="38"/>
    <line x1="2" y1="25" x2="12" y2="25" stroke="black"/>
    <line x1="25" y1="25" x2="58" y2="25" stroke="black"/>
    <line x1="12" y1="25" x2="25" y2="12" stroke="black"/>
    <line x1="25" y1="12" x2="48" y2="12" stroke="black"/>
    <line x1="25" y1="38" x2="48" y2="38" stroke="black"/>
    <line x1="48" y1="12" x2="48" y2="38" stroke="black"/>
    {for $ele at $count in $node/xs:element
          return
             s2svg:element($ele, 10, $count * 70, $ele/@name/string(), true(), '0..N', 'Annotation')
     }
</g>
};

declare %public function s2svg:complexContent($node as node(), $doc as node()) {
    s2svg:recurse($node, $doc)
};

declare %public function s2svg:complexType($node as node(), $doc as node()) {
let $height := count($node/*/*) * 70
return
<g class="complexType" transform="translate(50, 0)"> 
   <line class="hline" x1="0" x2="20" y1="{$height div 2}" y2="{$height div 2}" stroke="black" stroke-width="2"/>
   <line class="hline" x1="80" x2="120" y1="{$height div 2}" y2="{$height div 2}" stroke="black" stroke-width="2"/> 
   
   <line class="vline" x1="120" x2="120" y1="0" y2="{$height}" stroke="black" stroke-width="2"/>
   <g transform="translate(100 0)">
      {s2svg:recurse($node, $doc)}
   </g>
</g>
};

declare %public function s2svg:documentation($node as node(), $doc as node()) {
    ()
};

declare %public function s2svg:element($node as node(), $doc as node()) {
    if ($node/@name)
        then s2svg:element($node, 10, 0, string($node/@name), true(), '0..N', 'Annotation')
        else s2svg:element($node, 10, 0, string($node/@ref), true(), '0..N', 'Annotation')
};

declare function s2svg:element($node as node(), $x as xs:integer, $y as xs:integer, $name as xs:string, $optional as xs:boolean, 
   $cardinality as xs:string, $annotation as xs:string) as node() {
<g class="element" transform="translate({$x} {$y})">
    <line x1="0" x2="20" y1="14" y2="14" stroke="black" stroke-width="2"/>
    <rect x="10" y="0" rx="5" ry="5" width="250" height="28" class="xsd-required"/>
    <text x="15" y="20" class="xsd-text">{$name}</text>
    <text x="15" y="45" class="annotation-text" fill="gray">{$cardinality}</text>
    <text x="20" y="60" class="annotation-text" fill="gray">{$annotation}</text>
</g>
};

declare %public function s2svg:enumeration($node as node(), $doc as node()) {
    ()
};

declare %public function s2svg:extension($node as node(), $doc as node()) {
    ()
};

declare %public function s2svg:field($node as node(), $doc as node()) {
    ()
};

declare %public function s2svg:fractionDigits($node as node(), $doc as node()) {
    ()
};

declare %public function s2svg:group($node as node(), $doc as node()) {
    ()
};

declare %public function s2svg:import($node as node(), $doc as node()) {
    ()
};

declare %public function s2svg:include($node as node(), $doc as node()) {
    ()
};

declare %public function s2svg:key($node as node(), $doc as node()) {
    ()
};

declare %public function s2svg:keyref($node as node(), $doc as node()) {
    ()
};

declare %public function s2svg:length($node as node(), $doc as node()) {
    ()
};

declare %public function s2svg:list($node as node(), $doc as node()) {
    s2svg:recurse($node, $doc)
};

declare %public function s2svg:maxExclusive($node as node(), $doc as node()) {
    ()
};

declare %public function s2svg:maxInclusive($node as node(), $doc as node()) {
    ()
};

declare %public function s2svg:maxLength($node as node(), $doc as node()) {
    ()
};

declare %public function s2svg:minExclusive($node as node(), $doc as node()) {
    ()
};

declare %public function s2svg:minInclusive($node as node(), $doc as node()) {
    ()
};

declare %public function s2svg:minLength($node as node(), $doc as node()) {
    ()
};

declare %public function s2svg:notation($node as node(), $doc as node()) {
    ()
};

declare %public function s2svg:pattern($node as node(), $doc as node()) {
    s2svg:recurse($node, $doc)
};

declare %public function s2svg:redefine($node as node(), $doc as node()) {
    s2svg:recurse($node, $doc)
};

declare %public function s2svg:restriction($node as node(), $doc as node()) {
    ()
};

declare %public function s2svg:schema($node as node(), $doc as node()) {
    s2svg:recurse($node, $doc)
};

declare %public function s2svg:selector($node as node(), $doc as node()) {
    ()
};

declare %public function s2svg:sequence($node as node(), $doc as node()) {
let $height := count($node/*) * 70
return
<g class="sequence">
    <g transform="translate(-80, {$height div 2 - 20})" class="sequence">
        <polygon points="0,10 10,0 50,0 60,10  60,40 50,50  10,50 0,40" fill="none" stroke="black" stroke-width="2"/>
        <circle fill="black" r="5" cx="15" cy="25"/>
        <circle fill="black" r="5" cx="30" cy="25"/>
        <circle fill="black" r="5" cx="45" cy="25"/>
        <line x1="2" y1="25" x2="58" y2="25" stroke="black"/>
    </g>
    <g transform="translate(40 0)">
    {for $ele at $count in $node/xs:element
          return
             s2svg:element($ele, 20, $count * 70, $ele/@name/string(), true(), '0..N', 'Annotation')
     }
     </g>
</g>
};

declare %public function s2svg:simpleContent($node as node(), $doc as node()) {
    s2svg:recurse($node, $doc)
};

declare %public function s2svg:simpleType($node as node(), $doc as node()) {
    ()
};

declare %public function s2svg:totalDigits($node as node(), $doc as node()) {
    s2svg:recurse($node, $doc)
};

declare %public function s2svg:union($node as node(), $doc as node()) {
    s2svg:recurse($node, $doc)
};

declare %public function s2svg:unique($node as node(), $doc as node()) {
    ()
};

declare %public function s2svg:whiteSpace($node as node(), $doc as node()) {
    s2svg:recurse($node, $doc)
};
