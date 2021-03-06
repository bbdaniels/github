	
*cap prog drop make
prog make
	
	syntax [anything] [,      ///
	        toc               ///
					pkg               ///
					readme            ///
					replace           ///
					title(str)        ///
					Version(str)      /// 
					Description(str)  ///
					license(str)      ///
					AUThor(str)       ///
					affiliation(str)  ///
					url(str)          ///
					email(str)        ///
	        ancillary(str)    ///
	        install(str)      ///
				 ]
	
	//title of the package
	//local anything : di `anything'
	local capital : di ustrupper("`anything'") 
	
	//make the temporary files
	tempfile toctmp pkgtmp readtmp
	tempname hitch knot tocfile pkgfile readmefile
	
	// Creating the TOC file
	// -------------------------------------------------------
	qui file open `tocfile' using "`toctmp'", write replace
	if !missing("`version'") {
		file write `tocfile' "v `version'" _n 
	}
	if !missing("`author'") {
		file write `tocfile' "d Materials by `author'" _n 
	}
	

	if !missing("`affiliation'") {
		file write `tocfile' "d `affiliation'" _n 
	}
	if !missing("`email'") {
		file write `tocfile' "d `email'" _n 
	}
	if !missing("`url'") {
		file write `tocfile' "d `url'" _n 
	}

	
	file write `tocfile' _n
	
	*file write `tocfile' "d '`capital''" _n(2) 
	
	if !missing("`description'") {
		file write `tocfile' "d '`anything'': `description'" _n(2) 
	}
	file write `tocfile' "p `anything'" _n
	
	
	// Creating the PKG file
	// -------------------------------------------------------
	qui file open `pkgfile' using `"`pkgtmp'"', write replace
	if !missing("`version'") {
		file write `pkgfile' "v `version'" _n 
	}
	if !missing("`title'") {
		file write `pkgfile' "d '`capital'': `title'" _n
	}
	else file write `pkgfile' "d '`capital''" _n
	
	if !missing("`description'") {
		file write `pkgfile' "d " _n  "d `description'" _n
	}
	
	
	//date
	local today : di %td_CYND  date("$S_DATE", "DMY")
	file write `pkgfile' "d " _n 
	file write `pkgfile' "d Distribution-Date: `today'" _n 
	if !missing("`license'") {
		file write `pkgfile' "d License:" " `license'" _n
	}
	file write `pkgfile' "d " _n
	
	//if install and ancillary are empty, list all files 
	if missing("`install'") & missing("`ancillary'") {
		local install : dir . files "*" 
		tokenize `"`install'"'
		while `"`macval(1)'"' != "" {
			if `"`macval(1)'"' != ".DS_Store"  								    ///
			& substr(`"`macval(1)'"', -4,.) != ".pkg" 						///
			& substr(`"`macval(1)'"', -4,.) != ".toc" 						///
			& `"`macval(1)'"' != "README.md"                      ///
			& `"`macval(1)'"' != "readme.md"		                  ///
			& `"`macval(1)'"' != "index.md"		                    ///
			& `"`macval(1)'"' != "index.html"  									  ///
			& `"`macval(1)'"' != "license.md"		                  ///
			& `"`macval(1)'"' != "dependency.do"								  ///
			& `"`macval(1)'"' != "params.json"  								  ///
			& `"`macval(1)'"' != ".gitignore"									    ///
			{
				file write `pkgfile' `"F `1'"' _n
			}
			macro shift
		}
	}
	
	if !missing("`install'") {
		// get the file names install option
		tokenize `"`install'"', parse(";")	
		while !missing("`1'") {
				if "`1'" != ";" {
				file write `pkgfile' `"F `1'"' _n
			}
			macro shift
		}
	}
	if !missing("`ancillary'") {
		// get the file names ancillary option
		tokenize `"`ancillary'"', parse(";")	
		while !missing("`1'") {
				if "`1'" != ";" {
				file write `pkgfile' `"f `1'"' _n
			}
			macro shift
		}
	}
	
	
	// Creating the README.md file
	// -------------------------------------------------------
	qui file open `readmefile' using "`readtmp'", write replace
	
	if !missing("`version'") {
	  file write `readmefile' "_v. `version'_  " _n(2)
	}
	
	file write `readmefile' "`" "`anything'" "` "
	if !missing("`title'") {
		file write `readmefile' ": `title'"
	}
	local len = length(" `anything' : `title' ")
	file write `readmefile' _n  _dup(`len') "=" _n(2)
	
	
	if !missing("`description'") {
		file write `readmefile' "Description" _n
		file write `readmefile' "-----------" _n(2)
		file write `readmefile' "`description'" _n
	}
	
	if !missing("`license'") {
	  file write `readmefile' _n "### License" _n
		file write `readmefile' "`license'" _n
	}
	
	if !missing("`author'") {
	  file write `readmefile' _n "Author" _n
		file write `readmefile' "------" _n(2)
		file write `readmefile' "**`author'**  " _n
		if !missing("`affiliation'") file write `readmefile' "`affiliation'  " _n
		if !missing("`email'") file write `readmefile' "`email'  " _n
		if !missing("`url'") file write `readmefile' "<`url'>  " _n
	}

	
	//close and copy the files
	file close `tocfile'
	file close `pkgfile'
	file close `readmefile'
	if !missing("`toc'") quietly copy "`toctmp'" "stata.toc", `replace'
	if !missing("`pkg'") quietly copy "`pkgtmp'" "`anything'.pkg", `replace'
	if !missing("`readme'") quietly copy "`readtmp'" "README.md", `replace'


end



// make "test" 
//, install("githubdependency.ado;githublist.ado;githubmake.ado")
