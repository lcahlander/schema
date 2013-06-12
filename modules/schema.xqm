xquery version "3.0";

(:~
: This module provides the functions that process XML Schemas.
:
: @author Loren Cahlander, Dave Finton
: @version 1.5
: @since November 1, 2011
:)
module namespace xmlschema = "http://govworks.com/ns/schema/1.0";

import module namespace types = "http://govworks.com/ns/types/1.0" at "types.xqm";
import module namespace accounts = "http://govworks.com/ns/accounts/1.0" at "accounts.xqm";

declare namespace httpclient="http://exist-db.org/xquery/httpclient";
declare namespace xs="http://www.w3.org/2001/XMLSchema";
declare namespace xf="http://www.w3.org/2002/xforms";
declare namespace ev = "http://www.w3.org/2001/xml-events";
declare namespace bf = "http://betterform.sourceforge.net/xforms";
declare namespace bfc = "http://betterform.sourceforge.net/xforms/controls";
declare namespace davexf="http://www.dave.org/2002/xforms";
declare namespace request="http://exist-db.org/xquery/request";

declare namespace ut="http://syntactica.com/app/resources/schemas/general";

(:~
: 
: 
: @param $xsd
: @return
:)
declare function xmlschema:get-utility-schema-from-xsd (
    $xsd as node()
) as node() {

    let $utility-namespace := "http://syntactica.com/app/resources/schemas/general"
    let $utility-url := xs:string ($xsd/xs:schema/xs:import[@namespace eq $utility-namespace]/@schemaLocation)
    let $utility-request := httpclient:get ($utility-url, false(), (), ())
    let $utility-schema := $utility-request/*/xs:schema
    
    return $utility-schema

};

(:~
:
: @param $xsd-node
: @param $utility-schema
: @return The default field codes to be used for contextual viewing
:)
declare function xmlschema:construct-instance-node (
    $xsd-node as node(),
    $utility-schema as node()
) as node()* {
    
    let $xsd-node-name := xs:string ($xsd-node/@name)
    let $xsd-node-default := xs:string ($xsd-node/@default)
    let $xsd-node-min-occurs := xs:string ($xsd-node/@minOccurs)
    let $xsd-node-nillable := xs:string ($xsd-node/@nillable)
    
    let $xsd-sub-nodes := $xsd-node/xs:complexType/xs:sequence/xs:element
    
    let $instance-sub-nodes := for $xsd-sub-node in $xsd-sub-nodes
        
        let $xsd-sub-node-name := xs:string ($xsd-sub-node/@name)
        let $xsd-sub-node-type := xs:string ($xsd-sub-node/@type)
        
        let $instance-sub-node := if (string-length ($xsd-sub-node-type) > 0) then
            
            if (matches ($xsd-sub-node-type, "^xs:")) then
                xmlschema:construct-instance-node ($xsd-sub-node, $utility-schema)            
            else if (matches ($xsd-sub-node-type, "^xf:")) then
                xmlschema:construct-instance-node ($xsd-sub-node, $utility-schema)
            else if (matches ($xsd-sub-node-type, "^ut:")) then
                
                let $utility-type := replace ($xsd-sub-node-type, "^ut:", "")
                let $utility-type-xsd := 
                    element { "xs:element" } {
                        attribute name { $xsd-sub-node-name },
                        $utility-schema/xs:complexType[@name=$utility-type]
                    }
                
                let $utility-node := xmlschema:construct-instance-node ($utility-type-xsd, $utility-schema)
                
                return $utility-node
            
            else ()
        
        else
            xmlschema:construct-instance-node ($xsd-sub-node, $utility-schema)
        
        return $instance-sub-node
    
    let $instance-node := if (
        (
            (string-length ($xsd-node-min-occurs) = 0) or
            ($xsd-node-min-occurs ne "0")
        )
            and
        (
            string-length ($xsd-node-nillable) = 0
        )
    ) then
    
        element { $xsd-node-name } { 
            $instance-sub-nodes,
            $xsd-node-default
        }
    
    else ()
        
    return $instance-node

};

(:~
:
: @param $xsd
: @return The empty instance to use in our model and in the save file
:)
declare function xmlschema:xsd-to-instance (
    $xsd as node()
) as node() {

    let $utility-schema := xmlschema:get-utility-schema-from-xsd ($xsd)
    
    let $top-element := $xsd/xs:schema/xs:element

    let $instance := xmlschema:construct-instance-node ($top-element, $utility-schema)

    return $instance

};

(:~
:
: @param $xsd-node
: @param $utility-schema
: @param $instance-id-string
: @return The default field codes to be used for contextual viewing
:)
declare function xmlschema:construct-xfbind-list (
    $xsd-node as node(),
    $utility-schema as node(),
    $instance-id-string as xs:string
) as node()* {
    
    let $xsd-node-name := xs:string ($xsd-node/@name)
    let $xsd-node-type := xs:string ($xsd-node/@type)
    
    let $xfbind := if (string-length ($xsd-node-type) > 0) then
        
        if (matches ($xsd-node-type, "^xs:")) then
        
            let $node-set-string := $instance-id-string
            let $type-string := replace ($xsd-node-type, "^xs", "xf")
            
            let $xfbind-node :=
                <xf:bind nodeset="{$node-set-string}" type="{$type-string}"/>
                
            return $xfbind-node
        
        else if (matches ($xsd-node-type, "^xf:")) then
        
            let $node-set-string := $instance-id-string
            let $type-string := $xsd-node-type
            
            let $xfbind-node :=
                <xf:bind nodeset="{$node-set-string}" type="{$type-string}"/>
                
            return $xfbind-node
        
        else if (matches ($xsd-node-type, "^ut:")) then
        
            let $utility-type := replace ($xsd-node-type, "^ut:", "")
            let $utility-type-xsd := $utility-schema/xs:complexType[@name=$utility-type]
            let $utility-type-nodes := $utility-type-xsd/xs:sequence/xs:element
            
            let $utility-xfbind-list := for $utility-type-node in $utility-type-nodes
                let $new-instance-id-string := concat ($instance-id-string, "/", xs:string ($utility-type-node/@name))
                let $utility-xfbind := xmlschema:construct-xfbind-list ($utility-type-node, $utility-schema, $new-instance-id-string)
                return $utility-xfbind
            
            return $utility-xfbind-list
            
        else ()
        
    else if (count ($xsd-node/xs:simpleType) > 0) then
    
        let $restriction-base := xs:string ($xsd-node/xs:simpleType/xs:restriction/@base)
    
        let $xfbind-node :=
            <xf:bind nodeset="{$instance-id-string}" type="{$restriction-base}"/>
            
        return $xfbind-node
    
    else ()
    
    let $xsd-sub-nodes := $xsd-node/xs:complexType/xs:sequence/xs:element
    
    let $xfbind-sub-list := for $xsd-sub-node in $xsd-sub-nodes
        let $new-instance-id-string := concat ($instance-id-string, "/", xs:string ($xsd-sub-node/@name))
        let $xfbind-sub := xmlschema:construct-xfbind-list ($xsd-sub-node, $utility-schema, $new-instance-id-string)
        return $xfbind-sub
    
    return ($xfbind, $xfbind-sub-list)

};

(:~
:
: @param $xsd
: @param $instance
: @param $info
: @param $action
: @return The default field codes to be used for contextual viewing
:)
declare function xmlschema:xsd-to-xfmodel (
    $xsd as node(),
    $instance as node()?,
    $info as node()*,
    $action as xs:string
) as node() {

    let $utility-schema := xmlschema:get-utility-schema-from-xsd ($xsd)
    
    let $instance-id := 'save-data'
    let $template-id := 'template'
    let $info-id := 'info'
    let $instance-id-string := concat ("instance('", $instance-id, "')")
    
    let $top-element := $xsd/xs:schema/xs:element
    
    let $xfbind-list := xmlschema:construct-xfbind-list ($top-element, $utility-schema, $instance-id-string)
    let $template := xmlschema:xsd-to-instance ($xsd)
    let $instance-used := if ($instance) then $instance else $template
    
    let $xfmodel :=
        <xf:model id='save-data-model'>
            <xf:instance id="{$instance-id}"> {
                $instance-used
            } </xf:instance>
            <xf:instance id="{$template-id}"> {
                $template
            } </xf:instance>
            { 
                if ($info) then
                    (: <xf:instance id="{$info-id}"> :)
                        $info
                    (: </xf:instance> :)
                else ()
            }
            { $xfbind-list }
            <xf:submission id="save" method="post" action="{$action}" instance="save-data"/>
        </xf:model>
    
    return $xfmodel
    
};

(:~
: 
: 
: @param $xsd-node
: @param $utility-schema
: @param $language
: @param $is-root
: @return
:)
declare function xmlschema:construct-i18n-node (
    $xsd-node as node(), 
    $utility-schema as node(),
    $language as xs:string,
    $is-root as xs:boolean
) as node()* {
    
    let $xsd-node-name := xs:string ($xsd-node/@name)
    let $xsd-node-type := xs:string ($xsd-node/@type)
    
    let $xsd-sub-nodes := $xsd-node/xs:complexType/xs:sequence/xs:element
    
    let $i18n-sub-nodes := for $xsd-sub-node in $xsd-sub-nodes
        
        let $xsd-sub-node-type := xs:string ($xsd-sub-node/@type)
        
        let $i18n-sub-node := if (matches ($xsd-sub-node-type, "^ut:")) then
            types:ut-type-to-i18n ($xsd-sub-node-type)
        else 
            xmlschema:construct-i18n-node ($xsd-sub-node, $utility-schema, $language, fn:false())
        
        return $i18n-sub-node
        
    let $additional-read-contexts := if (string-length ($xsd-node-type) > 0) then
        <read>item</read>
    else
        <read>header</read>
    
    let $additional-search-contexts := if ($is-root) then
        <search>root</search>
    else ()
    
    let $field-node := 
        <field>
            <name>{ $xsd-node-name }</name>
            <label>{ $xsd-node-name }</label>
            <column>{ $xsd-node-name }</column>
            <type>xs:string</type>
            <contexts>
                <read>debug</read>
                { $additional-read-contexts }
                { $additional-search-contexts }
            </contexts>
            { $i18n-sub-nodes }
        </field>
    
    return $field-node

};

(:~
: 
: 
: @param $xsd
: @return
:)
declare function xmlschema:xsd-to-i18n (
    $xsd as node()
) as node() {

    let $utility-schema := xmlschema:get-utility-schema-from-xsd ($xsd)
    
    let $instance-id := 'save-data'
    let $instance-id-string := concat ("instance('", $instance-id, "')")
    
    let $top-element := $xsd/xs:schema/xs:element
    let $top-data-node := $top-element/xs:complexType/xs:sequence/xs:element[@name="Data"][1]
    let $app-name := xs:string ($top-element/@name)
    
    let $account := session:get-attribute('account')
    (: let $languages := accounts:get-supported-languages () :)
    let $languages := ("en_US")
    
    let $app-nodes := for $language in $languages
        
        let $field-node := xmlschema:construct-i18n-node ($top-data-node, $utility-schema, $language, fn:true())
        
        let $app-node := 
            <app xml:lang="{$language}">
                <name>{ $app-name }</name>
                <label>{ $app-name }</label>
                { $field-node }
            </app>
    
        return $app-node
    
    let $i18n := 
        <i18n>
            { $app-nodes }
        </i18n>
        
    return $i18n

};

(:~
: 
: 
: @param $xsd-node
: @param $utility-schema
: @return
:)
declare function xmlschema:construct-xform-node (
    $xsd-node as node(), 
    $utility-schema as node()
) as node()* {

    let $xsd-node-name := xs:string ($xsd-node/@name)
    let $xsd-node-type := xs:string ($xsd-node/@type)
    let $xsd-node-min-occurs := xs:string ($xsd-node/@minOccurs)
    let $xsd-node-nillable := xs:string ($xsd-node/@nillable)
    
    let $xsd-sub-nodes := $xsd-node/xs:complexType/xs:sequence/xs:element
    
    let $xform-sub-nodes := for $xsd-sub-node in $xsd-sub-nodes
        let $xform-sub-node := xmlschema:construct-xform-node ($xsd-sub-node, $utility-schema)
        return $xform-sub-node
        
    let $xform-node-name := if (string-length ($xsd-node-min-occurs) > 0) then
        "davexf:repeat"
    else
        "davexf:group"
        
    let $xform-node := if ($xsd-node-name eq "Data") then
    
        $xform-sub-nodes
    
    else if (string-length ($xsd-node-type) = 0) then
    
        element { $xform-node-name } {
            attribute id { $xsd-node-name },
            attribute appearance { "minimal" },
            $xform-sub-nodes
        }
        
    else if (matches ($xsd-node-type, "^xs:")) then
    
        types:xs-type-to-xform ($xsd-node-type, $xsd-node-name)
        
    else if (matches ($xsd-node-type, "^ut:")) then
        
        let $ut-xform := types:ut-type-to-xform ($xsd-node-type)
        
        let $complete-ut-xform := if ($xform-node-name = "davexf:repeat") then
            element { $xform-node-name } {
                attribute id { $xsd-node-name },
                attribute appearance { "minimal" },
                $ut-xform
            }
        else $ut-xform
        
        return $complete-ut-xform
        
    else ()
    
    return $xform-node

};

(:~
: 
: 
: @param $xsd
: @return
:)
declare function xmlschema:xsd-to-xform (
    $xsd as node()
) as node() {

    let $utility-schema := xmlschema:get-utility-schema-from-xsd ($xsd)
    
    let $instance-id := 'save-data'
    let $instance-id-string := concat ("instance('", $instance-id, "')")
    
    let $top-element := $xsd/xs:schema/xs:element
    let $data-element := $top-element/xs:complexType/xs:sequence/xs:element[@name="Data"]
    let $sub-elements := $data-element/xs:complexType/xs:sequence/xs:element
    
    let $sub-xforms := for $sub-element in $sub-elements
        let $sub-xform := xmlschema:construct-xform-node ($sub-element, $utility-schema)
        return $sub-xform

    let $xform := 
        <davexf:group model="save-data-model" appearance="bf:verticalTable"> {
            $sub-xforms
        } </davexf:group>
        
    return $xform

};
