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
//	Here's an example of a state machine with multiple transitions in
//	one of its states:
//
//		StateMachine
//			stateID = 'default'	// ID of the starting state
//
//			// Display a message when the state resets
//			stateTransitionAction(id) {
//				if(id == 'default')
//					"<.p>The state machine resets. ";
//			}
//		;
//
//		+State 'default';
//		++Transition toState = 'pebbleDropped';
//		+++Trigger dstObject = pebble action = DropAction;
//
//		+State 'pebbleDropped';
//
//		// The first transition, if the pebble is dropped a second
//		// time.  It resets the state machine.
//		++Transition toState = 'default';
//		+++Trigger dstObject = pebble action = DropAction;
//
//		// The second transition, if the rock is dropped after the
//		// pebble.  It advances the machine to its final state.
//		++Transition toState = 'done';
//		+++Trigger dstObject = rock action = DropAction;
//
//		+State 'done' stateStart() { "<.p>Reached the final state. "; };
//
//	This works the same as the first example unless you pick up the pebble
//	and drop it again before dropping the rock, in which case the
//	state is reset.
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

	// Hash table of our states, keyed by their IDs.
	fsmState = perInstance(new LookupTable())

	// Add a State.
	addState(obj) {
		if((obj == nil) || !obj.ofKind(State))
			return(nil);
		if(fsmState[obj.id] != nil)
			return(nil);
		fsmState[obj.id] = obj;
		if(obj.id == stateID)
			obj.enableAllRulebooks();
		else
			obj.disableAllRulebooks();

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
			stateID = nil;
			return(nil);
		}

		obj._stateStart();
		stateID = obj.id;

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

		// Do anything we want to do when the state changes.
		stateTransitionAction(newStateID);

		return(true);

	}

	// For instances' state transition actions.
	stateTransitionAction(id) {}
;
