#charset "us-ascii"
//
// stateMachine.t
//
//	A TADS3 module implementing simple finite state machines based on
//	the ruleEngine module.
//
//
// DEFINING A STATE MACHINE
//
//	First, each game needs to declare exactly one RuleEngine instance.
//	It doesn't need to be modified in any way, and if you have a
//	sceneController instance already defined that will work too.
//
//		// Declare a RuleEngine instance.
//		myRuleEngine: RuleEngine;
//
//	The only thing that needs to be in a StateMachine declaration is
//	a stateID to use for the initial state:
//
//		// Declare a StateMachine instance.
//		StateMachine
//			stateID = 'foo'		// ID of the initial state
//		;
//		
//	Then declare one or more Transition instances on the StateMachine.
//	Transition is a subclass of Rulebook which adds a "toState" property.
//	It defines the state to switch to when the Rulebook's state becomes
//	true.  The base Transition class uses the "regular" Rulebook, which
//	becomes true of all the rulebook's rules match.  There's also a
//	TransitionMatchAny which becomes true when any of the rulebook's
//	rules match, and a TransitionMatchNone which is true by default and
//	is nil only if any of its rules are matched.
//
//	Rules on Transitions work exactly like ordinary rules.
//
//	Here's a complete simple StateMachine definition:
//
//		StateMachine stateID = 'foo';
//		+State 'foo';
//		++Transition toState = 'bar';
//		+++Trigger dstObject = pebble action = DropAction;
//		+State 'bar';
//		++Transition toState = 'baz';
//		+++Trigger dstObject = rock action = DropAction;
//		+State 'baz'
//			stateStart() { "<.p>The state is now <q>baz</q>. "; }
//		;
//
//	This StateMachine starts in state "foo".  If the pebble is dropped
//	while the machine is in state "foo", the state will become "bar".
//	If the rock is dropped while in state "bar", the state will become
//	"baz".  If the rock is dropped while the machine is in state "foo",
//	nothing will happen (to the state machine;  the pebble will be
//	dropped as normal).
//
//	The stateStart() method of the state is called when the state
//	machine enters that state.  The stateEnd() method is called when the
//	state machine leaves the state.  So when the state transitions from
//	"foo" to "bar", the state with the ID "foo" will have its
//	stateEnd() method called, and the state with the ID "bar" will have
//	its stateStart() method called.
//
//	The state machine itself will call its own stateTransitionAction()
//	method when switching states.  The argument will be the new state
//	ID.
//
//
// STATE METHODS
//
//	The State class provides:
//
//		stateStart()
//			Called without arguments when the given state
//			instance becomes the current state.
//
//		stateEnd()
//			Called without arguments on the current state
//			immediately before a different state becomes current
//
//	Note that these methods will be called during a state transition,
//	and state transitions occur late in the turn, after action
//	resolution.
//
//	In order to interrupt action resolution, the transitionAction()
//	method on the state transition should be used.
//
//
// TRANSITION METHODS
//
//	The Transition class provides:
//
//		transitionAction()
//			If defined, this method will be called without
//			arguments during action resolution, in the
//			beforeAction() window.
//
//			WHATEVER IS DEFINED IN THIS METHOD WILL REPLACE
//			THE CURRENT ACTION and action resolution will
//			be terminated (via exit) immediately after the
//			method is called.
//
//		beforeTransition()
//			Called without arguments before a state change.
//
//		afterTransition()
//			Called without arguments after a state change,
//			specifically after the old state is ended and
//			before the new state is started.
//
//
//	DETAILED LIFECYCLE
//
//		During a state change, methods are called on the
//		current state instance and the Transition instance
//		causing the state change:
//
//			Transition.beforeTransition()
//			State.stateEnd()
//			Transition.afterTransition()
//
//		Then, the new state's stateStart() method is called:
//
//			State.stateStart()
//
//
#include <adv3.h>
#include <en_us.h>

#include "stateMachine.h"

// Module ID for the library
stateMachineModuleID: ModuleID {
        name = 'State Machine Library'
        byline = 'Diegesis & Mimesis'
        version = '1.0'
        listingOrder = 99
}

class StateMachine: RuleEngine
	syslogID = 'StateMachine'

	// The ID of the current state.
	stateID = nil

	_nextStateID = nil
	_nextState = nil
	_stateTransitionFlag = nil

	// Optional object reference, for the thing the state machine
	// is controlling the state of.
	statefulObject = nil

	// Hash table of our states, keyed by their IDs.
	fsmState = perInstance(new LookupTable())

	getStateByID(id) { return(fsmState[id]); }

	// Add a state to this state machine.
	addState(obj) {
		if((obj == nil) || !obj.ofKind(State))
			return(nil);

		if(fsmState[obj.id] != nil)
			return(nil);

		fsmState[obj.id] = obj;

		obj.stateMachine = self;
		obj.ruleEngine = self;

		if(obj.id == stateID) {
			obj.enableRuleSystem();
		} else {
			obj.disableRuleSystem();
		}

		return(true);
	}

	// Remove a state from this state machine.
	removeState(obj) {
		if((obj == nil) || !obj.ofKind(State))
			return(nil);

		if(fsmState[obj.id] == nil)
			return(nil);

		fsmState.removeElement(obj);
		obj.disableAllRulebooks();
		obj.disable();

		return(true);
	}

	// Queue a state transition.
	// This is usually called from StateMachineState.queueStateTransition(),
	// in turn from StateMachineState.rulebookMatchCallback().  That is,
	// we're called by a state when that state notices that one of its
	// rulebooks matched, leading it to request a state change.
	// The first arg is the old state (a State instance) and the second
	// is the ID of the new state (a string literal).
	//
	// We queue the change instead of handling it immediately to prevent
	// multiple state changes in a single turn.
	queueStateTransition(oldState, newStateID) {
		// Make sure the new state ID is valid.
		if(fsmState[newStateID] == nil) {
			_nextStateID = nil;
			return(nil);
		}

		// Remember the new state ID.
		_nextStateID = newStateID;

		// Let the rule engine know we want to be pinged later
		// in the turn.
		//gRuleEngine.addStateTransition(self);
		//addStateTransition(self);
		_stateTransitionFlag = true;

		return(true);

	}

	ruleEngineAction() {
		inherited();
		if(_stateTransitionFlag == true) {
			stateTransition();
			_stateTransitionFlag = nil;
		}
	}

	validateStateTransition() {
		return(_nextStateID != stateID);
	}

	// Called by RuleEngine after action resolution, during the
	// window when daemons are polled.
	// This only gets called if we rand queueStateTransition() (above)
	// earlier in the turn (during action resolution, usually).
	stateTransition() {
		local obj;

		// Make sure the state's changing.
		if(validateStateTransition() != true)
			return;

		// End the current state, if it's not nil
		if((obj = fsmState[stateID]) != nil)
			obj._stateEnd();

		// Set the new state ID and clear queued one.
		stateID = _nextStateID;
		_nextStateID = nil;

		// If the new state is a bogus ID something very
		// silly has happened and we bail.
		if((obj = fsmState[stateID]) == nil)
			return;

		// New state transition notifications for the new state.
		obj._stateStart();

		// Do state-machine-level transition stuff.
		stateTransitionAction(stateID);
	}

	// For instances' state transition actions.
	stateTransitionAction(id) {}

	debugStateMachine() {}
;
