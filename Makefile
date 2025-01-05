##-*- makefile -*-############################################################
#
#  System        : 
#  Module        : 
#  Object Name   : $RCSfile$
#  Revision      : $Revision$
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : MicroEmacs User
#  Created       : 2025-01-05 12:22:15
#  Last Modified : <250105.1223>
#
#  Description	
#
#  Notes
#
#  History
#	
#  $Log$
#
##############################################################################
#
#  Copyright (c) 2025 MicroEmacs User.
# 
#  All Rights Reserved.
# 
#  This  document  may  not, in  whole  or in  part, be  copied,  photocopied,
#  reproduced,  translated,  or  reduced to any  electronic  medium or machine
#  readable form without prior written consent from MicroEmacs User.
#
##############################################################################

default:
	grep -eo '^[a-z]+:' Makefile
docu:
	cd tdot && perl -ne "/^#' ?(.*)/ and print \"\$$1\n\"" tdot.tcl > tdot.tmd
	cd tdot && TCLLIBPATH=.. tmdoc tdot.tmd tdot.md
	cd tdot && mkdoc tdot.md tdot.html --css mini.css 
