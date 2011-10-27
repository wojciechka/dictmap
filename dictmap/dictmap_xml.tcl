namespace eval dictmap {}
namespace eval dictmap::xml {}

package require tdom

proc dictmap::xml::export {handle typeName data} {
    set d [dom createDocument $typeName]
    exportNode $handle $typeName $data $d [$d documentElement]
    set xml [$d asXML]
    $d delete
    return $xml
}

proc dictmap::xml::exportNodeValue {handle typeName field type value domDoc} {
    set pn [$domDoc createElement $field]
    if {[dictmap::isComplexType $handle $type]} {
	exportNode $handle $type $value $domDoc $pn
    }  elseif {$type == "dict"} {
	foreach name [dict keys $value] {
	    set value [dict get $value $name]
	    set keynode [$domDoc createElement $name]
	    set cdn [$domDoc createTextNode $value]
	    $keynode appendChild $cdn
	    $pn appendChild $keynode
	}
    }  else  {
	set cdn [$domDoc createTextNode $value]
	$pn appendChild $cdn
    }
    return $pn
}

proc dictmap::xml::exportNode {handle typeName data domDoc domNode} {
    set data [dictmap::mergeWithDefault $handle $typeName $data]
    foreach field [dict keys $data] {
	set type [dictmap::getFieldInfo $handle $typeName $field type]
	set value [dict get $data $field]

	if {[set itemType [dictmap::getListType $handle $type]] != ""} {
	    foreach value $value {
		$domNode appendChild [exportNodeValue $handle $typeName $field $itemType $value $domDoc]
	    }
	}  else  {
	    $domNode appendChild [exportNodeValue $handle $typeName $field $type $value $domDoc]
	}
    }
}

proc dictmap::xml::import {handle typeName data} {
    # TODO: remove <?xml...?> header to get proper Tcl strings 
    set domDoc [dom parse $data]
    set domNode [$domDoc documentElement]

    if {$typeName == ""} {
	set typeName [$domNode nodeName]
    }

    set value [importNode $handle $typeName $domNode]
}

proc dictmap::xml::importNode {handle typeName domNode} {
    set result [dict create]
    foreach node [$domNode childNodes] {
	set name [$node nodeName]
	lappend nodes($name) $node
    }

    foreach field [array names nodes] {
	set type [dictmap::getFieldInfo $handle $typeName $field type]
	if {[set itemType [dictmap::getListType $handle $type]] != ""} {
	    set value {}
	    foreach node $nodes($field) {
		lappend value [importNodeValue $handle $itemType $node]
	    }
	}  else  {
	    set value [importNodeValue $handle $type [lindex $nodes($field) 0]]
	}
	dict set result $field $value
    }

    return [dictmap::mergeWithDefault $handle $typeName $result]
}

proc dictmap::xml::importNodeValue {handle typeName domNode} {
    if {[dictmap::isComplexType $handle $typeName]} {
	return [importNode $handle $typeName $domNode]
    }  elseif {$typeName == "dict"} {
	set rc {}
	foreach node [$domNode childNodes] {
	    lappend rc [$node nodeName] [importChildNodesValue $node]
	}
	return $rc
    }  else  {
	return [importChildNodesValue $domNode]
    }
}

proc dictmap::xml::importChildNodesValue {domNode} {
    set rc ""
    foreach node [$domNode childNodes] {
	append rc [$node nodeValue]
    }
    return $rc
}

package provide dictmap::xml 1.0
