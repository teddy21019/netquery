
## Example Usage

```
netquery clear

use edges, clear
netquery setedge (s) (t), name(pn) attr(sales)
use nodes, clear
netquery setattr node_name, keep(is_manu bscd2 labor_N) name(pn)

// or, alternatively, with using
netquery setedge (s) (t) using edge, name(pn2)
netquery setattr node_name using nodes, keep(is_manu bscd2 labor_N) name(pn2)


// query
netquery find (bscd2 < 8)-()-(labor_N > 10), clear name(pn)
netquery find (bscd2 < 8)-()-(labor_N < 10), clear name(pn)
netquery find (bscd2 < 8)-(sales > 10)-(labor_N < 10), clear name(pn)
```
