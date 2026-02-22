@echo off
:#*****************************************************************************
:#                                                                            *
:#  Filename	    intersect.bat					      *
:#                                                                            *
:#  Description	    Intersect two lists in a make file			      *
:#                                                                            *
:#  Notes	    The output is read back by a make file, and so must be    *
:#		    a valid make file itself. For example use # for comments. *
:#		    							      *
:#		    Usage:                                                    *
:#		    							      *
:#     TEMPMAK=$(TMP)\intersect.$(PID).mak				      *
:#     !IF [$(NMINCLUDE)\intersect.bat LIST1 LIST2 OUTVARNAME TEMPMAK] == 0   *
:#     !INCLUDE TEMPMAK							      *
:#     !ENDIF								      *
:#		    							      *
:#  History	                                                              *
:#   2024-01-02 JFL jf.larvoire@free.fr created this batch.                   *
:#                                                                            *
:#                  (C) Copyright 2024 Jean-Francois Larvoire                 *
:# Licensed under the Apache 2.0 license: www.apache.org/licenses/LICENSE-2.0 *
:#*****************************************************************************

setlocal EnableExtensions EnableDelayedExpansion

set "LIST=" &:# Output list
for %%a in (%~1) do for %%b in (%~2) do if "%%a"=="%%b" (
  if defined LIST set "LIST=!LIST! "
  set "LIST=!LIST!%%a"
)

set  "EXCL=^!"		&:# One exclamation mark

echo !EXCL!UNDEF %~3
if defined LIST echo %~3=!LIST!
echo INTERSECT_MSG=%~3=!LIST! ^^^^# intersect.mak %1 %2

exit /b 0
