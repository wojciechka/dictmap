namespace eval dictmap {}

if {![info exists dictmap::handleCounter]} {
    set dictmap::handleCounter 0
}

set dictmap::defaultTypeDefinition [dict create type string defaultValue ""]

proc dictmap::create {} {
    variable handleCounter
    set handle ::dictmap::dictmap[incr handleCounter]
    upvar #0 $handle d

    set d [dict create]
    dict set d types [dict create]

    return $handle
}

proc dictmap::createType {handle typeName args} {
    upvar #0 $handle d
    dict set d types $typeName [dict create]
    dict set d types $typeName fields [dict create]
    dict set d types $typeName default [dict create]

    foreach {field definition} $args {
	dictmap::createTypeField $handle $typeName $field $definition
    }
}

proc dictmap::createTypeField {handle typeName field definition} {
    upvar #0 $handle d
    variable defaultTypeDefinition

    set definition [dict merge $defaultTypeDefinition $definition]

    dict set d types $typeName default $field [dict get $definition defaultValue]
    dict set d types $typeName fields $field $definition
}

proc dictmap::mergeWithDefault {handle typeName value} {
    upvar #0 $handle d

    if {[dict exists $d types $typeName]} {
	return [dict merge [dict get $d types $typeName default] $value]
    }  else  {
	puts stderr "WTF - mergeWithDefault"
	return $value
    }
}

proc dictmap::isDictionary {handle typeName} {
    return [string equal $typeName dict]
}

proc dictmap::isComplexType {handle typeName} {
    upvar #0 $handle d

    return [dict exists $d types $typeName]
}

proc dictmap::getListType {handle type} {
    upvar #0 $handle d

    if {[lindex $type 0] == "list"} {
	return [lindex $type 1]
    }  else  {
	return ""
    }
}

proc dictmap::getFields {handle typeName} {
    upvar #0 $handle d
    if {[dict exists $d types $typeName]} {
	return [dict keys [dict get $d types $typeName fields]]
    }  else  {
	return {}
    }
}

proc dictmap::getFieldInfo {handle typeName fieldName parameter {defaultValue ""}} {
    upvar #0 $handle d
    variable defaultTypeDefinition

    if {[dict exists $d types $typeName fields $fieldName]} {
	set typeDef [dict get $d types $typeName fields $fieldName]
    }  else  {
	puts stderr "WTF - getFieldInfo $typeName"
	set typeDef $defaultTypeDefinition
    }

    if {[dict exists $typeDef $parameter]} {
	return [dict get $typeDef $parameter]
    }  else  {
	return $defaultValue
    }
}

package provide dictmap 1.0

