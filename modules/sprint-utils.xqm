xquery version "3.0";

module namespace sutil="http://greatlinkup.com/apps/schema/sprint-util";

import module namespace config="http://greatlinkup.com/apps/schema/config" at "config.xqm";

declare function sutil:sprint-sequence-descending() {
    for $sprint in xmldb:get-child-collections($config:data-root) 
            let $parts := fn:tokenize($sprint, '-')
            where not($sprint = 'changelog') and not($sprint = 'config') 
            order by xs:integer($parts[2]) descending, xs:integer($parts[3]) descending 
            return $sprint
};

declare function sutil:next-sprint($sprint as xs:string) as xs:string {
    let $parts := fn:tokenize($sprint, '-')
    return if (xs:integer($parts[3]) ge 5)
            then fn:string-join(('S', (xs:integer($parts[2]) + 1), '1'), '-')
            else fn:string-join(('S', $parts[2], (xs:integer($parts[3]) + 1)), '-')
};

declare function sutil:sprint-collection($sprint as xs:string) as xs:string?
{
    let $sprints := sutil:sprint-sequence-descending()
    return
    switch ($sprint)
        case ('working') return $config:data-root|| '/'  || $sprints[1]
        case ('stable') return $config:data-root|| '/'  || $sprints[2]
        default return if (xmldb:collection-available($config:data-root || '/' || $sprint))
                        then $config:data-root || '/' || $sprint
                        else ()
};

declare function sutil:working-collection() as xs:string
{
    let $sprints := sutil:sprint-sequence-descending()
    return $config:data-root || '/' || $sprints[1]
};

declare function sutil:stable-collection() as xs:string
{
    let $sprints := sutil:sprint-sequence-descending()
    return $config:data-root || '/' || $sprints[2]
};

declare function sutil:sprint-collection($sprint as xs:string) as xs:string
{
    let $sprints := sutil:sprint-sequence-descending()
    let $sprintdir := switch ($sprint)
                        case 'working' return $sprints[1]
                        case 'stable' return $sprints[2]
                        default return $sprint
    return $config:data-root || '/' || $sprintdir
};

declare function sutil:schema-dir($sprint as xs:string)
{
    sutil:sprint-collection($sprint) || '/schemas'
};

declare function sutil:examples-dir($sprint as xs:string)
{
    sutil:sprint-collection($sprint) || '/examples'
};

declare function sutil:control-dir($sprint as xs:string)
{
    sutil:sprint-collection($sprint) || '/control'
};
