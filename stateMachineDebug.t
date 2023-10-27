#charset "us-ascii"
//
// stateMachineDebug.t
//
//	Debugging stuff.
//
//	For readibility all the logging stuff is tagged.  The tags are:
//
//		transition		state transitions
//
//	To enable debugging output for a tag, use syslog.enable() with
//	the tag as the argument.  For example:
//
//		syslog.enable('transition');
//
#include <adv3.h>
#include <en_us.h>

#include "stateMachine.h"

#ifdef SYSLOG

modify StateMachine
	queueStateTransition(oldState, newStateID) {
		_debug('queueStateTransition:
			<<(oldState ? oldState.id : 'nil')>>
			to <<newStateID>>', 'transition');
		return(inherited(oldState, newStateID));
	}

	stateTransition() {
		_debug('stateTransition(): <<toString(stateID)>> to
                        <<toString(_nextStateID)>>', 'transition');
		inherited();
	}
;

#endif // SYSLOG
