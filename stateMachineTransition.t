#charset "us-ascii"
//
// stateMachineTransition.t
//
#include <adv3.h>
#include <en_us.h>

// Transitions are specialized Rulebooks.
class Transition: Rulebook
	// This defines what state the FSM should move into if this
	// rulebook matches.
	toState = nil

	// Wrap the normal Rulebook.callback() in our before and after
	// methods.
	callback() {
		beforeTransition();
		inherited();
		afterTransition();
	}

	// Stub methods.
	beforeTransition() {}
	afterTransition() {}
;

// Transitions are just rulebooks, so we shadow all the stock
// Rulebook variations.
class TransitionMatchAll: Transition;
class TransitionMatchAny: RulebookMatchAny, Transition;
class TransitionMatchNone: RulebookMatchNone, Transition;

class NoTransition: Transition;
