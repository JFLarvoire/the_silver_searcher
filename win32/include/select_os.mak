###############################################################################
#                                                                             #
#   File name       select_os.mak                                             #
#                                                                             #
#   Description     Select which target OSs are to be built                   #
#                                                                             #
#   Notes           Uses the following macros as arguments:                   #
#                                                                             #
#                   ONLY_OS=OS1 OS2 ...     List of possible OSs to build     #
#                                             Default: Any OS                 #
#                   DEFAULT_OS=OS           The one to build by default       #
#                                             Default: The first in $(ONLY_OS)#
#                                                                             #
#   History                                                                   #
#    2024-10-08 JFL jf.larvoire@free.fr created this file.                    #
#                                                                             #
#                  (C) Copyright 2024 Jean-Francois Larvoire                  #
# Licensed under the Apache 2.0 license - www.apache.org/licenses/LICENSE-2.0 #
###############################################################################

# When invoked without a specific target OS, build for $(DEFAULT_OS)
!IF !DEFINED(OS) || "$(OS)"=="Windows_NT" # If OS is not specified on the command line
!  UNDEF OS # Necessary to override OS values set on the command line
!  IF !DEFINED(DEFAULT_OS) # If DEFAULT_OS isn't defined
!    IF DEFINED(ONLY_OS) && ("$(ONLY_OS: =)" == "$(ONLY_OS)") # Simple case with a single target
DEFAULT_OS=$(ONLY_OS) # then use it as default
!    ELSE # There are several targets
EVAL=DEFAULT_OS=`for /f "tokens=1" %t in ("$(ONLY_OS)") do echo %t`
!      INCLUDE <eval.mak> # Use the first one as default
!    ENDIF
!  ENDIF
OS=$(DEFAULT_OS)
!ENDIF

# If we're involved with a specific target OS, check if there's anything to be done now.
!IF DEFINED(ONLY_OS)

!  IF "$(OS)"=="NT"
!    UNDEF ONLY_OS
ONLY_OS=WIN32 IA64 WIN64 ARM ARM64
!  ENDIF

!  IF "$(ONLY_OS)"=="NT"
!    UNDEF ONLY_OS
ONLY_OS=WIN32 IA64 WIN64 ARM ARM64
!  ENDIF

SELECT_OS_MSG=This module is only for $(ONLY_OS: = or ), not for $(OS: = or )

INTERSECT_ARGS="$(OS)" "$(ONLY_OS)" OS2
!  INCLUDE "intersect.mak" # OS2=intersection of $(OS) and $(ONLY_OS)
!  IF "$(OS2)"==""	   # None of the $(ONLY_OS) OSs matched
!    IF DEFINED(MAKEDEPTH) && "$(MAKEDEPTH)"!="0" # If invoked recursively from the project root directory
!      IF DEFINED(MESSAGES) # => Nothing buildable here, but there might be buildable things in other sibling directories
!        MESSAGE $(MAKEFILE) : Nothing to do. $(SELECT_OS_MSG)
!      ENDIF
# DO_NOTHING_MSG=Nothing to do # Don't put $(OS) in the message, as it'll be redefined below. (Or valueize it, but this wastes 5ms)

nothing_to_do: NUL
    echo Nothing to do. $(SELECT_OS_MSG)

!    ELSE # Invoked locally in the subdirectory => The user asked for something impossible
!      ERROR $(MAKEFILE) : $(SELECT_OS_MSG)
!    ENDIF # DEFINED(MAKEDEPTH) && "$(MAKEDEPTH)"!="0" # If invoked recursively from the project root directory
!  ENDIF # "$(OS2)"==""
!ENDIF # DEFINED(ONLY_OS)

# # If there's nothing to do, define a default goal that will do just that
# !IF DEFINED(DO_NOTHING_MSG)
# 
# nothing_to_do: NUL
#     echo $(DO_NOTHING_MSG)
# 
# !ENDIF

# Cleanup
!IF "$(OS2)"!=""
OS=$(OS2) # No need to valueize this one, as OS2 itself is valueized by intersect.mak
# Don't !UNDEF OS2 here again, else OS won't be defined anymore either (unless OS revaluized!)
!ENDIF
!UNDEF SELECT_OS_MSG

