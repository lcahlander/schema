xquery version "3.0";

module namespace s2svg="http://greatlinkup.com/ns/schema2svg";
import module namespace s2svgdim="http://greatlinkup.com/ns/schema2svgdim" at "schema2svgdim.xqm";
import module namespace s2util = "http://greatlinkup.com/ns/schema-util" at "schema-util.xqm";

declare namespace xs = "http://www.w3.org/2001/XMLSchema";

declare %public function s2svg:svg($node as node(), $doc as node(), $depth as xs:double) {
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
    {s2svg:process-node($node, $doc, 3)}
</svg>
};

declare %public function s2svg:process-node($node as node()?, $doc as node(), $depth as xs:double) {
    if ($node) then 
    typeswitch($node) 
        case text() return $node 
        case element(xs:schema) return s2svg:schema($node, $doc, $depth)
        case element(xs:group) return s2svg:group($node, $doc, $depth)
        case element(xs:element) return s2svg:element($node, $doc, $depth)
        case element(xs:simpleType) return s2svg:simpleType($node, $doc, $depth)
        case element(xs:attribute) return s2svg:attribute($node, $doc, $depth)
        case element(xs:attributeGroup) return s2svg:attributeGroup($node, $doc, $depth)
        case element(xs:anyAttribute) return s2svg:anyAttribute($node, $doc, $depth)
        case element(xs:complexContent) return s2svg:complexContent($node, $doc, $depth)
        case element(xs:restriction) return s2svg:restriction($node, $doc, $depth)
        case element(xs:extension) return s2svg:extension($node, $doc, $depth)
        case element(xs:simpleContent) return s2svg:simpleContent($node, $doc, $depth)
        case element(xs:complexType) return s2svg:complexType($node, $doc, $depth)
        case element(xs:all) return s2svg:all($node, $doc, $depth)
        case element(xs:choice) return s2svg:choice($node, $doc, $depth)
        case element(xs:sequence) return s2svg:sequence($node, $doc, $depth)
        case element(xs:any) return s2svg:any($node, $doc, $depth)
        case element(xs:include) return s2svg:include($node, $doc, $depth)
        case element(xs:redefine) return s2svg:redefine($node, $doc, $depth)
        case element(xs:import) return s2svg:import($node, $doc, $depth)
        case element(xs:selector) return s2svg:selector($node, $doc, $depth)
        case element(xs:field) return s2svg:field($node, $doc, $depth)
        case element(xs:unique) return s2svg:unique($node, $doc, $depth)
        case element(xs:key) return s2svg:key($node, $doc, $depth)
        case element(xs:keyref) return s2svg:keyref($node, $doc, $depth)
        case element(xs:notation) return s2svg:notation($node, $doc, $depth)
        case element(xs:appinfo) return s2svg:appinfo($node, $doc, $depth)
        case element(xs:documentation) return s2svg:documentation($node, $doc, $depth)
        case element(xs:annotation) return s2svg:annotation($node, $doc, $depth)
        case element(xs:list) return s2svg:list($node, $doc, $depth)
        case element(xs:union) return s2svg:union($node, $doc, $depth)
        case element(xs:minExclusive) return s2svg:minExclusive($node, $doc, $depth)
        case element(xs:minInclusive) return s2svg:minInclusive($node, $doc, $depth)
        case element(xs:maxExclusive) return s2svg:maxExclusive($node, $doc, $depth)
        case element(xs:maxInclusive) return s2svg:maxInclusive($node, $doc, $depth)
        case element(xs:totalDigits) return s2svg:totalDigits($node, $doc, $depth)
        case element(xs:fractionDigits) return s2svg:fractionDigits($node, $doc, $depth)
        case element(xs:length) return s2svg:length($node, $doc, $depth)
        case element(xs:minLength) return s2svg:minLength($node, $doc, $depth)
        case element(xs:maxLength) return s2svg:maxLength($node, $doc, $depth)
        case element(xs:enumeration) return s2svg:enumeration($node, $doc, $depth)
        case element(xs:whiteSpace) return s2svg:whiteSpace($node, $doc, $depth)
        case element(xs:pattern) return s2svg:pattern($node, $doc, $depth)
        default return s2svg:recurse($node, $doc, $depth) 
    else () 
};

declare function s2svg:recurse($node as node()?, $doc as node(), $depth as xs:double) as item()* {
    if ($node) then for $cnode in $node/node() return s2svg:process-node($cnode, $doc, $depth) else ()
};

declare %public function s2svg:all($node as node(), $doc as node(), $depth as xs:double) {
    ()
};

declare %public function s2svg:annotation($node as node(), $doc as node(), $depth as xs:double) {
    s2svg:recurse($node, $doc, $depth)
};

declare %public function s2svg:any($node as node(), $doc as node(), $depth as xs:double) {
<g transform="translate(50, 190)" class="any">
    <polygon points="0,10 10,0 50,0 60,10  60,40 50,50  10,50 0,40"  fill="none" stroke="black" stroke-width="2"/>
    <circle fill="black" r="5" cx="30" cy="12"/>
    <circle fill="black" r="5" cx="30" cy="25"/>
    <circle fill="black" r="5" cx="30" cy="38"/>
    <line x1="2" y1="25" x2="58" y2="25" stroke="black"/>
    <line x1="12" y1="12" x2="48" y2="12" stroke="black"/>
    <line x1="12" y1="38" x2="48" y2="38" stroke="black"/>
    <line x1="12" y1="12" x2="12" y2="38" stroke="black"/>
    <line x1="48" y1="12" x2="48" y2="38" stroke="black"/>
    {for $ele at $count in $node/xs:element
          return
             s2svg:element($ele, $doc, 10, $count * 70, $ele/@name/string(), true(), '0..N', 'Annotation', $depth - 1)
     }
</g>};

declare %public function s2svg:anyAttribute($node as node(), $doc as node(), $depth as xs:double) {
    ()
};

declare %public function s2svg:appinfo($node as node(), $doc as node(), $depth as xs:double) {
    ()
};

declare %public function s2svg:attribute($node as node(), $doc as node(), $depth as xs:double) {
    ()
};

declare %public function s2svg:attributeGroup($node as node(), $doc as node(), $depth as xs:double) {
    ()
};

declare %public function s2svg:choice($node as node(), $doc as node(), $depth as xs:double) {
    let $height := count($node/*) * 70
    let $dim := s2svgdim:process-node($node, $depth)
    let $y := ($dim//y/number() div 2)
return
<g class="sequence">
    <g transform="translate(-80, {$height div 2 - 10 - $y})" class="choice">
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
    </g>
    <g transform="translate(10 -30)">
    {for $ele at $count in $node/xs:element
          return
             s2svg:element($ele, $doc, 10, ($count - 1) * 70, $ele/@name/string(), true(), '0..N', 'Annotation', $depth - 1)
     }
     </g>
</g>
};

declare %public function s2svg:complexContent($node as node(), $doc as node(), $depth as xs:double) {
    s2svg:recurse($node, $doc, $depth)
};

declare %public function s2svg:complexType($node as node(), $doc as node(), $depth as xs:double) {
let $height := s2svgdim:recurse($node, $depth - 1)//y/number()
return
<g class="complexType" transform="translate(50, 0)"> 
   <line class="hline" x1="0" x2="20" y1="{($height div 2) - 20}" y2="{($height div 2) - 20}" stroke="black" stroke-width="2"/>
   <line class="hline" x1="80" x2="120" y1="{($height div 2) - 20}" y2="{($height div 2) - 20}" stroke="black" stroke-width="2"/> 
   
   <line class="vline" x1="120" x2="120" y1="-17" y2="{$height - 16}" stroke="black" stroke-width="2"/>
   <g transform="translate(100 0)">
      {s2svg:recurse($node, $doc, $depth)}
   </g>
</g>
};

declare %public function s2svg:documentation($node as node(), $doc as node(), $depth as xs:double) {
    ()
};

declare %public function s2svg:element($node as node(), $doc as node(), $depth as xs:double) {
    let $dim := s2svgdim:process-node($node, $depth)
    let $y := ($dim//y/number() div 2)
    return 
    if ($node/@name)
        then s2svg:element($node, $doc, 10, $y, string($node/@name), true(), '0..N', 'Annotation', $depth)
        else 
            let $base := string($node/@ref)
            let $eDoc := s2util:schema-from-prefix($base, $doc)
            let $matchName := if (contains($base, ':'))
                                then substring-after($base, ':')
                                else $base
            let $extension := $eDoc//*[string(@name) eq $matchName][1]
            return s2svg:element($extension, $eDoc, 10, $y, string($node/@ref), true(), '0..N', 'Annotation', $depth + 1)
};

declare function s2svg:element($node as node(), $doc as node(), $x as xs:integer, $y as xs:integer, $name as xs:string, $optional as xs:boolean, 
   $cardinality as xs:string, $annotation as xs:string, $depth as xs:double) as node() {
<g class="element" transform="translate({$x} {$y})">
    <line x1="0" x2="11" y1="14" y2="14" stroke="black" stroke-width="2"/>
    <rect x="10" y="0" rx="5" ry="5" width="150" height="28" class="xsd-required"/>
    <text x="15" y="20" class="xsd-text">{$name}</text>
    <text x="15" y="45" class="annotation-text" fill="gray">{$cardinality}</text>
    <text x="20" y="60" class="annotation-text" fill="gray">{$annotation}</text>
   <g transform="translate(110 0)">
      {s2svg:recurse($node, $doc, $depth - 1)}
   </g>
</g>
};

declare %public function s2svg:enumeration($node as node(), $doc as node(), $depth as xs:double) {
    ()
};

declare %public function s2svg:extension($node as node(), $doc as node(), $depth as xs:double) {
    ()
};

declare %public function s2svg:field($node as node(), $doc as node(), $depth as xs:double) {
    ()
};

declare %public function s2svg:fractionDigits($node as node(), $doc as node(), $depth as xs:double) {
    ()
};

declare %public function s2svg:group($node as node(), $doc as node(), $depth as xs:double) {
    ()
};

declare %public function s2svg:import($node as node(), $doc as node(), $depth as xs:double) {
    ()
};

declare %public function s2svg:include($node as node(), $doc as node(), $depth as xs:double) {
    ()
};

declare %public function s2svg:key($node as node(), $doc as node(), $depth as xs:double) {
    ()
};

declare %public function s2svg:keyref($node as node(), $doc as node(), $depth as xs:double) {
    ()
};

declare %public function s2svg:length($node as node(), $doc as node(), $depth as xs:double) {
    ()
};

declare %public function s2svg:list($node as node(), $doc as node(), $depth as xs:double) {
    s2svg:recurse($node, $doc, $depth)
};

declare %public function s2svg:maxExclusive($node as node(), $doc as node(), $depth as xs:double) {
    ()
};

declare %public function s2svg:maxInclusive($node as node(), $doc as node(), $depth as xs:double) {
    ()
};

declare %public function s2svg:maxLength($node as node(), $doc as node(), $depth as xs:double) {
    ()
};

declare %public function s2svg:minExclusive($node as node(), $doc as node(), $depth as xs:double) {
    ()
};

declare %public function s2svg:minInclusive($node as node(), $doc as node(), $depth as xs:double) {
    ()
};

declare %public function s2svg:minLength($node as node(), $doc as node(), $depth as xs:double) {
    ()
};

declare %public function s2svg:notation($node as node(), $doc as node(), $depth as xs:double) {
    ()
};

declare %public function s2svg:pattern($node as node(), $doc as node(), $depth as xs:double) {
    s2svg:recurse($node, $doc, $depth)
};

declare %public function s2svg:redefine($node as node(), $doc as node(), $depth as xs:double) {
    s2svg:recurse($node, $doc, $depth)
};

declare %public function s2svg:restriction($node as node(), $doc as node(), $depth as xs:double) {
    ()
};

declare %public function s2svg:schema($node as node(), $doc as node(), $depth as xs:double) {
    s2svg:recurse($node, $doc, $depth)
};

declare %public function s2svg:selector($node as node(), $doc as node(), $depth as xs:double) {
    ()
};

declare %public function s2svg:sequence($node as node(), $doc as node(), $depth as xs:double) {
let $height := count($node/*) * 70
    let $dim := s2svgdim:process-node($node, $depth)
    let $y := ($dim//y/number() div 2)
return
<g class="sequence">
    <g transform="translate(-80, {$height div 2 - 10 - $y})" class="sequence">
        <polygon points="0,10 10,0 50,0 60,10  60,40 50,50  10,50 0,40" fill="none" stroke="black" stroke-width="2"/>
        <circle fill="black" r="5" cx="15" cy="25"/>
        <circle fill="black" r="5" cx="30" cy="25"/>
        <circle fill="black" r="5" cx="45" cy="25"/>
        <line x1="2" y1="25" x2="58" y2="25" stroke="black"/>
    </g>
    <g transform="translate(10 -30)">
    {for $ele at $count in $node/xs:element
            let $name := if ($ele/@name) then $ele/@name/string() else $ele/@ref/string()
          return
             s2svg:element($ele, $doc, 10, ($count - 1) * 70, $name, true(), '0..N', 'Annotation', $depth - 1)
     }
     </g>
</g>
};

declare %public function s2svg:simpleContent($node as node(), $doc as node(), $depth as xs:double) {
    s2svg:recurse($node, $doc, $depth)
};

declare %public function s2svg:simpleType($node as node(), $doc as node(), $depth as xs:double) {
    ()
};

declare %public function s2svg:totalDigits($node as node(), $doc as node(), $depth as xs:double) {
    s2svg:recurse($node, $doc, $depth)
};

declare %public function s2svg:union($node as node(), $doc as node(), $depth as xs:double) {
    s2svg:recurse($node, $doc, $depth)
};

declare %public function s2svg:unique($node as node(), $doc as node(), $depth as xs:double) {
    ()
};

declare %public function s2svg:whiteSpace($node as node(), $doc as node(), $depth as xs:double) {
    s2svg:recurse($node, $doc, $depth)
};
