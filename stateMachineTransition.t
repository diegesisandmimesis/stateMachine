#charset "us-ascii"
//
// stateMachineTransition.t
//
#include <adv3.h>
#include <en_us.h>

#include "stateMachine.h"

// Transitions are specialized Rulebooks.
class Transition: Rulebook
	// This defines what state the FSM should move into if this
	// rulebook matches.
	toState = nil

	// Wrap the normal Rulebook.callback() in our before and after
	// methods.
	callback() {
		// Make sure we're notified after the transition.
		queueTransition();

		// Do any before transition stuff.
		beforeTransition();

		// Do any default callback stuff.
		inherited();

		// Check to see if we have a non-null transitionAction()
		// defined.
		// If so, we treat it like a replacement action:  we
		// do it, and then stop processing the action.
		if(propDefined(&transitionAction)
			&& (propType(&transitionAction) != TypeNil)) {
			transitionAction();
			exit;
		}
	}

	// Try to notify the state we're part of that we want to be
	// notified after the state transition.
	queueTransition() {
		if(ruleSystem == nil) return;
		ruleSystem.queueTransition(self);
	}

	// Stub methods.
	beforeTransition() {}
	afterTransition() {}
	transitionAction = nil

	debugStateMachineTransition() {}
;

// Transitions are just rulebooks, so we shadow all the stock
// Rulebook variations.
class TransitionMatchAll: Transition;
class TransitionMatchAny: RulebookMatchAny, Transition;
class TransitionMatchNone: RulebookMatchNone, Transition;

class NoTransition: Transition;
