#charset "us-ascii"
//
// stateMachineState.t
//
#include <adv3.h>
#include <en_us.h>

#include "stateMachine.h"

// States, like RuleSystem, are just bundles of Rulebooks.
// States additionally have a "toState" property, for the ID of the
// state to transition to if our conditions are satisfied.
class State: RuleSystem
	// This state's state ID.
	id = nil

	// The StateMachine we're part of.
	stateMachine = nil

	statefulObject = (stateMachine.statefulObject)

	// A queue of Transition instances that want to be notified after
	// the state changes.
	_transitionQueue = perInstance(new Vector())

	// Queue a state transition.  We're the old state and the arg is the
	// ID of the rulebook triggering the change.
	queueStateTransition(id) {
		local obj;

		// If we don't have an owner, we've got nobody to
		// notify;  fail.
		if(stateMachine == nil)
			return;

		// Get the rulebook that was triggered or give up.
		if((obj = getRulebook(id)) == nil)
			return;

		// NoTransition rulebooks don't change the state.
		if(obj.ofKind(NoTransition))
			return;

		// Notify our state machine of the transition.
		stateMachine.queueStateTransition(self, obj.toState);
	}

	// Normal RuleSystem method, called when all a rulebook's rules match.
	// Arg is the rulebook ID.
	rulebookMatchCallback(id) {
		// Do whatever we'd normally do.
		inherited(id);

		// Also notify our state machine about the state transition.
		queueStateTransition(id);
	}

	// Preinit method.
	initializeRuleSystem() {
		// Do whatever we'd normally do.
		inherited();

		// Add ourselves to our state machine.
		initializeStateMachineState();
	}

	_tryStateMachine(obj) {
		if(obj == nil)
			return(nil);
		if(!obj.ofKind(StateMachine))
			return(nil);

		if(obj.addState(self) == true)
			stateMachine = obj;

		return(true);
	}

	// Called at preinit.
	initializeStateMachineState() {
		if(_tryStateMachine(location) == true)
			return;
		if(_tryStateMachine(location.stateMachine) == true)
			return;
	}

	// Mark a transition instance for notification after the state
	// changes.
	// This is usually called by the Transition instance that's triggering
	// the state change, and it's used for calling afterTransition() on
	// it.
	// We have to do this juggling because the triggers are evaluated
	// during action resolution (early in the turn) and we don't update
	// the state until after action resolution is done.
	queueTransition(obj) {
		if((obj == nil) || !obj.ofKind(Transition))
			return;

		_transitionQueue.append(obj);
	}

	// Call all the subscribers to the transition queue, clearing it
	// afterwards.
	notifyQueuedTransitions() {
		_transitionQueue.forEach(function(o) { o.afterTransition(); });
		_transitionQueue.setLength(0);
	}

	// Called by our state machine during a state transition where
	// we were the current state but aren't anymore.
	_stateEnd() {
		disableState();
		stateEnd();
		notifyQueuedTransitions();
	}

	// Called by our state machine during a state transition when we
	// become the current state.
	_stateStart() {
		enableState();
		stateStart();
	}

	// Pure semantic sugar.
	enableState() { enableRuleSystem(); }
	disableState() { disableRuleSystem(); }

	// State transition lifecycle methods.
	// Called when a state is set and cleared, respectively.
	stateStart() {}
	stateEnd() {}

	debugStateMachineState() {}
;
