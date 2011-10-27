namespace eval dictmap {}
namespace eval dictmap::json {}

package require json

proc dictmap::json::export {handle typeName data} {
    return [exportValue $handle $typeName $data]

}

proc dictmap::json::exportValue {handle typeName data} {
    set data [dictmap::mergeWithDefault $handle $typeName $data]

    set rc [list]
    foreach field [dict keys $data] {
	set type [dictmap::getFieldInfo $handle $typeName $field type]
	set value [dict get $data $field]

	if {[set itemType [dictmap::getListType $handle $type]] != ""} {
	    set values [list]
	    foreach value $value {
		lappend values [exportNodeValue $handle $itemType $value]
	    }
	    set value "\[[join $values ,]\]"
	}  else  {
	    set value [exportNodeValue $handle $type $value]
	}
	lappend rc "[exportNodeValue $handle string $field]:$value"
    }
    return "\{[join $rc ,]\}"
}

proc dictmap::json::exportNodeValue {handle type value} {
    if {[dictmap::isComplexType $handle $type]} {
	return [exportValue $handle $type $value]
    }  elseif {$type == "dict"} {
	set rc {}
	foreach name [dict keys $value] {
	    set value [dict get $value $name]
	    lappend rc "[exportNodeValue $handle string $name]:[exportNodeValue $handle string $value]"
	}
	return "\{[join $rc ,]\}"
    }  elseif {[string is integer -strict $value]} {
	return $value
    }  else  {
	set value [string map \
	    [list "\"" "\\\"" "\r" "\\r" "\n" "\\n" "\t" "\\t"] \
	    $value]
	return "\"$value\""
    }
}

proc dictmap::json::import {handle typeName data} {
    set data [json::json2dict $data]
    return [importNode $handle $typeName $data]
}

proc dictmap::json::importNode {handle typeName data} {
    set data [dictmap::mergeWithDefault $handle $typeName $data]

    foreach field [dictmap::getFields $handle $typeName] {
	set type [dictmap::getFieldInfo $handle $typeName $field type]
	set oldvalue [dict get $data $field]

	if {[set itemType [dictmap::getListType $handle $type]] != ""} {
	    set value {}
	    foreach v $oldvalue {
		lappend value [importNodeValue $handle $itemType $v]
	    }
	}  else  {
	    set value [importNodeValue $handle $type $oldvalue]
	}

	dict set data $field $value
    }
    return $data
}

proc dictmap::json::importNodeValue {handle type value} {
    if {[dictmap::isComplexType $handle $type]} {
	return [importNode $handle $type $value]
    }  else  {
	return $value
    }
}

package provide dictmap::json 1.0
