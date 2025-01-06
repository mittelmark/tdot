default:
	@# list all tasks
	@grep -Eo '^[a-z]+:' Makefile | grep -v default | sed -s 's/://'
docu:
	cd tdot && mkdoc tdot.tcl tdot.tmd
	cd tdot && TCLLIBPATH=.. tmdoc tdot.tmd tdot.md
	cd tdot && mkdoc tdot.md tdot.html --css mini.css 
