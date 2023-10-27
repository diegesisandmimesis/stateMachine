#charset "us-ascii"
//
// stateMachineRuleEngine.t
//
//	RuleEngine modifications for state machines.
//
#include <adv3.h>
#include <en_us.h>

#include "stateMachine.h"

modify RuleEngine
	// For keeping track of which state machines need notification
	// at the end of the turn.
	stateTransition = perInstance(new Vector())

	// Subscribe to notification later in the turn.
	// Arg is a StateEngine instance.
	addStateTransition(obj) {
		if((obj == nil) || !obj.ofKind(StateMachine))
			return(nil);

		stateTransition.append(obj);

		return(true);
	}

	// Called by the RuleEngine's daemon instance, this sends notifications
	// to the state engines that requested them earlier in the turn.
	updateRuleEngine() {
		inherited();

		// Notify everyone who asked for it.
		stateTransition.forEach(function(o) { o.stateTransition(); });

		// Clear the notification list.
		stateTransition.setLength(0);
	}
;
