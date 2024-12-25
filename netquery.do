mata: mata set matastrict on
mata: nt_edge_list = AssociativeArray() 
mata: nt_attr_list = AssociativeArray() 

capture program drop netquery

* netquery setedge (seller_ban) (buyer_ban), name(pn) attr(sales)
* netquery setattr idn_ban, keep(labor_N *_export)
* netquery find (labor_N > 5 & is_manu)-(sales > 10000)-(is_manu == 0), attr(v)
* netquery setedge (s) (t), name(pn) path(/Users/ted/Documents)

program define netquery

	gettoken subcom_type 0: 0
	
	if "`subcom_type'" == "setedge"{
		_nqset_edge `0'
	}
	else if "`subcom_type'" == "setattr"{
		_nqset_attr `0'
	}
	else if "`subcom_type'" == "find"{
		_nqfind `0'
	}
	else if "`subcom_type'" == "clear"{
		mata: _nqclear(nt_list)
		mata: _nqclear(nt_attr_list)
	}
	else{
		error 197
	}
end

capture program drop _nqset_edge
program define _nqset_edge
	_parseparanedge `0'
	
	local source_var `s(source_var)'
	local target_var `s(target_var)'
	local 0 `s(rest)'
	
	local swc: word count `source_var'
	local twc: word count `target_var'
	
	if (`swc' > 1){
		di as error "Only one variable can be set as source"
		error 103
	}
	
	if (`twc' > 1){
		di as error "Only one variable can be set as target"
		error 103
	}
	
	syntax [using/] [if] [in], Name(string) [ATTRibute(varlist) PATH(string)]
	
	* if specifies using, then replace the file
	if ("`using'" != ""){
		use `source_var' `target_var' `attribute' `in' `if' using `using'
	}
	
	* set edge list file into temp file
	if ("`path'" == ""){
		local path = "`c(pwd)'"
	}
	local fp "`path'/_edge_`name'"
	
	preserve
		rename `source_var' _00s				// rename source_var as _00s
		rename `target_var' _00t				// rename target_var as _00t
		char _00s[_orig_var] `source_var'
		char _00t[_orig_var] `target_var'		// retreive using local target_var: char _00s[_orig_var]
		keep _00s _00t `attribute'
		qui save `fp', replace
		mata: nt_edge_list.put("`name'", "`fp'")
	restore
	
	
	
	
	* set as source and target
	
	
end

* netquery setattr idn_ban, keep(labor_N *_export) name(pn)
capture program drop _nqset_attr
program define _nqset_attr

	syntax namelist(max=1) [using/] [if] [in], name(string) [keep(string) PATH(string)]
	
	local node_key `namelist'
	
	* set edge list file into temp file
	if ("`path'" == ""){
		local path = "`c(pwd)'"
	}
	local fp "`path'/_node_`name'"
	
	* if specifies using, then replace the file
	if ("`using'" != ""){
		use `keep' `node_key' `in' `if' using `using'
		isid `node_key'
		rename `node_key' _00n	// rename node as _00n
		char _00n[_orig_var] `node_key'
		qui save `fp', replace
		
	}
	else{
		preserve
			if "`in'" != "" keep `in'
			if "`if'" != "" keep `if'
			isid `node_key'
			keep `node_key' `keep'
			rename `node_key' _00n
			char _00n[_orig_var] `node_key'
			qui save `fp', replace
		restore
	}
	
	mata: nt_attr_list.put("`name'", "`fp'")
	
* node name _00n
end


* netquery find (labor_N > 5 & is_manu)-(sales > 10000)-(is_manu == 0), attr(v)
capture program drop _nqfind
program define _nqfind	
	
	_parseparanfind `0'
	
	local source_if `s(source_if)'
	local target_if `s(target_if)'
	local edge_if	`s(edge_if)'
	local 0 `s(rest)'
	
	if ("`source_if'" != ""){
		local source_if if `source_if'
	}
	
	if ("`target_if'" != ""){
		local target_if if `target_if'
	}
	

	

	syntax, clear [Name(string) NODEName(string) EDGEName(string) ]
	
	* specify name or (nodename, edgename)
	
	if mi("`name'`noden'`edgename'"){		// none specified
		di as error "Please specify name. Can be [name] or separate for node and edge using [nodename] and [edgename]"
		error 197
	}
	
	if ( !mi("`name'") & !mi("`nodename'`edgename'")){		// error if both specified
		di as error "Specify either one name or (nodename, edgename)."
		error 197
	}
	if ( mi("`name'") & ( (mi("`nodename'") & !mi("`edgename'")) | (!mi("`nodename'") & mi("`edgename'")) ) ){	// no name, and lack one
		di as error "[nodename] and [edgename] must be both specified. If same, use option [node]"
		error 197
	}
	if ("`name'" != "") {
		local nodename `name'
		local edgename `name'
	}
	
	tempfile sf tf ef
	mata: _node_name = st_local("nodename")
	mata: _edge_name = st_local("edgename")
	mata: st_local("_node_path", nt_attr_list.get(_node_name))
	mata: st_local("_edge_path", nt_edge_list.get(_edge_name))
	
	* First filter from source file
		* Get
		if ("`source_if'" == ""){
			* get file path from name
			use `_node_path', clear
		}
		else {
			use `source_if' using `_node_path', clear
		}
		local node_key: char _00n[_orig_var]
		qui save `sf'
	
	* Then filter from target file
		* Get
		if ("`target_if'" == ""){
			* get file path from name
			use `_node_path', clear
		}
		else {
			use `target_if' using `_node_path', clear
		}
		qui save `tf'


	* Last get from edge file
		if ("`edge_if'" == ""){
			* get file path from name
			use `_edge_path', clear
		}
		else {
			use `edge_if' using `_edge_path', clear
		}
 		// save `ef' 	// actually not needed
		confirm var _00s _00t, exact
		local source_var: char _00s[_orig_var]
		local target_var: char _00t[_orig_var]
		
	* Start merging
		* source
		di as result "Linking Source"
		rename _00s _00n
		merge m:1 _00n using `sf', nogen keep(match)
			qui ds _00n _00t, not
			local cur_all_var `r(varlist)'
			_addsuffix `cur_all_var', suf(s_)

		rename _00n `source_var'
		
		*target
		di as result "Linking Target"
		rename _00t _00n
		merge m:1 _00n using `tf', nogen keep(match)
			_addsuffix `cur_all_var', suf(t_)
		rename _00n `target_var'

end


capture mata mata drop _nqclear()
mata:
	void _nqclear( class AssociativeArray scalar  A) {
		
		real scalar i
		string scalar path
		string matrix K
		K = A.keys()
		for (i=1; i<=length(K); i++) {
				path = A.get(K[i,.]) + ".dta"
				printf("Deleted:" + path + "\n")
				unlink(path)
		 }


	}
	
end

capture program drop _parseparanedge
program define _parseparanedge, sclass

	gettoken source_var 0 : 0, parse(" ,[") match(paren) bind

	gettoken target_var 0 : 0, parse(" ,[")  match(paren) bind
	
	sreturn local source_var `source_var'
	sreturn local target_var `target_var'
	sreturn local rest `0'

end

capture program drop _parseparanfind
program define _parseparanfind, sclass

	tokenize "`0'", parse("-")
	
	if ("`2'" != "-" | "`4'" != "-"){
		di as error "Query format error. Please specify query as (source_if)-(edge_if)-(target_if), [options]. Leave empty in parantheses if no specification"
		error 197
	}
	
	gettoken source_if: 1, match(paren) bind quotes
	gettoken edge_if: 3, match(paren) bind quotes
	gettoken target_if other: 5, parse(",") match(paren) bind quotes

	sreturn local source_if `source_if'
	sreturn local target_if `target_if'
	sreturn local edge_if `edge_if'
	sreturn local rest `other'

end


capture program drop _addsuffix
program define _addsuffix
	
	syntax namelist, SUFfix(string)
	foreach v of local namelist{
		rename `v' `v'_`suffix'
	}
end
