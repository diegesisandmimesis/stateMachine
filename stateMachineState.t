#charset "us-ascii"
//
// stateMachineState.t
//
#include <adv3.h>
#include <en_us.h>

// States, like RuleUsers, are just bundles of Rulebooks.
// States additionally have a "toState" property, for the ID of the
// state to transition to if our conditions are satisfied.
class State: RuleUser
	id = nil

	toState = nil

	// State transition.  We're the old state and the arg is the
	// ID of the new state.
	stateTransition(id) {
		local obj;

		// If we don't have an owner, we've got nobody to
		// notify;  fail.
		if(owner == nil)
			return;

		// Get the rulebook that was satisfied or give up.
		if((obj = getRulebook(id)) == nil)
			return;

		// NoTransition rulebooks don't change the state.
		if(obj.ofKind(NoTransition))
			return;

		// Notify our state machine of the transition.
		owner.stateTransition(self, obj.toState);
	}

	// Normal RuleUser method, called when all a rulebook's rules match.
	// Arg is the rulebook ID.
	rulebookMatchCallback(id) {
		// Do whatever we'd normally do.
		inherited(id);

		// Also notify our state machine about the state transition.
		stateTransition(id);
	}

	// Preinit method.
	initializeRuleUser() {
		// Do whatever we'd normally do.
		inherited();

		// Add ourselves to our state machine.
		initializeStateMachineState();
	}

	// Called at preinit.
	initializeStateMachineState() {
		// Make sure we're in a state machine.
		if((location == nil) || !location.ofKind(StateMachine))
			return;

		// Tell our state machine to add us.
		location.addState(self);

		// Remember our state machine.
		owner = location;
	}

	// Called by our state machine during a state transition where
	// we were the current state but aren't anymore.
	_stateEnd() {
		disableRuleUser();
		//disableAllRulebooks();
		stateEnd();
	}

	// Called by our state machine during a state transition when we
	// become the current state.
	_stateStart() {
		enableRuleUser();
		//enableAllRulebooks();
		stateStart();
	}

	// State transition lifecycle methods.
	// Called when a state is set and cleared, respectively.
	stateStart() {}
	stateEnd() {}
;
