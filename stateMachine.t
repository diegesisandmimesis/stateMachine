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
//	while the machine is in state "foo', the state will become "bar".
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
#include <adv3.h>
#include <en_us.h>

// Module ID for the library
stateMachineModuleID: ModuleID {
        name = 'State Machine Library'
        byline = 'Diegesis & Mimesis'
        version = '1.0'
        listingOrder = 99
}

class StateMachine: RuleEngineObject
	syslogID = 'StateMachine'

	// The ID of the current state.
	stateID = nil

	_nextStateID = nil
	_nextState = nil

	// Hash table of our states, keyed by their IDs.
	fsmState = perInstance(new LookupTable())

	// Add a State.
	addState(obj) {
		if((obj == nil) || !obj.ofKind(State))
			return(nil);
		if(fsmState[obj.id] != nil)
			return(nil);
		fsmState[obj.id] = obj;
		if(obj.id == stateID) {
			obj.enableAllRulebooks();
			obj.enable();
		} else {
			obj.disableAllRulebooks();
			obj.disable();
		}

		return(true);
	}

	// Remove a state.
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

	// Called during a state transition.  Argument is the old state.
	clearState(obj) {
		if((obj == nil) || !obj.ofKind(State))
			return(nil);

		obj._stateEnd();

		return(true);
	}

	// Called during a state transition.  Argument is the new state.
	setState(obj) {
		if((obj == nil) || !obj.ofKind(State)) {
			_nextState = nil;
			_nextStateID = nil;
			return(nil);
		}

		// Remember the new state.
		_nextState = obj;
		_nextStateID = obj.id;

		return(true);
	}

	// Handle a state transition.
	// Usually called from a state object, when that state notices one
	// of its transition conditions is met.
	// First arg is the State instance of the old state, second arg
	// is the ID of the new state.
	stateTransition(oldState, newStateID) {
		_debug('stateTransition:  <<(oldState ? oldState.id : 'nil')>>
			to <<newStateID>>');

		// Clear the old state.
		clearState(oldState);

		// Set the new state.
		if(setState(fsmState[newStateID]) != true)
			return(nil);

		return(true);

	}

	// Method called by the RuleEngine near the end of
	// turn processing.
	// We do this juggling so that we don't have to worry about
	// state transitions firing multiple times per turn (pushing
	// a button triggers a state change, the new state has
	// a rule for checking if the button is being pushed, which triggers
	// a transition back to the original state...which has a rule
	// for the checking if the button is being pushed...).
	handleStateTransition() {
		// Make sure the state's changing.
		if((_nextStateID == stateID) ||( _nextState == nil))
			return;
		
		// Call the state's stateStart() method.
		_nextState._stateStart();
		_nextState = nil;

		// Actually set the state.
		stateID = _nextStateID;

		// Do whatever we're supposed to do on a state change.
		stateTransitionAction(stateID);
	}

	// For instances' state transition actions.
	stateTransitionAction(id) {}
;


modify RuleEngine
	updateRuleEngine() {
		inherited();
		forEachInstance(StateMachine, function(o) {
			o.handleStateTransition();
		});
	}
;
