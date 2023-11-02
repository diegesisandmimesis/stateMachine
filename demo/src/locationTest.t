#charset "us-ascii"
//
// locationTest.t
// Version 1.0
// Copyright 2022 Diegesis & Mimesis
//
// This is a very simple demonstration "game" for the stateMachine library.
//
// It can be compiled via the included makefile with
//
//	# t3make -f locationTest.t3m
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
	}
;

startRoom: Room 'Void'
	"This is a featureless void, with a vending machine that is completely
	devoid of rules.
	<.p>
	The rule room is to the north. "
	north = ruleRoom
;

+me: Person;
++Coin;
++Coin;

ruleRoom: Room 'Rule Room'
	"This is a room with rules.  And a vending machine.
	<.p>
	The void lies to the south. "
	south = startRoom
;
//+machine: VendingMachine, StateMachineThing
+vendingMachineState: VendingMachine, StateMachineThing
	stateID = 'default'
	statefulObject = self
;
+State 'default';
++Transition 'insertCoin'
	toState = 'paid'
	transitionAction() {
		"The coin clatters down into the machine's
			innards and the button lights up. ";
		gDobj.moveInto(nil);
	}
;
+++Trigger
	srcObject = Coin
	dstObject = statefulObject.slot
	action = PutInAction
;
++NoTransition 'haventPaid'
	transitionAction() {
		reportFailure('When {you/he} push{es} the button, it
			briefly lights up red.  No pebble is dispensed. ');
	}
;
+++Trigger
	dstObject = statefulObject.button
	action = PushAction
;

+State 'paid';
++Transition 'dispensing'
	toState = 'default'

	transitionAction() {
		local obj;

		defaultReport('The vending machine emits a loud
			thunking sound as it spits out a pebble. ');

		obj = Pebble.createInstance();
		obj.moveInto(statefulObject.getOutermostRoom());
	}
;
+++Trigger
	dstObject = statefulObject.button
	action = PushAction
;
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
