###############################################################################
#                                                                             #
#   File name       eval.mak                                                  #
#                                                                             #
#   Description     Set macro based on the output of a batch command          #
#                                                                             #
#   Notes           Usage:                                                    #
#                   EVAL=VARNAME=`COMMAND`	 	                      #
#                   !INCLUDE <eval.mak>                                       #
#                                                                             #
#                   Ex:                                                       #
#                   COUNTER=2                                                 #
#                   EVAL=COUNTER=`set /a =$(COUNTER)+1`                       #
#                   !INCLUDE <eval.mak>                                       #
#                   # Result: COUNTER=3                                       #
#                                                                             #
#   History                                                                   #
#    2024-01-05 JFL jf.larvoire@free.fr created this file.                    #
#                                                                             #
#                  (C) Copyright 2024 Jean-Francois Larvoire                  #
# Licensed under the Apache 2.0 license - www.apache.org/licenses/LICENSE-2.0 #
###############################################################################

# Invoke intersect.bat for doing the conversion
EVAL_MAK=$(TMP)\eval.$(PID).mak
EVAL_CMD="$(NMINCLUDE)\eval.bat" $(EVAL) >"$(EVAL_MAK)"

# Log the command executed
# !IF DEFINED(MESSAGES)
# !  MESSAGE EVAL=$(EVAL)
# !  MESSAGE $(EVAL_CMD)
# !ENDIF

# If the evaluation succeeds, load the output make file
!IF [$(EVAL_CMD)] == 0
!  INCLUDE "$(EVAL_MAK)"
!ELSE
!  ERROR eval.mak : Failed to evaluate $(EVAL_CMD)
!ENDIF

# Log the result generated
!IF DEFINED(MESSAGES)
!  MESSAGE $(EVAL_MSG)
!ENDIF

# Cleanup
!UNDEF EVAL_MAK
!UNDEF EVAL_MSG
