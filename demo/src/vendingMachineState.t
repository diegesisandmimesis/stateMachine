#charset "us-ascii"
//
// vendingMachineState.t
//
//	State machine for controlling a vending machine.
//
#include <adv3.h>
#include <en_us.h>

#include "stateMachine.h"

// State machine for controlling the vending machine
vendingMachineState: StateMachine
	// The default state of the state machine.
	stateID = 'default'

	// The object we're controlling the state of.
	statefulObject = nil
;

// The default state.  All we give it is an ID.
+State 'default';
// The default state's transitions.  We have two, although one is a
// "no transition" transition (just used to display a message without
// changing the state).
++Transition 'insertCoin'
	// This is the state we switch to if the transition's rules match.
	toState = 'paid'

	// The action for the transition.  This will replace any turn
	// action.
	// We display a message and take care of moving the coin (which
	// will be gDobj, per our trigger rules below).
	transitionAction() {
		"The coin clatters down into the machine's
			innards and the button lights up. ";
		gDobj.moveInto(nil);
	}
;
// The transition's trigger is >PUT COIN IN SLOT
+++Trigger
	srcObject = Coin
	dstObject = statefulObject.slot
	action = PutInAction
;

// A "no transition" transition.  This is just to display a special
// message if the button is pushed before we've paid.
// It also illustrates how Transitions/Rulebooks are only active when they're
// part of the state machine's current state:  the trigger is identical to
// the one in the "paid" state, and so the only thing that keeps them both
// from firing every time the button is pressed is the state juggling.
++NoTransition 'haventPaid'
	transitionAction() {
		reportFailure('When {you/he} push{es} the button, it
			briefly lights up red.  No pebble is dispensed. ');
	}
;
// The NoTransition's trigger is >PUSH BUTTON
+++Trigger
	dstObject = statefulObject.button
	action = PushAction
;

// The state for when we've put a zorkmid in the slot.
+State 'paid';
++Transition 'dispensing'
	// After we dispense a pebble, we return to the default state.
	toState = 'default'

	// The action for the transition when the vending machine dispenses
	// a pebble.
	// We display a message and move a pebble into the room.
	transitionAction() {
		local obj;

		defaultReport('The vending machine emits a loud
			thunking sound as it spits out a pebble. ');

		obj = Pebble.createInstance();
		obj.moveInto(statefulObject.getOutermostRoom());
	}
;
// The trigger is >PUSH BUTTON
+++Trigger
	dstObject = statefulObject.button
	action = PushAction
;

// We add another "no transition" transition, this one handling when
// the player inserts multiple coins without pressing the button.
++NoTransition 'coinReturn'
	transitionAction() {
		"The coin disappears into the slot, and then, after
			some brief clattering from the machine, it is
			spit back out. ";
		gDobj.moveInto(statefulObject.getOutermostRoom());
	}
;
+++Trigger
	srcObject = Coin
	dstObject = statefulObject.slot
	action = PutInAction
;
