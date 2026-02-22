###############################################################################
#                                                                             #
#   File name       intersect.mak                                             #
#                                                                             #
#   Description     Intersect two lists			                      #
#                                                                             #
#   Notes           Usage:                                                    #
#                   INTERSECT_ARGS=LIST1 LIST2 OUTVARNAME                     #
#                   !INCLUDE <intersect.mak>                                  #
#                                                                             #
#                   Ex:                                                       #
#                   INTERSECT_ARGS="WIN32 WIN64" "DOS WIN32" OS               #
#                   !INCLUDE <intersect.mak>                                  #
#                   # Result: OS=WIN32                                        #
#                                                                             #
#   History                                                                   #
#    2024-01-02 JFL jf.larvoire@free.fr created this file.                    #
#                                                                             #
#                  (C) Copyright 2024 Jean-Francois Larvoire                  #
# Licensed under the Apache 2.0 license - www.apache.org/licenses/LICENSE-2.0 #
###############################################################################

# Invoke intersect.bat for doing the conversion
INTERSECT_MAK=$(TMP)\intersect.$(PID).mak
INTERSECT_CMD="$(NMINCLUDE)\intersect.bat" $(INTERSECT_ARGS) >"$(INTERSECT_MAK)"

# Log the command executed
# !IF DEFINED(MESSAGES)
# !  MESSAGE $(INTERSECT_CMD)
# !ENDIF

# If the intersection succeeds, load the output make file
!IF [$(INTERSECT_CMD)] == 0
!  INCLUDE "$(INTERSECT_MAK)"
!ELSE
!  ERROR intersect.mak : Failed with INTERSECT_ARGS=$(INTERSECT_ARGS)
!ENDIF

# Log the result generated
!IF DEFINED(MESSAGES)
!  MESSAGE $(INTERSECT_MSG)
!ENDIF

# Cleanup
!UNDEF INTERSECT_MAK
!UNDEF INTERSECT_MSG
