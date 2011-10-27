#!/usr/bin/env tclkit

cd [file dirname [info script]]
set dir [file rootname [file tail [info script]]]
if {![file exists ../dictmap-all.tcl]} {
    puts stderr "Please run build.tcl before running tests."
    exit 1
}

source ../dictmap-all.tcl

set dm [dictmap::create]
dictmap::createType $dm user \
    id {type integer} \
    username {type string} \
    fullname {type string}

dictmap::createType $dm group \
    id {type integer} \
    groupname {type string} \
    fullname {type string} \
    userlist {type {list user}}

foreach {format outformats type data} {
    json {xml dict} user {
        {"id": 1, "username": "jdoe", "fullname": "jdoe"}
    }
    dict {json xml} group {
        id 1000 groupname users fullname "Users" userlist {{id 1000 username user fullname "Example user"} {id 1001 username test fullname "Test user"}}
    }
} {
    puts "Converting $format $type information:\n[string trim $data]\n"
    set rawdata [dictmap::${format}::import $dm $type $data]
    foreach outformat $outformats {
        puts "AS $outformat:"
        puts "----------------"
        puts [string trim [dictmap::${outformat}::export $dm $type $rawdata]]
        puts "----------------"
        puts ""
    }
}
