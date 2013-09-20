xquery version "3.0";

import module namespace config="http://greatlinkup.com/apps/schema/config" at "modules/config.xqm";

declare option exist:serialize "method=text media-type=text/plain";

let $nl := "&#10;"
return 
for $group in doc($config:data-root || '/S-7-1/schemas/CDXF_EIM.xsd')//xs:group
    let $groupName := $group/@name/string()
    let $groupERWin := $group/xs:annotation/xs:appinfo/text()
    order by $groupERWin
    return for $element in $group/xs:sequence/xs:element
            let $elementName := $element/@name/string()
            let $elementERWin := $element/xs:annotation/xs:appinfo/text()
            where $element/@name
            order by $elementERWin
            return $groupName || ',' || $groupERWin || ',' || $elementName || ',' || $elementERWin || $nl