#charset "us-ascii"
//
// beforeAfterTest.t
// Version 1.0
// Copyright 2022 Diegesis & Mimesis
//
// This is a very simple demonstration "game" for the stateMachine library.
//
// It can be compiled via the included makefile with
//
//	# t3make -f beforeAfterTest.t3m
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
		//syslog.enable('RuleEngine');
		showIntro();
		runGame(true);
	}
	showIntro() {
		"This demo is based on the basicTest demo, with additional
		output.
		<.p>
		Specifically:  each transition will output a message in
		its beforeTransition() and afterTransition() methods.
		<.p>
		The state machine itself just checks for:
		<.p>
		\n\t<b>&gt;</b>DROP PEBBLE
		\n\t<b>&gt;</b>DROP ROCK
		<.p>
		...in that order.
		<.p> ";
	}
;

startRoom: Room 'Void' "This is a featureless void.";
+me: Person;
++pebble: Thing 'small round pebble' 'pebble' "A small, round pebble. ";
++rock: Thing 'ordinary rock' 'rock' "An ordinary rock. ";

// Modify the State definition to bark during transitions.
modify State
	stateStart() { "State <<id>>:  stateStart().\n "; }
	stateEnd() { "State <<id>>:  stateEnd().\n "; }
;

// Modify the Transition definition to bark during transitions.
modify Transition
	beforeTransition() { "Transition <<id>>:  beforeTransition()\n "; }
	afterTransition() { "Transition <<id>>:  afterTransition()\n "; }
	transitionAction() {
		"Transition <<id>>:  transitionAction()\n ";
		gDobj.moveInto(gActor.location);
	}
;

// State machine with a starting state.
StateMachine stateID = 'foo';

// First state.  One transition, triggered by >DROP PEBBLE
+State 'foo';
++Transition 'FooToBar' toState = 'bar';
+++Trigger dstObject = pebble action = DropAction;

// Second state.  One transition, triggered by >DROP ROCK
+State 'bar';
++Transition 'BarToBaz' toState = 'baz';
+++Trigger dstObject = rock action = DropAction;

// Last state.  No transitions.
+State 'baz';
