###############################################################################
#									      #
#   File name:	    All.mak						      #
#									      #
#   Description:    NMake file to build all MS OS versions of a program.      #
#									      #
#   Notes:	    Depends on a series of target-OS-specific make files,     #
#		    that know how to build a program for that target OS.      #
#		    Ex: BIOS.mak, DOS.mak, WIN32.mak, WIN64.mak		      #
#		    By convention, each such make file outputs the files it   #
#		    builds into a directory tree with that base name.	      #
#		    Ex: BIOS\*, DOS\*, WIN32\*, WIN64\*			      #
#		    							      #
#		    Use with configure.bat and make.bat, which define the     #
#		    necessary variables.				      #
#		    							      #
#		    Usage: make.bat [options] [definitions] [targets]	      #
#									      #
#		    Sample targets:					      #
#		    clean	Erase all output files built for all targets. #
#		    {prog}.com	           Build BIOS and DOS {prog}.com.     #
#		    Debug\{prog}.com	   Build the debug versions of the 2. #
#		    {prog}.exe	     Build DOS, WIN32, and WIN64 {prog}.exe.  #
#		    Debug\{prog}.exe	   Build the debug versions of the 3. #
#		    BIOS\{prog}.com        Build the BIOS release version.    #
#		    BIOS\Debug\{prog}.com  Build the BIOS debug version.      #
#		    DOS\{prog}.com         Build the DOS release version.     #
#		    DOS\Debug\{prog}.com   Build the DOS debug version.	      #
#		    DOS\{prog}.exe         Build the DOS release version.     #
#		    DOS\Debug\{prog}.exe   Build the DOS debug version.	      #
#		    WIN32\{prog}.exe       Build the WIN32 release version.   #
#		    WIN32\Debug\{prog}.exe Build the WIN32 debug version.     #
#		    WIN64\{prog}.exe       Build the WIN64 release version.   #
#		    WIN64\Debug\{prog}.exe Build the WIN64 debug version.     #
#									      #
#		    If a specific target [path\]{prog}.exe is specified,      #
#		    includes the corresponding {prog}.mak if it exists.       #
#		    This make file, defines the files to use beyond the       #
#		    default {prog}.c/{prog}.obj; Compiler options; etc.       #
#		    SOURCES	Source files to compile.		      #
#		    OBJECTS	Object files to link. Optional.		      #
#		    PROGRAM	The node name of the program to build. Opt.   #
#									      #
#		    In the absence of a {prog}.mak file, or if one of the     #
#		    generic targets is used, then the default Dirs.mak or     #
#		    Files.mak are used instead. Same definitions.	      #
#									      #
#		    Note that these sub-make files are designed to be	      #
#		    OS-independant. The goal is to reuse them to build	      #
#		    the same program under Unix/Linux too. So for example,    #
#		    all paths must contain forward slashes. Also avoid using  #
#		    nmake-specific !conditional preprocessing directives.     #
#									      #
#		    Another design goal is to use that same All.mak	      #
#		    in complex 1-project environments (One Files.mak defines  #
#		    all project components); And in simple multiple-project   #
#		    environments (No Files.mak; Most programs have a single   #
#		    source file, and use default compiler options).	      #
#		    							      #
#		    To add support for a new OS or processor:                 #
#		    - Choose a unique name for that OS/Proc pair. Ex: CPM86   #
#		    - Update configure.bat to locate the necessary build      #
#		      tools, and set the necessary variables. Ex: CPM86_CC, ..#
#		    - Create a new CPM86.mak file that knows how to build for #
#		      that OS/proc pair. Use WIN95.mak as a sample for a make #
#		      file that is derived from a generic one (WIN32.mak).    #
#		    - Manage below the OS=CPM86 value;                        #
#		      Add definitions for DOCPM86 and IFCPM86.                #
#		    - Add below inference rules for building CPM86 targets.   #
#		    - Add below a set of dispatching rules for these targets. #
#		      DISPATCH_OS=CPM86                                       #
#		      !INCLUDE "Dispatch.mak"                                 #
#		    - Update the help in the end to show the new capabilities.#
#		    							      #
#  History:								      #
#    2000-09-21 JFL Adapted from earlier projects.			      #
#    2001-01-11 JFL Added generation of 32-bit EXE.			      #
#    2001-01-11 JFL Generalized for use on multiple programs.		      #
#    2002-04-08 JFL Use debug versions of the MultiOS libraries.	      #
#    2002-05-21 JFL Build either a debug or a release version.		      #
#    2002-11-29 JFL Give the same name to the 16-bits EXE as to the 32-bits   #
#		    version, but put it in a different directory.	      #
#    2002-12-18 JFL And name these directories DOS and WIN32 repectively.     #
#    2003-03-21 JFL Move file dependancies to a sub-makefile called Files.mak.#
#		    Restructure directories as DOS, DOS\OBJ, DOS\LIST, etc.   #
#    2003-03-31 JFL Renamed as DosWin32.mak, and coupled with new make.bat.   #
#    2003-04-15 JFL Added inference rules for making {OS_NAME}\{prog}.exe     #
#		     targets.						      #
#    2003-06-16 JFL Fixed bound DOS+Win32 builds, broken in last change.      #
#    2003-06-16 JFL Fixed problem with files.mak, which must NOT be present   #
#                    if we don't mean to use it.			      #
#    2010-03-19 JFL Added support for building 64-bits Windows programs.      #
#    2010-03-26 JFL Restructured macros w.more generic 16/32/64 bits versions.#
#    2010-04-07 JFL Added dynamic generation of OBJECTS by src2objs.bat.      #
#		    Split in 4: DosWin.mak dos.mak win32.mak win64.mak        #
#    2012-10-04 JFL Added rules for the case where we just have a .mak file   #
#		    that matches the target names.			      #
#    2012-10-17 JFL Changed the output directories structure to:	      #
#		    [DOS[\$(MEM)]|WIN32|WIN64][\Debug][\OBJ|\LIST]	      #
#		    Removed the special handling of MultiOS.lib.	      #
#    2015-01-06 JFL Target prog.exe also makes the WIN64 version.	      #
#		    Added target debug\prog.exe, to make the 3 debug versions.#
#		    The all target now makes the 6 normal and debug versions. #
#    2015-01-16 JFL Added variable OS for specifying the target OSs list.     #
#		    Pass selected cmd-line definitions thru to sub-make files.#
#    2015-10-21 JFL If PROGRAMS is defined, build $(PROGRAMS) by default.     #
#    2015-10-27 JFL Added support for .com targets.			      #
#		    Added support for BIOS OS targets.			      #
#		    Fixed the OS variable default value handling.             #
#    2015-11-05 JFL Added WINVER variable to force the target OS version.     #
#    2015-11-06 JFL Removed all OS-specific inference rules, and use          #
#		    Dispatch.mak to get them from the OS-specific make files. #
#		    Renamed as All.mak to reflect new generic capabilities.   #
#    2015-12-15 JFL Added dynamic checking of prerequisites set in Files.mak. #
#    2016-04-11 JFL Renamed NODOSLIB as BIOSLIB.                              #
#    2016-04-22 JFL Renamed the MULTIOS library as SYSLIB.		      #
#    2016-09-28 JFL Avoid having the word "Error" in the log unnecessarily.   #
#		    Added support for the optional OUTDIR.		      #
#		    Rewrote the all rule handling to record errors, and	      #
#		    report them in the end.				      #
#    2016-10-03 JFL Added target list_programs.                               #
#		    Fixed errors comparing the WIN95 and WIN32 C compilers.   #
#    2016-10-04 JFL Updated fix comparing the WIN95 and WIN32 C compilers.    #
#		    Use the shell PID to generate unique temp file names.     #
#		    Display messages only if variable MESSAGES is defined.    #
#    2016-10-04 JFL Target distclean must delete config.*.bat files.	      #
#    2016-10-11 JFL Adapted for use in SysToolsLib global C include dir.      #
#    2016-10-20 JFL Added missing inference rules to build .asm programs.     #
#    2016-11-07 JFL Do not hide any command that's part of a build.           #
#    2017-02-22 JFL Added mechanism to build subprojects defined in Files.mak.#
#		    Avoid building OS targets with no corresp. make file.     #
#                   Allow building a makefile-defined executable.	      #
#    2017-02-28 JFL Bug fix: Enclose all $(MAKEPATH) references in "quotes".  #
#    2017-03-02 JFL Added the CLEAN_DIRS and CLEAN_FILES variables.           #
#    2017-03-13 JFL Fix build if environment variable OS is not defined.      #
#    2017-08-29 JFL Bugfix: The help target did output a "1 file copied" msg. #
#    2017-10-22 JFL Changed OUTDIR default to the bin subdirectory.           #
#    2017-10-30 JFL Corrected a typo in the help message.                     #
#    2017-11-13 JFL Added inference rules to build a DLL.		      #
#    2018-12-28 JFL Added macros defining standard extensions for Windows.    #
#		    (Useful for Files.mak that work for Unix too.)	      #
#		    Exclude *.bak, *~, *# from the source file distribution.  #
#    2019-01-18 JFL The .exe extension is now optional for PROGRAMS list items.
#		    Added the BUILDING_$(PROGRAM) mechanism for conditionally #
#		    specifying SOURCES in the NMakefile calling this All.mak. #
#    2019-02-09 JFL Added support for ARM64 target OS.			      #
#    2020-12-16 JFL Added a dependency on NUL for all pseudo-targets. This    #
#		    makes sure that they run, even if a file with that name   #
#                   exists. We had the case with a new `clean` Shell script.  #
#    2022-10-20 JFL Allow cleaning just one OS. Ex: `make "OS=DOS" clean`     #
#		    Also `make clean` does not delete Unix builds anymore.    #
#    2022-11-25 JFL Added support for the LODOS build type.                   #
#    2022-12-14 JFL Bug fix: `make "OS=WIN32" clean` deleted $(OUTDIR) even   #
#		    if it was not empty.				      #
#    2022-12-22 JFL `make clean` now deletes the $(OUTDIR)\SRC directory.     #
#    2023-11-28 JFL Added rules for building DLLs from C or C++ files.        #
#    2023-12-05 JFL Added rules for building a .com from a .asm source.       #
#    2023-12-09 JFL Added support for the WIN16 target OS.		      #
#    2023-12-30 JFL Added the ability to loop on multiple debug versions.     #
#    2024-01-02 JFL Renamed target veryclean as allclean or cleanall.	      #
#    2024-01-03 JFL Changed the default build OS to $(THIS_OS) only.	      #
#    		    Added variable ONLY_OS to restrict the buildable set.     #
#    		    Added variable TEST_OS to define the OS list for testing. #
#    2024-10-11 JFL Bug fixes & performance improvements.                     #
#    2025-09-24 JFL The batch config file name is config.$(CONFNAME).bat.     #
#    		    							      #
#       © Copyright 2016-2017 Hewlett Packard Enterprise Development LP       #
# Licensed under the Apache 2.0 license - www.apache.org/licenses/LICENSE-2.0 #
###############################################################################

.SUFFIXES: # Clear the predefined suffixes list.
.SUFFIXES: .com .exe .sys .obj .asm .c .r .cpp .cc .cxx .res .rc .def .manifest .mak

!IFNDEF TMP
!IFDEF TEMP
TMP=$(TEMP)
!ELSE
TMP=.
!ENDIF
!ENDIF

!IF !DEFINED(OUTDIR)
OUTDIR=bin
OD=bin\			# Output directory - In the default bin subdirectory
!ELSEIF "$(OUTDIR)"=="."
OD=			# Output directory - In the current directory
!ELSE # It's defined and not empty
OD=$(OUTDIR)\		# Output directory - In the specified directory
!ENDIF

###############################################################################
#									      #
#			        Definitions				      #
#									      #
###############################################################################

# Command-line definitions that need carrying through to sub-make instances
# Note: Cannot redefine MAKEFLAGS, so defining an alternate variable instead.
MAKEDEFS=
!IF DEFINED(WINVER)	# Windows target version. 4.0=Win95/NT4 5.1=XP 6.0=Vista ...
MAKEDEFS=$(MAKEDEFS) "WINVER=$(WINVER)"
!ENDIF
!IF DEFINED(MEM)	# Memory model for DOS compilation. T|S|C|D|L|H. Default=S.
MAKEDEFS=$(MAKEDEFS) "MEM=$(MEM)"
!ENDIF
!IF DEFINED(PROGRAM)	# Specify a program name
MAKEDEFS=$(MAKEDEFS) "PROGRAM=$(PROGRAM)"
!ENDIF
!IF DEFINED(SOURCES)	# Specify a list of sources
MAKEDEFS=$(MAKEDEFS) "SOURCES=$(SOURCES)"
!ENDIF

MAKEPATH=.
!IF (!EXIST("$(All.mak)")) && EXIST("$(NMINCLUDE)\$(All.mak)")
MAKEPATH=$(NMINCLUDE)
!ENDIF

!IF !DEFINED(MAKEDEPTH)
MAKEDEPTH=0
!ELSEIF "$(MAKEDEPTH)"=="10"
!ERROR Too many All.mak nesting levels. Infinite loop?
!ENDIF

!IF DEFINED(MESSAGES)
!MESSAGE All.mak : Started in $(MAKEDIR) "DEBUG=$(DEBUG)" "TEST_OS=$(TEST_OS)" "ONLY_OS=$(ONLY_OS)" "OS=$(OS)"
!IF [echo %TIME%]
!ENDIF
!ENDIF

!IF !DEFINED(DEBUG) && ("$(OS)"!="test" && "$(OS)"!="tests")
DEBUG=0
!ELSEIF "$(DEBUG)"=="all" || (!DEFINED(DEBUG) && ("$(OS)"=="test" || "$(OS)"=="tests"))
!UNDEF DEBUG # Necessary to override DEBUG values set on the command line
DEBUG=0 1
!ENDIF

# Build the OS list
ALL_OS=BIOS LODOS DOS WIN16 WIN95 WIN32 IA64 WIN64 ARM ARM64 # All managed types
!IF !DEFINED(TEST_OS)
TEST_OS=$(THIS_OS) # By default, build for the current OS only
!ENDIF
# $(OS) = List of target operating systems to build for, separated by spaces
# Note: The OS variable here conflicts with Windows' %OS%, defaulting to Windows_NT
!IF !DEFINED(OS) || "$(OS)"=="Windows_NT" # If OS is not specified on the command line
OS=$(THIS_OS)
!ELSEIF "$(OS)"=="all"
!UNDEF OS # Necessary to override OS values set on the command line
OS=$(ALL_OS)
!ELSEIF "$(OS)"=="test" || "$(OS)"=="tests"
!UNDEF OS # Necessary to override OS values set on the command line
OS=$(TEST_OS)
!ELSE
# Use whatever was specified
!ENDIF
# Replace the dummy target OS "THIS" by $(THIS_OS)
_OS_=_ $(OS) _
!IF "$(_OS_: THIS =)"!="$(_OS_)"
_OS_=$(_OS_: THIS = ) $(THIS_OS) _
_OS_=$(_OS_: _ = )
_OS2_=$(_OS_:_ =)
VALUEIZE=OS=$(_OS2_: _=)
!INCLUDE valueize.mak
!UNDEF _OS2_
!ENDIF

# !MESSAGE All.mak : step 1 "TEST_OS=$(TEST_OS)" "OS=$(OS)" "_OS_=$(_OS_)"

# Limit the OS list to the OSs that we can build for
OS2=/		# Initialize with a recognizable string that we'll remove later
!IF DEFINED(DOS_CC) && EXIST("$(MAKEPATH)\BIOS.mak") && "$(_OS_: BIOS =)"!="$(_OS_)"
OS2=$(OS2) BIOS
!ENDIF
!IF DEFINED(DOS_CC) && EXIST("$(MAKEPATH)\LODOS.mak") && "$(_OS_: LODOS =)"!="$(_OS_)"
OS2=$(OS2) LODOS
!ENDIF
!IF DEFINED(DOS_CC) && EXIST("$(MAKEPATH)\DOS.mak") && "$(_OS_: DOS =)"!="$(_OS_)"
OS2=$(OS2) DOS
!ENDIF
!IF DEFINED(DOS_CC) && EXIST("$(MAKEPATH)\WIN16.mak") && "$(_OS_: WIN16 =)"!="$(_OS_)"
OS2=$(OS2) WIN16
!ENDIF
!IF DEFINED(WIN95_CC) && DEFINED(WIN32_CC) && EXIST("$(MAKEPATH)\WIN95.mak") && "$(_OS_: WIN95 =)"!="$(_OS_)"
# Do not combine with next line, else there's a syntax error if WIN95_CC is not defined.
!IF ($(WIN95_CC) != $(WIN32_CC)) # CC paths have "quotes" already
OS2=$(OS2) WIN95
!ENDIF
!ENDIF
!IF DEFINED(WIN32_CC) && EXIST("$(MAKEPATH)\WIN32.mak") && "$(_OS_: WIN32 =)"!="$(_OS_)"
OS2=$(OS2) WIN32
!ENDIF
!IF DEFINED(IA64_CC) && EXIST("$(MAKEPATH)\IA64.mak") && "$(_OS_: IA64 =)"!="$(_OS_)"
OS2=$(OS2) IA64
!ENDIF
!IF DEFINED(WIN64_CC) && EXIST("$(MAKEPATH)\WIN64.mak") && "$(_OS_: WIN64 =)"!="$(_OS_)"
OS2=$(OS2) WIN64
!ENDIF
!IF DEFINED(ARM_CC) && EXIST("$(MAKEPATH)\ARM.mak") && "$(_OS_: ARM =)"!="$(_OS_)"
OS2=$(OS2) ARM
!ENDIF
!IF DEFINED(ARM64_CC) && EXIST("$(MAKEPATH)\ARM64.mak") && "$(_OS_: ARM64 =)"!="$(_OS_)"
OS2=$(OS2) ARM64
!ENDIF
OS2=$(OS2:/ =)	# Remove the initial / and the first following space
!IF "$(OS2)"=="/"	# None of the default OSs matched
!ERROR Cannot build any $(OS) program. Required compilers not installed.
!ENDIF
VALUEIZE=OS=$(OS2)
!INCLUDE valueize.mak
!UNDEF OS2

# !MESSAGE All.mak : step 2 "OS=$(OS)"

# Limit the OS list to those that match OSs in $(ONLY_OS)
!IF "$(ONLY_OS)"=="NT"
!UNDEF ONLY_OS
ONLY_OS=WIN32 IA64 WIN64 ARM ARM64
!ENDIF

!IF DEFINED(MESSAGES)
!MESSAGE All.mak : OS="$(OS)" ONLY_OS="$(ONLY_OS)"
!ENDIF

!IF DEFINED(ONLY_OS)
INTERSECT_ARGS="$(OS)" "$(ONLY_OS)" OS2
!  INCLUDE "intersect.mak" # OS2=intersection of $(OS) and $(ONLY_OS)
!  IF "$(OS2)"==""	   # None of the $(ONLY_OS) OSs matched
!    IF DEFINED(MAKEDEPTH) && "$(MAKEDEPTH)"!="0" # If invoked recursively from the project root directory
!      IF DEFINED(MESSAGES) # => Nothing buildable here, but there might be buildable things in other sibling directories
!        MESSAGE All.mak : Nothing to do, as there are no sources for $(OS) here
!      ENDIF
DO_NOTHING_MSG=Nothing to do # Don't put $(OS) in the message, as it'll be redefined below. (Or valueize it, but this wastes 5ms)
!    ELSE # Invoked locally in the subdirectory => The user asked for something impossible
!      ERROR All.mak : There are no sources for $(OS) here
!    ENDIF # DEFINED(MAKEDEPTH) && "$(MAKEDEPTH)"!="0" # If invoked recursively from the project root directory
!  ENDIF # "$(OS2)"==""
OS=$(OS2) # No need to valueize this one, as OS2 itself is valueized by intersect.mak
# Don't !UNDEF OS2 here again, else OS won't be defined anymore either (unless OS revaluized!)
!ENDIF # DEFINED(ONLY_OS)

# Report start options
MAKEDEFS=$(MAKEDEFS) "DEBUG=$(DEBUG)" "OS=$(OS)"
!IF DEFINED(MESSAGES)
!MESSAGE All.mak : Running with "DEBUG=$(DEBUG)" "OS=$(OS)"
!IF [echo %TIME%]
!ENDIF
!ENDIF

_OS_=_ $(OS) _

# Convert that text list to boolean variables, one for each OS.
DOBIOS=0
DOLODOS=0
DODOS=0
DOWIN16=0
DOWIN95=0
DOWIN32=0
DOIA64=0
DOWIN64=0
DOARM=0
DOARM64=0

# Generate guard macros for each OS
IFBIOS=rem
IFLODOS=rem
IFDOS=rem
IFWIN16=rem
IFWIN95=rem
IFWIN32=rem
IFIA64=rem
IFWIN64=rem
IFARM=rem
IFARM64=rem

!IF "$(_OS_: BIOS =)"!="$(_OS_)"
DOBIOS=1
IFBIOS=
!ENDIF
!IF "$(_OS_: LODOS =)"!="$(_OS_)"
DOLODOS=1
IFLODOS=
!ENDIF
!IF "$(_OS_: DOS =)"!="$(_OS_)"
DODOS=1
IFDOS=
!ENDIF
!IF "$(_OS_: WIN16 =)"!="$(_OS_)"
DOWIN16=1
IFWIN16=
!ENDIF
!IF "$(_OS_: WIN95 =)"!="$(_OS_)"
DOWIN95=1
IFWIN95=
!ENDIF
!IF "$(_OS_: WIN32 =)"!="$(_OS_)"
DOWIN32=1
IFWIN32=
!ENDIF
!IF "$(_OS_: IA64 =)"!="$(_OS_)"
DOIA64=1
IFIA64=
!ENDIF
!IF "$(_OS_: WIN64 =)"!="$(_OS_)"
DOWIN64=1
IFWIN64=
!ENDIF
!IF "$(_OS_: ARM =)"!="$(_OS_)"
DOARM=1
IFARM=
!ENDIF
!IF "$(_OS_: ARM64 =)"!="$(_OS_)"
DOARM64=1
IFARM64=
!ENDIF

# !MESSAGE All.mak : DOBIOS=$(DOBIOS) DOLODOS=$(DOLODOS) DODOS=$(DODOS) DOWIN16=$(DOWIN16) DOWIN95=$(DOWIN95) DOWIN32=$(DOWIN32) DOWIN64=$(DOWIN64)
# !MESSAGE All.mak : IFBIOS=$(IFBIOS) IFLODOS=$(IFLODOS) IFDOS=$(IFDOS) IFWIN16=$(IFWIN16) IFWIN95=$(IFWIN95) IFWIN32=$(IFWIN32) IFIA64=$(IFIA64) IFWIN64=$(IFWIN64) IFARM=$(IFARM) IFARM64=$(IFARM64)

MSG=>con echo		# Command for writing a progress message on the console
HEADLINE=$(MSG).&$(MSG)	# Output a blank line, then a message
REPORT_FAILURE=$(MSG) ... FAILED. & exit /b # Report that a build failed, and forward the error code.

# Add the /NOLOGO flags to MAKEFLAGS. But problem: MAKEFLAGS cannot be updated
MAKEFLAGS_=/$(MAKEFLAGS)# Also MAKEFLAGS does not contain the initial /
!IF "$(MAKEFLAGS_: =)"=="/" # And if no flag is provided, it still contains a dozen spaces
MAKEFLAGS_=		# In that case, clear the useless / and spaces
!ENDIF
MAKEFLAGS__=/_ /$(MAKEFLAGS) /_	# Temp variable to check if /NOLOGO is already there
!IF "$(MAKEFLAGS__: /NOLOGO =)"=="$(MAKEFLAGS__)"
MAKEFLAGS_=/NOLOGO $(MAKEFLAGS_)
!ENDIF
!UNDEF MAKEFLAGS__

!IF "$(MAKEDEPTH)"=="0"		# Fast result in the most common case
MAKEDEPTH1=1
!ELSEIF "$(MAKEDEPTH)"=="1"	# Fast result in the 2nd most common case
MAKEDEPTH1=2
!ELSEIF "$(MAKEDEPTH)"=="2"	# Fast result in the 3rd most common case
MAKEDEPTH1=3
!ELSE				# Slow result in all other cases
EVAL=MAKEDEPTH1=`set /a $(MAKEDEPTH)+1`
!INCLUDE eval.mak
!ENDIF

# Recursive call to this make file
# Do not include $(MAKEDEFS) in SUBMAKE definition, as macros can only be
# overriden by inserting a new value _ahead_ of the previous definitions.
SUBMAKE=$(MAKE) $(MAKEFLAGS_) /F "$(MAKEFILE)" MAKEDEPTH=$(MAKEDEPTH1)

# Standard file extensions for Windows. Useful for Files.mak that work for Unix too
_EXE = .exe
_OBJ = .obj

###############################################################################
#									      #
#			       Inference rules				      #
#									      #
###############################################################################

# Inference rule to build a simple program. Build BIOS, DOS, Win32, and Win64 versions.
.asm.com:
    @echo Applying inference rule .asm.com:
    $(IFBIOS)  for %%d in ($(DEBUG)) do $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\BIOS.mak"  "DEBUG=%%d" $(MAKEDEFS) $@
    $(IFLODOS) for %%d in ($(DEBUG)) do $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\LODOS.mak" "DEBUG=%%d" $(MAKEDEFS) $@
    $(IFDOS)   for %%d in ($(DEBUG)) do $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\DOS.mak"   "DEBUG=%%d" $(MAKEDEFS) $@

.c.com:
    @echo Applying inference rule .c.com:
    $(IFBIOS)  for %%d in ($(DEBUG)) do $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\BIOS.mak"  "DEBUG=%%d" $(MAKEDEFS) $@
    $(IFLODOS) for %%d in ($(DEBUG)) do $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\LODOS.mak" "DEBUG=%%d" $(MAKEDEFS) $@
    $(IFDOS)   for %%d in ($(DEBUG)) do $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\DOS.mak"   "DEBUG=%%d" $(MAKEDEFS) $@

.c.exe:
    @echo Applying inference rule .c.exe:
    $(IFBIOS)  for %%d in ($(DEBUG)) do $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\BIOS.mak"  "DEBUG=%%d" $(MAKEDEFS) $@
    $(IFLODOS) for %%d in ($(DEBUG)) do $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\LODOS.mak" "DEBUG=%%d" $(MAKEDEFS) $@
    $(IFDOS)   for %%d in ($(DEBUG)) do $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\DOS.mak"   "DEBUG=%%d" $(MAKEDEFS) $@
    $(IFWIN16) for %%d in ($(DEBUG)) do $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\WIN16.mak" "DEBUG=%%d" $(MAKEDEFS) $@
    $(IFWIN95) for %%d in ($(DEBUG)) do $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\WIN95.mak" "DEBUG=%%d" $(MAKEDEFS) $@
    $(IFWIN32) for %%d in ($(DEBUG)) do $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\WIN32.mak" "DEBUG=%%d" $(MAKEDEFS) $@
    $(IFIA64)  for %%d in ($(DEBUG)) do $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\IA64.mak"  "DEBUG=%%d" $(MAKEDEFS) $@
    $(IFWIN64) for %%d in ($(DEBUG)) do $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\WIN64.mak" "DEBUG=%%d" $(MAKEDEFS) $@
    $(IFARM)   for %%d in ($(DEBUG)) do $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\ARM.mak"   "DEBUG=%%d" $(MAKEDEFS) $@
    $(IFARM64) for %%d in ($(DEBUG)) do $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\ARM64.mak" "DEBUG=%%d" $(MAKEDEFS) $@

.c.dll:
    @echo Applying inference rule .c.dll:
    $(IFWIN95) for %%d in ($(DEBUG)) do $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\WIN95.mak" "DEBUG=%%d" $(MAKEDEFS) $@
    $(IFWIN32) for %%d in ($(DEBUG)) do $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\WIN32.mak" "DEBUG=%%d" $(MAKEDEFS) $@
    $(IFIA64)  for %%d in ($(DEBUG)) do $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\IA64.mak"  "DEBUG=%%d" $(MAKEDEFS) $@
    $(IFWIN64) for %%d in ($(DEBUG)) do $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\WIN64.mak" "DEBUG=%%d" $(MAKEDEFS) $@
    $(IFARM)   for %%d in ($(DEBUG)) do $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\ARM.mak"   "DEBUG=%%d" $(MAKEDEFS) $@
    $(IFARM64) for %%d in ($(DEBUG)) do $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\ARM64.mak" "DEBUG=%%d" $(MAKEDEFS) $@

.cpp.com:
    @echo Applying inference rule .cpp.com:
    $(IFBIOS)  for %%d in ($(DEBUG)) do $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\BIOS.mak"  "DEBUG=%%d" $(MAKEDEFS) $@
    $(IFLODOS) for %%d in ($(DEBUG)) do $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\LODOS.mak" "DEBUG=%%d" $(MAKEDEFS) $@
    $(IFDOS)   for %%d in ($(DEBUG)) do $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\DOS.mak"   "DEBUG=%%d" $(MAKEDEFS) $@

.cpp.exe:
    @echo Applying inference rule .cpp.exe:
    $(IFBIOS)  for %%d in ($(DEBUG)) do $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\BIOS.mak"  "DEBUG=%%d" $(MAKEDEFS) $@
    $(IFLODOS) for %%d in ($(DEBUG)) do $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\LODOS.mak" "DEBUG=%%d" $(MAKEDEFS) $@
    $(IFDOS)   for %%d in ($(DEBUG)) do $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\DOS.mak"   "DEBUG=%%d" $(MAKEDEFS) $@
    $(IFWIN16) for %%d in ($(DEBUG)) do $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\WIN16.mak" "DEBUG=%%d" $(MAKEDEFS) $@
    $(IFWIN95) for %%d in ($(DEBUG)) do $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\WIN95.mak" "DEBUG=%%d" $(MAKEDEFS) $@
    $(IFWIN32) for %%d in ($(DEBUG)) do $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\WIN32.mak" "DEBUG=%%d" $(MAKEDEFS) $@
    $(IFIA64)  for %%d in ($(DEBUG)) do $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\IA64.mak"  "DEBUG=%%d" $(MAKEDEFS) $@
    $(IFWIN64) for %%d in ($(DEBUG)) do $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\WIN64.mak" "DEBUG=%%d" $(MAKEDEFS) $@
    $(IFARM)   for %%d in ($(DEBUG)) do $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\ARM.mak"   "DEBUG=%%d" $(MAKEDEFS) $@
    $(IFARM64) for %%d in ($(DEBUG)) do $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\ARM64.mak" "DEBUG=%%d" $(MAKEDEFS) $@

.cpp.dll:
    @echo Applying inference rule .cpp.dll:
    $(IFWIN95) for %%d in ($(DEBUG)) do $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\WIN95.mak" "DEBUG=%%d" $(MAKEDEFS) $@
    $(IFWIN32) for %%d in ($(DEBUG)) do $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\WIN32.mak" "DEBUG=%%d" $(MAKEDEFS) $@
    $(IFIA64)  for %%d in ($(DEBUG)) do $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\IA64.mak"  "DEBUG=%%d" $(MAKEDEFS) $@
    $(IFWIN64) for %%d in ($(DEBUG)) do $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\WIN64.mak" "DEBUG=%%d" $(MAKEDEFS) $@
    $(IFARM)   for %%d in ($(DEBUG)) do $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\ARM.mak"   "DEBUG=%%d" $(MAKEDEFS) $@
    $(IFARM64) for %%d in ($(DEBUG)) do $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\ARM64.mak" "DEBUG=%%d" $(MAKEDEFS) $@

.asm.exe:
    @echo Applying inference rule .asm.exe:
    $(IFBIOS)  for %%d in ($(DEBUG)) do $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\BIOS.mak"  "DEBUG=%%d" $(MAKEDEFS) $@
    $(IFLODOS) for %%d in ($(DEBUG)) do $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\LODOS.mak" "DEBUG=%%d" $(MAKEDEFS) $@
    $(IFDOS)   for %%d in ($(DEBUG)) do $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\DOS.mak"   "DEBUG=%%d" $(MAKEDEFS) $@
    $(IFWIN95) for %%d in ($(DEBUG)) do $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\WIN95.mak" "DEBUG=%%d" $(MAKEDEFS) $@
    $(IFWIN32) for %%d in ($(DEBUG)) do $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\WIN32.mak" "DEBUG=%%d" $(MAKEDEFS) $@
    $(IFIA64)  for %%d in ($(DEBUG)) do $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\IA64.mak"  "DEBUG=%%d" $(MAKEDEFS) $@
    $(IFWIN64) for %%d in ($(DEBUG)) do $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\WIN64.mak" "DEBUG=%%d" $(MAKEDEFS) $@
    $(IFARM)   for %%d in ($(DEBUG)) do $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\ARM.mak"   "DEBUG=%%d" $(MAKEDEFS) $@
    $(IFARM64) for %%d in ($(DEBUG)) do $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\ARM64.mak" "DEBUG=%%d" $(MAKEDEFS) $@

# Inference rule to build a makefile-defined executable. Build BIOS, DOS, Win32, and Win64 versions.
.mak.exe:
    @echo Applying inference rule .mak.exe:
    $(IFBIOS)  for %%d in ($(DEBUG)) do $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\BIOS.mak"  "DEBUG=%%d" $(MAKEDEFS) $@
    $(IFLODOS) for %%d in ($(DEBUG)) do $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\LODOS.mak" "DEBUG=%%d" $(MAKEDEFS) $@
    $(IFDOS)   for %%d in ($(DEBUG)) do $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\DOS.mak"   "DEBUG=%%d" $(MAKEDEFS) $@
    $(IFWIN16) for %%d in ($(DEBUG)) do $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\WIN16.mak" "DEBUG=%%d" $(MAKEDEFS) $@
    $(IFWIN95) for %%d in ($(DEBUG)) do $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\WIN95.mak" "DEBUG=%%d" $(MAKEDEFS) $@
    $(IFWIN32) for %%d in ($(DEBUG)) do $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\WIN32.mak" "DEBUG=%%d" $(MAKEDEFS) $@
    $(IFIA64)  for %%d in ($(DEBUG)) do $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\IA64.mak"  "DEBUG=%%d" $(MAKEDEFS) $@
    $(IFWIN64) for %%d in ($(DEBUG)) do $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\WIN64.mak" "DEBUG=%%d" $(MAKEDEFS) $@
    $(IFARM)   for %%d in ($(DEBUG)) do $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\ARM.mak"   "DEBUG=%%d" $(MAKEDEFS) $@
    $(IFARM64) for %%d in ($(DEBUG)) do $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\ARM64.mak" "DEBUG=%%d" $(MAKEDEFS) $@

# Inference rule to build a makefile-defined library. Build BIOS, DOS, Win32, and Win64 versions.
.mak.lib:
    @echo Applying inference rule .mak.lib:
    $(IFBIOS)  for %%d in ($(DEBUG)) do $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\BIOS.mak"  "DEBUG=%%d" $(MAKEDEFS) $@
    $(IFLODOS) for %%d in ($(DEBUG)) do $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\LODOS.mak" "DEBUG=%%d" $(MAKEDEFS) $@
    $(IFDOS)   for %%d in ($(DEBUG)) do $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\DOS.mak"   "DEBUG=%%d" $(MAKEDEFS) $@
    $(IFWIN95) for %%d in ($(DEBUG)) do $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\WIN95.mak" "DEBUG=%%d" $(MAKEDEFS) $@
    $(IFWIN32) for %%d in ($(DEBUG)) do $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\WIN32.mak" "DEBUG=%%d" $(MAKEDEFS) $@
    $(IFIA64)  for %%d in ($(DEBUG)) do $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\IA64.mak"  "DEBUG=%%d" $(MAKEDEFS) $@
    $(IFWIN64) for %%d in ($(DEBUG)) do $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\WIN64.mak" "DEBUG=%%d" $(MAKEDEFS) $@
    $(IFARM)   for %%d in ($(DEBUG)) do $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\ARM.mak"   "DEBUG=%%d" $(MAKEDEFS) $@
    $(IFARM64) for %%d in ($(DEBUG)) do $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\ARM64.mak" "DEBUG=%%d" $(MAKEDEFS) $@

# Inference rule to build a makefile-defined DLL. Build BIOS, DOS, Win32, and Win64 versions.
.mak.dll:
    @echo Applying inference rule .mak.dll:
    $(IFDOS)   for %%d in ($(DEBUG)) do $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\DOS.mak"   "DEBUG=%%d" $(MAKEDEFS) $@
    $(IFWIN95) for %%d in ($(DEBUG)) do $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\WIN95.mak" "DEBUG=%%d" $(MAKEDEFS) $@
    $(IFWIN32) for %%d in ($(DEBUG)) do $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\WIN32.mak" "DEBUG=%%d" $(MAKEDEFS) $@
    $(IFIA64)  for %%d in ($(DEBUG)) do $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\IA64.mak"  "DEBUG=%%d" $(MAKEDEFS) $@
    $(IFWIN64) for %%d in ($(DEBUG)) do $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\WIN64.mak" "DEBUG=%%d" $(MAKEDEFS) $@
    $(IFARM)   for %%d in ($(DEBUG)) do $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\ARM.mak"   "DEBUG=%%d" $(MAKEDEFS) $@
    $(IFARM64) for %%d in ($(DEBUG)) do $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\ARM64.mak" "DEBUG=%%d" $(MAKEDEFS) $@

# Inference rule to build a simple program. Build BIOS, DOS, Win32, and Win64 debug versions.
{.\}.asm{Debug\}.com:
    @echo Applying inference rule {.\}.asm{Debug\}.com:
    $(IFBIOS)  $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\BIOS.mak"  "DEBUG=1" $(MAKEDEFS) $(@F)
    $(IFLODOS) $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\LODOS.mak" "DEBUG=1" $(MAKEDEFS) $(@F)
    $(IFDOS)   $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\DOS.mak"   "DEBUG=1" $(MAKEDEFS) $(@F)

{.\}.c{Debug\}.com:
    @echo Applying inference rule {.\}.c{Debug\}.com:
    $(IFBIOS)  $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\BIOS.mak"  "DEBUG=1" $(MAKEDEFS) $(@F)
    $(IFLODOS) $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\LODOS.mak" "DEBUG=1" $(MAKEDEFS) $(@F)
    $(IFDOS)   $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\DOS.mak"   "DEBUG=1" $(MAKEDEFS) $(@F)

{.\}.c{Debug\}.exe:
    @echo Applying inference rule {.\}.c{Debug\}.exe:
    $(IFBIOS)  $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\BIOS.mak"  "DEBUG=1" $(MAKEDEFS) $(@F)
    $(IFLODOS) $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\LODOS.mak" "DEBUG=1" $(MAKEDEFS) $(@F)
    $(IFDOS)   $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\DOS.mak"   "DEBUG=1" $(MAKEDEFS) $(@F)
    $(IFWIN16) $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\WIN16.mak" "DEBUG=1" $(MAKEDEFS) $(@F)
    $(IFWIN95) $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\WIN95.mak" "DEBUG=1" $(MAKEDEFS) $(@F)
    $(IFWIN32) $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\WIN32.mak" "DEBUG=1" $(MAKEDEFS) $(@F)
    $(IFIA64)  $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\IA64.mak"  "DEBUG=1" $(MAKEDEFS) $(@F)
    $(IFWIN64) $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\WIN64.mak" "DEBUG=1" $(MAKEDEFS) $(@F)
    $(IFARM)   $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\ARM.mak"   "DEBUG=1" $(MAKEDEFS) $(@F)
    $(IFARM64) $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\ARM64.mak" "DEBUG=1" $(MAKEDEFS) $(@F)

{.\}.cpp{Debug\}.com:
    @echo Applying inference rule {.\}.cpp{Debug\}.com:
    $(IFBIOS)  $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\BIOS.mak"  "DEBUG=1" $(MAKEDEFS) $(@F)
    $(IFLODOS) $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\LODOS.mak" "DEBUG=1" $(MAKEDEFS) $(@F)
    $(IFDOS)   $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\DOS.mak"   "DEBUG=1" $(MAKEDEFS) $(@F)

{.\}.cpp{Debug\}.exe:
    @echo Applying inference rule {.\}.cpp{Debug\}.exe:
    $(IFBIOS)  $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\BIOS.mak"  "DEBUG=1" $(MAKEDEFS) $(@F)
    $(IFLODOS) $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\LODOS.mak" "DEBUG=1" $(MAKEDEFS) $(@F)
    $(IFDOS)   $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\DOS.mak"   "DEBUG=1" $(MAKEDEFS) $(@F)
    $(IFWIN16) $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\WIN16.mak" "DEBUG=1" $(MAKEDEFS) $(@F)
    $(IFWIN95) $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\WIN95.mak" "DEBUG=1" $(MAKEDEFS) $(@F)
    $(IFWIN32) $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\WIN32.mak" "DEBUG=1" $(MAKEDEFS) $(@F)
    $(IFIA64)  $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\IA64.mak"  "DEBUG=1" $(MAKEDEFS) $(@F)
    $(IFWIN64) $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\WIN64.mak" "DEBUG=1" $(MAKEDEFS) $(@F)
    $(IFARM)   $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\ARM.mak"   "DEBUG=1" $(MAKEDEFS) $(@F)
    $(IFARM64) $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\ARM64.mak" "DEBUG=1" $(MAKEDEFS) $(@F)

{.\}.asm{Debug\}.exe:
    @echo Applying inference rule {.\}.asm{Debug\}.exe:
    $(IFBIOS)  $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\BIOS.mak"  "DEBUG=1" $(MAKEDEFS) $(@F)
    $(IFLODOS) $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\LODOS.mak" "DEBUG=1" $(MAKEDEFS) $(@F)
    $(IFDOS)   $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\DOS.mak"   "DEBUG=1" $(MAKEDEFS) $(@F)
    $(IFWIN95) $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\WIN95.mak" "DEBUG=1" $(MAKEDEFS) $(@F)
    $(IFWIN32) $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\WIN32.mak" "DEBUG=1" $(MAKEDEFS) $(@F)
    $(IFIA64)  $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\IA64.mak"  "DEBUG=1" $(MAKEDEFS) $(@F)
    $(IFWIN64) $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\WIN64.mak" "DEBUG=1" $(MAKEDEFS) $(@F)
    $(IFARM)   $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\ARM.mak"   "DEBUG=1" $(MAKEDEFS) $(@F)
    $(IFARM64) $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\ARM64.mak" "DEBUG=1" $(MAKEDEFS) $(@F)

# Inference rule to build a makefile-defined executable. Build BIOS, DOS, Win32, and Win64 versions.
{.\}.mak{Debug\}.exe:
    @echo Applying inference rule {.\}.mak{Debug\}.exe:
    $(IFBIOS)  $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\BIOS.mak"  "DEBUG=1" $(MAKEDEFS) $(@F)
    $(IFLODOS) $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\LODOS.mak" "DEBUG=1" $(MAKEDEFS) $(@F)
    $(IFDOS)   $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\DOS.mak"   "DEBUG=1" $(MAKEDEFS) $(@F)
    $(IFWIN16) $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\WIN16.mak" "DEBUG=1" $(MAKEDEFS) $(@F)
    $(IFWIN95) $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\WIN95.mak" "DEBUG=1" $(MAKEDEFS) $(@F)
    $(IFWIN32) $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\WIN32.mak" "DEBUG=1" $(MAKEDEFS) $(@F)
    $(IFIA64)  $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\IA64.mak"  "DEBUG=1" $(MAKEDEFS) $(@F)
    $(IFWIN64) $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\WIN64.mak" "DEBUG=1" $(MAKEDEFS) $(@F)
    $(IFARM)   $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\ARM.mak"   "DEBUG=1" $(MAKEDEFS) $(@F)
    $(IFARM64) $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\ARM64.mak" "DEBUG=1" $(MAKEDEFS) $(@F)

# Inference rule to build a makefile-defined library. Build BIOS, DOS, Win32, and Win64 versions.
{.\}.mak{Debug\}.lib:
    @echo Applying inference rule {.\}.mak{Debug\}.lib:
    $(IFBIOS)  $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\BIOS.mak"  "DEBUG=1" $(MAKEDEFS) $(@F)
    $(IFLODOS) $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\LODOS.mak" "DEBUG=1" $(MAKEDEFS) $(@F)
    $(IFDOS)   $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\DOS.mak"   "DEBUG=1" $(MAKEDEFS) $(@F)
    $(IFWIN95) $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\WIN95.mak" "DEBUG=1" $(MAKEDEFS) $(@F)
    $(IFWIN32) $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\WIN32.mak" "DEBUG=1" $(MAKEDEFS) $(@F)
    $(IFIA64)  $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\IA64.mak"  "DEBUG=1" $(MAKEDEFS) $(@F)
    $(IFWIN64) $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\WIN64.mak" "DEBUG=1" $(MAKEDEFS) $(@F)
    $(IFARM)   $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\ARM.mak"   "DEBUG=1" $(MAKEDEFS) $(@F)
    $(IFARM64) $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\ARM64.mak" "DEBUG=1" $(MAKEDEFS) $(@F)

# Inference rule to build a makefile-defined DLL. Build BIOS, DOS, Win32, and Win64 versions.
{.\}.mak{Debug\}.dll:
    @echo Applying inference rule {.\}.mak{Debug\}.dll:
    $(IFDOS)   $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\DOS.mak"   "DEBUG=1" $(MAKEDEFS) $(@F)
    $(IFWIN95) $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\WIN95.mak" "DEBUG=1" $(MAKEDEFS) $(@F)
    $(IFWIN32) $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\WIN32.mak" "DEBUG=1" $(MAKEDEFS) $(@F)
    $(IFIA64)  $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\IA64.mak"  "DEBUG=1" $(MAKEDEFS) $(@F)
    $(IFWIN64) $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\WIN64.mak" "DEBUG=1" $(MAKEDEFS) $(@F)
    $(IFARM)   $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\ARM.mak"   "DEBUG=1" $(MAKEDEFS) $(@F)
    $(IFARM64) $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\ARM64.mak" "DEBUG=1" $(MAKEDEFS) $(@F)

# Inference rules to build something for DOS, WIN32 and WIN64 respectively
# Get them from their respective DOS.mak, WIN32.mak, WIN64.mak make files, etc.

# Does not work, due to late evaluation of nmake macros.
# So using make.bat instead to generate the correct make file.
# DISPATCH_OS=BIOS
# !INCLUDE "Dispatch.mak"
# 
# DISPATCH_OS=LODOS
# !INCLUDE "Dispatch.mak"
# 
# DISPATCH_OS=DOS
# !INCLUDE "Dispatch.mak"
# 
# DISPATCH_OS=WIN95
# !INCLUDE "Dispatch.mak"
# 
# DISPATCH_OS=WIN32
# !INCLUDE "Dispatch.mak"
# 
# DISPATCH_OS=IA64
# !INCLUDE "Dispatch.mak"
# 
# DISPATCH_OS=WIN64
# !INCLUDE "Dispatch.mak"
# 
# DISPATCH_OS=ARM
# !INCLUDE "Dispatch.mak"

###############################################################################
#									      #
#			        Specific rules				      #
#									      #
###############################################################################

default: all

!IF EXIST("Files.mak")
!  INCLUDE Files.mak	# Set variable DIRS, SOURCES, ALL, MODULE, CLEAN_DIRS, CLEAN_FILES, etc
!ENDIF

!IF DEFINED(DIRS)
# List sub-directories to build, one per line
list_dirs: NUL
    for %%d in ($(DIRS)) do @echo %%~d

# Build individual modules in the specified subdirectories
$(DIRS): NUL
    rem # Build the module in dir $@, using the current log file
    cd $@ & (if not defined CONFNAME set "CONFNAME=%COMPUTERNAME%") & \
      (for %%f in (config.%CONFNAME%.bat) do if exist %%f call %%f) & \
      $(SUBMAKE) $(MAKEDEFS) || $(MSG) $@ build failed. Error %ERRORLEVEL% & exit /b
!ENDIF

!IF DEFINED(MODULE) # Defined in Files.mak
module_name: NUL
    @echo $(MODULE)
!ENDIF

nothing: # Useful for testing
    $(MSG) Nothing done in $(MAKEDIR) for "OS=$(OS)" "DEBUG=$(DEBUG)"

outdir: # Create OUTDIR if needed
    cmd /c <<"$(TMP)\mk_outdir.$(PID).bat" || exit /b &:# Using the shell PID to generate a unique name, to avoid conflicts in case of // builds.
        @echo off
        setlocal EnableExtensions EnableDelayedExpansion
	echo Applying All.mak outdir rule
        set "OUTDIR=$(OUTDIR)"
        :# set "MD_OUTDIR=$(MD_OUTDIR)"
        :# set "LINK_OUTDIR=$(LINK_OUTDIR)"
        for /f "tokens=* delims=" %%l in ('findstr _OUTDIR config.%COMPUTERNAME%.bat') do %%l
        goto :start
	:is_dir pathname        -- Check if a pathname refers to an existing directory
	for /f "tokens=1,2 delims=d" %%a in ("-%~a1") do if not "%%~b"=="" exit /b 0
	exit /b 1
	:start
        :# Code duplicated from make.bat, necessary now that we don't use $(BMAKE) anymore for recursing
	if defined LINK_OUTDIR ( :# Check if creating junctions works, and if so, prepare to create one
	  :# Check if creating junctions works, and if so, prepare to create one
	  mklink /j TEST_JUNCTION_CREATION "%LINK_OUTDIR%\%OUTDIR%" >NUL 2>NUL
	  if not errorlevel 1 (
	    set "MD_OUTDIR0=!MD_OUTDIR!"
	    set MD_OUTDIR=mklink /j "%OUTDIR%" "%LINK_OUTDIR%\%OUTDIR%"
	    rd TEST_JUNCTION_CREATION
	  )
	)
        if not defined MD_OUTDIR set MD_OUTDIR=md "%OUTDIR%"
	echo CD=%CD% OUTDIR=%OUTDIR% LINK_OUTDIR=%LINK_OUTDIR% MD_OUTDIR=%MD_OUTDIR%
	if not "%OUTDIR%"=="" call :is_dir "%OUTDIR%" || %MD_OUTDIR% || (
	  >&2 echo Error: %MD_OUTDIR%: Cannot create the output directory.
	  exit /b 1
	)
	exit /b 0
<<KEEP

all_case1: NUL
    @echo Applying All.mak all rule first case: DEFINED(ALL) or DEFINED(DIRS)

all_case2: NUL
    @echo Applying All.mak all rule second case: Try using PROGRAMS

!IF DEFINED(DO_NOTHING_MSG)
all: NUL
    echo $(DO_NOTHING_MSG)
!ELSEIF DEFINED(ALL) || DEFINED(DIRS)
all: all_case1 $(REQS) outdir $(DIRS) $(ALL)
!ELSE # Another scheme for defining all goals, using $(PROGRAMS)
all: all_case2 $(REQS) outdir # Having a batch file is necessary for dynamically updating the *FAILED variables.
    cmd /c <<"$(TMP)\build_all.$(PID).bat" || exit /b &:# Using the shell PID to generate a unique name, to avoid conflicts in case of // builds.
        @echo off
        setlocal EnableExtensions EnableDelayedExpansion
        set "PROGRAMS=$(PROGRAMS)"
        set "DEBUG=$(DEBUG)"
        if defined PROGRAMS ( :# Build the list of programs defined in Files.mak 
	    echo Applying All.mak all rule with "DEBUG=!DEBUG!" "PROGRAMS=!PROGRAMS!"
	) else ( :# As a last resort, try compiling all C and C++ files in the current directory
	    echo Applying All.mak all rule with "DEBUG=!DEBUG!" PROGRAMS undefined
	    for %%f in (*.c *.cpp) do set "PROGRAMS=!PROGRAMS! %%~nf.exe"
	    set PROGRAMS=!PROGRAMS:~1!
	    echo Trying to compile all C and C++ files: set PROGRAMS=!PROGRAMS!
	)
        set "NFAILED=0"
        set "WHAT_FAILED="
        for %%p in (!PROGRAMS!) do (
	    $(HEADLINE) Building %%~p
	    :# Make the .exe extension optional in PROGRAMS elements
	    set "P=%%~p"
	    if "%%~p"=="%%~np" set "P=!P!.exe"
	    set CMD=$(SUBMAKE) "BUILDING_%%~np=1" $(MAKEDEFS) "!P!"
	    echo !CMD!
	    !CMD!
	    if errorlevel 1 (
		set /A "NFAILED+=1"
		set "WHAT_FAILED=!WHAT_FAILED! %%~p"
		echo All.mak: %%~p build failed
	    )
        )
        if defined WHAT_FAILED set "WHAT_FAILED=%WHAT_FAILED:~1%"
        echo NFAILED=%NFAILED% WHAT_FAILED=(%WHAT_FAILED%)
        if not %NFAILED%==0 $(HEADLINE) Error: Builds failed: %WHAT_FAILED%
        exit /b %NFAILED%
<<KEEP
!ENDIF

# Dummy targets for dynamically checking common prerequisites
ERRMSG=>&2 echo Error: # Use a variable, to avoid getting the word "Error" in the build log when there's no error
BiosLib_library: NUL
    if not defined BIOSLIB %ERRMSG% The BiosLib library is not configured & exit /b 1
    if not exist %BIOSLIB%\clibdef.h %ERRMSG% The BiosLib library is not configured correctly & exit /b 1
    if not exist %BIOSLIB%\bios.lib %ERRMSG% The BiosLib library must be built first & exit /b 1

LoDosLib_library: NUL
    if not defined LODOSLIB %ERRMSG% The LoDosLib library is not configured & exit /b 1
    if not exist %LODOSLIB%\lodos.h %ERRMSG% The LoDosLib library is not configured correctly & exit /b 1
    if not exist %LODOSLIB%\lodos.lib %ERRMSG% The LoDosLib library must be built first & exit /b 1

SysLib_library: NUL
    if not defined SYSLIB %ERRMSG% The SysLib library is not configured & exit /b 1
    if not exist %SYSLIB%\oprintf.h %ERRMSG% The SysLib library is not configured correctly & exit /b 1
    if not exist %SYSLIB%\$(OD)lib\*.lib %ERRMSG% The SysLib library must be built first & exit /b 1

MsvcLibX_library: NUL
    if not defined MSVCLIBX %ERRMSG% The MsvcLibX library is not configured & exit /b 1
    if not exist %MSVCLIBX%\include\msvclibx.h %ERRMSG% The MsvcLibX library is not configured correctly & exit /b 1
    if not exist %MSVCLIBX%\$(OD)lib\*.lib %ERRMSG% The MsvcLibX library must be built first & exit /b 1

PModeLib_library: NUL
    if not defined PMODELIB %ERRMSG% The PModeLib library is not configured & exit /b 1
    if not exist %PMODELIB%\pmode.h %ERRMSG% The PModeLib library is not configured correctly & exit /b 1
    if not exist %PMODELIB%\pmode.lib %ERRMSG% The PModeLib library must be built first & exit /b 1

!IF !DEFINED(ZIPFILE)
ZIPFILE=sources.zip
ZIPSOURCES=*.c *.cpp *.h *.asm *.inc *Makefile *.mak *.bat *.rc *.def *.manifest
!ENDIF

$(ZIPFILE): $(ZIPSOURCES)
    $(MSG) Building $@ ...
    if exist $@ del $@
    set PATH=$(PATH);C:\Program Files\7-zip
    7z.exe a -xr!*.bak -xr!*~ -xr!*# $@ $**
    $(MSG) ... done

dist zip: $(ZIPFILE)

# The following targets are special-cased in make.bat, and their output in _not_ redirected to a log file.
# => Make sure to redirect to NUL anything you don't want to normally see.

# List PROGRAMS defined in Files.mak
list_programs: NUL
    cmd /c <<"$(TMP)\list_programs.$(PID).bat" || exit /b &:# Using the shell PID to generate a unique name, to avoid conflicts in case of // builds.
        @echo off
        setlocal EnableExtensions EnableDelayedExpansion
	set "PROGRAMS=$(PROGRAMS)"
	if defined PROGRAMS (
	    set "PROGRAMS="
	    for %%p in ($(PROGRAMS)) do (
	        :# Add a .exe extension for those that don't have one.
		set "P=%%~p"
		if "%%~p"=="%%~np" set "P=!P!.exe"
		set "PROGRAMS=!PROGRAMS! !P!"
	    )
	    :# Remove the extra space added in the first loop
	    echo !PROGRAMS:~1!
	)
	exit /b
<<

# Erase all output files
clean mostlyclean distclean: NUL
!IF DEFINED(DIRS)
    rem # Delete files in DIRS=$(DIRS)
    for %d in ($(DIRS)) do @($(MSG) Cleaning %d & cd "$(MAKEDIR)\%d" && $(SUBMAKE) $(MAKEDEFS) $@)
    $(MSG) Cleaning .
!ENDIF
    rem # Delete files built for supported OS types
    $(IFBIOS)  $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\BIOS.mak"  $(MAKEDEFS) clean
    $(IFLODOS) $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\LODOS.mak" $(MAKEDEFS) clean
    $(IFDOS)   $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\DOS.mak"   $(MAKEDEFS) clean
    $(IFWIN16) $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\WIN16.mak" $(MAKEDEFS) clean
    $(IFWIN95) $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\WIN95.mak" $(MAKEDEFS) clean
    $(IFWIN32) $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\WIN32.mak" $(MAKEDEFS) clean
    $(IFIA64)  $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\IA64.mak"  $(MAKEDEFS) clean
    $(IFWIN64) $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\WIN64.mak" $(MAKEDEFS) clean
    $(IFARM)   $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\ARM.mak"   $(MAKEDEFS) clean
    $(IFARM64) $(MAKE) $(MAKEFLAGS_) /f "$(MAKEPATH)\ARM64.mak" $(MAKEDEFS) clean
    rem # Delete the output directories
!IF DEFINED(OUTDIR) && "$(OUTDIR)" != "" && "$(OUTDIR)" != "." && "$(OUTDIR)" != ".."
    -if "$@"=="distclean" rd /S /Q $(OUTDIR) >NUL 2>&1		&:# Delete OUTDIR, including Unix builds there
!ENDIF
!IF DEFINED(OUTDIR) && "$(OUTDIR)" != ""
    -if exist $(OUTDIR)\Lib rd $(OUTDIR)\Lib >NUL 2>&1		&:# Delete OUTDIR\Lib if it's empty
    -if exist $(OUTDIR)\*.log del $(OUTDIR)\*.log >NUL 2>&1	&:# Delete OUTDIR\*.log
    rem # Delete localized sources in the output directory, if they're not in use anymore.
# This must be done after deleting $(OUTDIR) in the distclean case, to avoid getting the warning messages about remaining directories.
    -if exist $(OUTDIR)\SRC set "RD_SRC=1" \
      & (for %t in ($(ALL_OS)) do @if exist $(OUTDIR)\%t (%IF_VERBOSE% echo :# Found $(MAKERELDIR)\$(OUTDIR)\%t) & set "RD_SRC=") \
      & if defined RD_SRC ((%IF_VERBOSE% echo rd /S /Q $(OUTDIR)\SRC) & rd /S /Q $(OUTDIR)\SRC) else (%IF_VERBOSE% echo :# =^> Keep $(MAKERELDIR)\$(OUTDIR)\SRC)
!ENDIF
!IF DEFINED(OUTDIR) && "$(OUTDIR)" != "" && "$(OUTDIR)" != "." && "$(OUTDIR)" != ".."
    rem # Delete OUTDIR if it's empty, be it a directory or a junction
#   -if exist $(OUTDIR) rd $(OUTDIR) >NUL 2>&1		&:# Delete OUTDIR if it's empty
# Known problem: $(OUTDIR) may be a junction, and `rd $(OUTDIR)` deletes it even if the target directory is not empty.
# Workaround: Use a for /d loop to detect subdirectories, and remove the junction only if there are none.
    -if exist $(OUTDIR) ((for /d %d in ($(OUTDIR)\*) do @(call)) && rd $(OUTDIR) >NUL 2>&1) &:# Delete OUTDIR if it's empty
!ENDIF
    -del /Q *.bak	>NUL 2>&1
    -del /Q *~		>NUL 2>&1
    -del /Q *.log	>NUL 2>&1
    -if "$@"=="distclean" del /Q config.*.bat >NUL 2>&1
!IF DEFINED(CLEAN_DIRS) # Then clean each directory, and remove it if empty
    -for %%d in ($(CLEAN_DIRS)) do @pushd %%d & $(SUBMAKE) $(MAKEDEFS) $@ & popd & rd %%d 2>NUL
!ENDIF
!IF DEFINED(CLEAN_FILES) # Then clean each file
    -for %%d in ($(CLEAN_FILES)) do @if exist %%d del %%d >NUL 2>&1
!ENDIF
!IF DEFINED(DISTCLEAN_FILES) # Then clean each file
    -if "$@"=="distclean" for %%d in ($(DISTCLEAN_FILES)) do @if exist %%d del %%d >NUL 2>&1
!ENDIF

allclean cleanall: NUL
    $(SUBMAKE) "OS=$(ALL_OS)" $(MAKEDEFS) clean
!IF DEFINED(OUTDIR) && "$(OUTDIR)" != "" && "$(OUTDIR)" != "." && "$(OUTDIR)" != ".."
    -rd /S /Q $(OUTDIR) >NUL 2>&1 &:# Delete OUTDIR, including Unix builds there
!ENDIF

# Convert sources from Windows to Unix formats
UNIXTEMP=$(TMP)\$(PROGRAM)
w2u: NUL
    echo Converting sources into Unix format, in $(UNIXTEMP) >con
    -rd /S /Q $(UNIXTEMP) >nul
    md $(UNIXTEMP)
    for %%F in ($(SOURCES) *.h *Makefile *.mak go go.bat make.bat *.htm) do call w2u %%F $(UNIXTEMP)\%%~nxF

# Help message describing the targets
help: NUL
    type <<
Usage: make.bat [options] [nmake_options] [macro_definitions] [targets] ...

Macro definitions:     (They must be quoted, else the = sign will be lost)
  "DEBUG=0"            Generate the release version. (Default)
  "DEBUG=1"            Generate the debug version. <==> Target in a Debug\ dir.
  "DEBUG=all"          Generate both the debug and release versions.
  "DEBUG=0 1"          Generate both the debug and release versions.
  "MEM=L"              Build the DOS version w. large memory model. Dflt: T or S
  "OS=this"            Build for the current OS. (Default)
  "OS=all"             Build all buildable OS versions
  "OS=tests"           Build OS versions for testing, both debug and release
  "OS=BIOS DOS WIN95 WIN32 WIN64"   List of target OSs to build for
  "WINVER=4.0"         Target OS version. 4.0=Win95/NT4, 5.1=WinXP, 6.1=Win7

Targets:
  all                    Build all available programs and libraries
  clean                  Erase all output files built by this make system
  allclean               Erase all output files for all OSs, including Unix'
  distclean              Erase all output files and all configuration files
  {prog}.com             Build BIOS and DOS versions of {prog}.com
  {prog}.exe             Build DOS and all Windows versions of {prog}.exe
  Debug\{prog}.exe       Build BIOS and DOS versions of the same
  {prog}.exe             Build DOS, WIN32, and WIN64 versions of {prog}.exe
  Debug\{prog}.exe       Build DOS, WIN32, and WIN64 debug versions of the same
  BIOS\{prog}.com        Build the BIOS release version of {prog}.com
  BIOS\Debug\{prog}.com  Build the BIOS debug version of {prog}.com
  LODOS\{prog}.com       Build the low DOS release version of {prog}.com
  LODOS\Debug\{prog}.com Build the low DOS debug version of {prog}.com
  LODOS\{prog}.exe       Build the low DOS release version of {prog}.exe
  LODOS\Debug\{prog}.exe Build the low DOS debug version of {prog}.exe
  LODOS\{prog}.sys       Build the low DOS release version of {prog}.sys
  LODOS\Debug\{prog}.sys Build the low DOS debug version of {prog}.sys
  DOS\{prog}.com         Build the DOS release version of {prog}.com
  DOS\Debug\{prog}.com   Build the DOS debug version of {prog}.com
  DOS\{prog}.exe         Build the DOS release version of {prog}.exe
  DOS\Debug\{prog}.exe   Build the DOS debug version of {prog}.exe
  WIN95\{prog}.exe       Build the WIN95 release version of {prog}.exe
  WIN95\Debug\{prog}.exe Build the WIN95 debug version of {prog}.exe
  WIN32\{prog}.exe       Build the WIN32 release version of {prog}.exe
  WIN32\Debug\{prog}.exe Build the WIN32 debug version of {prog}.exe
  WIN64\{prog}.exe       Build the WIN64 release version of {prog}.exe
  WIN64\Debug\{prog}.exe Build the WIN64 debug version of {prog}.exe
  w2u                    Convert all sources to Unix format, into $(UNIXTEMP)
  zip                    Make a zip file with all sources

Also supports .obj and .res to compile C, C++, ASM, and Windows .RC files.
<<NOKEEP
