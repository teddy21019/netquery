cd /Users/ted/Documents/Stata/netquery

use edges, clear
list


netquery clear

netquery setedge (s) (t), name(pn)
netquery setattr node_name using nodes, keep(is_manu bscd2 labor_N) name(pn)
netquery setattr node_name using nodes, keep(is_manu bscd2) name(pn2)

netquery clear

netquery setedge (s) (t) using edges, name(pn)
use nodes, clear
list

netquery setattr node_name, keep(is_manu bscd2 labor_N) name(pn)
netquery setattr node_name, keep(is_manu bscd2) name(pn2)


log using test, replace

netquery clear
use edges, clear
list
netquery setedge (s) (t), name(pn)

use nodes, clear
list
netquery setattr node_name using nodes, keep(is_manu bscd2 labor_N) name(pn)


netquery find (bscd2 < 8)-()-(labor_N > 10), clear name(pn)
list 
netquery find (bscd2 < 8)-()-(labor_N < 10), clear name(pn)
list 
cap noi netquery find (bscd2 < 8)-(sales > 10)-(labor_N < 10), clear name(pn)

log close
