#charset "us-ascii"
//
// sample.t
// Version 1.0
// Copyright 2022 Diegesis & Mimesis
//
// This is a very simple demonstration "game" for the stateMachine library.
//
// It can be compiled via the included makefile with
//
//	# t3make -f makefile.t3m
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
		showIntro();
		runGame(true);
	}
	showIntro() {
		"This demo includes a simple state machine that displays
		a message when the pebble is dropped and then the rock
		is dropped.  If the pebble is dropped, picked up, and
		then dropped again, the state resets.
		<.p> ";
	}
;

startRoom: Room 'Void' "This is a featureless void.";
+me: Person;
++pebble: Thing 'small round pebble' 'pebble' "A small, round pebble. ";
++rock: Thing 'ordinary rock' 'rock' "An ordinary rock. ";

StateMachine
	stateID = 'default'	// ID of the starting state

	// We could handle all the transitions here, but we only check
	// for resets.
	stateTransitionAction(id) {
		switch(id) {
			case 'default':
				"<.p>The state machine resets itself with a
					click. ";
				break;
		}
	}
;

// The starting state.
+State 'default';
++Transition toState = 'pebbleDropped';
+++Trigger dstObject = pebble action = DropAction;

// The "pebble dropped" state.
+State 'pebbleDropped'
	// We use stateStart() to display a transition message.
	stateStart() {
		"<.p>There's a soft click as the pebble is dropped. ";
	}
;
//
// Our first transition is for when the pebble is dropped a second time
// before the rock is dropped.  This resets the state machine.
++Transition toState = 'default';
+++Trigger dstObject = pebble action = DropAction;
//
// Our second transition is for when the rock is dropped after the pebble
// was dropped.  This takes us to the final state.
++Transition toState = 'done';
+++Trigger dstObject = rock action = DropAction;

// The final state.
+State 'done'
	// We display a little message when we enter the state.
	stateStart() {
		"<.p>And thus our little stony drama ends. ";
	}
;
