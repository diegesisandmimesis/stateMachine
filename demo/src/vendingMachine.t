#charset "us-ascii"
//
// vendingMachine.t
// Version 1.0
// Copyright 2022 Diegesis & Mimesis
//
// This is a very simple demonstration "game" for the stateMachine library.
//
// It can be compiled via the included makefile with
//
//	# t3make -f vendingMachine.t3m
//
// ...or the equivalent, depending on what TADS development environment
// you're using.
//
// This "game" is distributed under the MIT License, see LICENSE.txt
// for details.
//
#include <adv3.h>
#include <en_us.h>

#include "stateMachine.h"

versionInfo: GameID
        name = 'stateMachine Library Demo Game'
        byline = 'Diegesis & Mimesis'
        desc = 'Demo game for the stateMachine library. '
        version = '1.0'
        IFID = '12345'
	showAbout() {
		"This is a simple test game that demonstrates the features
		of the stateMachine library.
		<.p>
		Consult the README.txt document distributed with the library
		source for a quick summary of how to use the library in your
		own games.
		<.p>
		The library source is also extensively commented in a way
		intended to make it as readable as possible. ";
	}
;
gameMain: GameMainDef
	initialPlayerChar = me
	newGame() {
		syslog.enable('transition');
		showIntro();
		runGame(true);
	}
	showIntro() {
		"This demo includes vending machine whose logic is managed
		via a StateMachine instance.
		<.p>
		<b>NOTE:</b> This is intended to serve as an example to
		illustrate how the stateMachine module works.  The actual
		problem being solved here (keeping track of a simple two-state
		system) could be handled much more efficiently via conventional
		dobjFor() checks on the slot and buttons.
		<.p> ";
	}
;

// The thing being vended.  Starts out without a location.
class Pebble: Thing '(small) (round) (hot) (fresh) pebble' 'pebble'
	"A small, round pebble.  It appears to be neither hot nor fresh. "
	isEquivalent = true
;

class Coin: Thing '(weathered) zorkmid coin' 'zorkmid'
	"A weathered zorkmid. "
	isEquivalent = true
;

startRoom: Room 'Void'
	"This is a featureless void with a vending machine in one corner."
;

// The vending machine.
// All of the moving parts are Fixtures on it.
+machine: Fixture '(pebble) (vending) machine' 'vending machine'
	"The vending machine is implausibly labelled <q>Hot, Fresh Pebbles</q>.
	Below that there's a coin slot and a button. "
;

// The label on the machine.
++Fixture 'sign label' 'sign' "<q>Hot, Fresh Pebbles</q> ";

// The coin slot.
// It's a container so PutInAction works, and we supply a
// canFitObjThruOpening() method so we can only insert the coin.
// Note that we don't put any action handling on it.
++slot: Fixture, Container '(coin) slot' 'slot'
	"It looks like it accepts zorkmids. "
	canFitObjThruOpening(obj) { return(obj.ofKind(Coin)); }
;

// The button.
// We have to declare dobjFor(Push) to override the default verify(), which
// would fail because we're a Fixture.  But we don't otherwise handle the
// action here.
// Also note that we check the state machine's state to indicate whether
// or not the button is lit.
++button: Fixture '(ordinary) button' 'button'
	"It's an ordinary button.  It is
		<<((vendingMachineState.stateID != 'paid') ? 'not' : '')>>
		currently lit. "
	dobjFor(Push) { verify() {} }
;

// The player and a slightly infringing zorkmid.
+me: Person;
++Coin;
++Coin;

// The state machine itself.
vendingMachineState: StateMachine
	// All we declare on the machine itself is the default state.
	stateID = 'default'
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
	dstObject = slot
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
	dstObject = button
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
		obj.moveInto(machine.getOutermostRoom());
	}
;
// The trigger is >PUSH BUTTON
+++Trigger
	dstObject = button
	action = PushAction
;

// We add another "no transition" transition, this one handling when
// the player inserts multiple coins without pressing the button.
++NoTransition 'coinReturn'
	transitionAction() {
		"The coin disappears into the slot, and then, after
			some brief clattering from the machine, it is
			spit back out. ";
		gDobj.moveInto(machine.getOutermostRoom());
	}
;
+++Trigger
	srcObject = Coin
	dstObject = slot
	action = PutInAction
;
