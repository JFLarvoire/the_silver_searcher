@echo off
:#*****************************************************************************
:#                                                                            *
:#  Filename	    eval.bat						      *
:#                                                                            *
:#  Description	    Set a variable based on a batch command output string     *
:#                                                                            *
:#  Notes	    The output is read back by a make file, and so must be    *
:#		    a valid make file itself. For example use # for comments. *
:#		    							      *
:#		    Usage:                                                    *
:#		    							      *
:#     TEMPMAK=$(TMP)\eval.$(PID).mak					      *
:#     !IF [$(NMINCLUDE)\eval.bat VAR=`COMMAND` >$(TEMPMAK)] == 0	      *
:#     !INCLUDE $(TEMPMAK)						      *
:#     !ENDIF								      *
:#		    							      *
:#  History	                                                              *
:#   2024-01-05 JFL jf.larvoire@free.fr created this batch.                   *
:#   2024-10-12 JFL Return an error if no variable is specified.              *
:#                                                                            *
:#                  (C) Copyright 2024 Jean-Francois Larvoire                 *
:# Licensed under the Apache 2.0 license: www.apache.org/licenses/LICENSE-2.0 *
:#*****************************************************************************

setlocal EnableExtensions EnableDelayedExpansion

set  "EXCL=^!"		&:# One exclamation mark

set ARGS=%*

set "VAR="
set "EXPR="
set "VALUE="
for /f "usebackq tokens=1,* delims==" %%a in ('!ARGS!') do (
  set VAR=%%a
  set EXPR=%%b
  for /f "usebackq" %%v in (%%b) do set VALUE=%%v
)

if not defined VAR (
  >&2 echo eval.bat error: No variable specified.
  exit /b 1
)

echo !EXCL!UNDEF %VAR%
if defined VALUE echo %VAR%=!VALUE!
echo EVAL_MSG=%VAR%=!VALUE! ^^^^# eval.mak !EXPR!

exit /b 0
