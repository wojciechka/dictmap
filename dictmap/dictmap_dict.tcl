namespace eval dictmap {}
namespace eval dictmap::dict {}

proc dictmap::dict::export {handle typeName data} {
    return [mergeWithDefaultRecursively $handle $typeName $data]
}

proc dictmap::dict::import {handle typeName data} {
    return [mergeWithDefaultRecursively $handle $typeName $data]
}

proc dictmap::dict::mergeWithDefaultRecursively {handle typeName data} {
    set data [dictmap::mergeWithDefault $handle $typeName $data]

    foreach field [dictmap::getFields $handle $typeName] {
	set type [dictmap::getFieldInfo $handle $typeName $field type]
	set oldvalue [dict get $data $field]

	if {[set itemType [dictmap::getListType $handle $type]] != ""} {
	    set value {}
	    foreach v $oldvalue {
		lappend value [convertNodeValue $handle $itemType $v]
	    }
	}  else  {
	    set value [convertNodeValue $handle $type $oldvalue]
	}

	dict set data $field $value
    }
    return $data
}

proc dictmap::dict::convertNodeValue {handle type value} {
    if {[dictmap::isComplexType $handle $type]} {
	return [mergeWithDefaultRecursively $handle $type $value]
    }  elseif  {$type == "dict"} {
	return [dict create {*}$value]
    }  else  {
	return $value
    }
}

package provide dictmap::dict 1.0
