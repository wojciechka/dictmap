#!/usr/bin/env tclkit

set fh [open dictmap-all.tcl w]
foreach f {dictmap.tcl dictmap_dict.tcl dictmap_json.tcl dictmap_xml.tcl} {
    set sfh [open dictmap/$f r]
    puts $fh [read $sfh]
    close $sfh
}
close $fh

exit 0
