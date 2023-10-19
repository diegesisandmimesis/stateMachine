#charset "us-ascii"
//
// basicTest.t
// Version 1.0
// Copyright 2022 Diegesis & Mimesis
//
// This is a very simple demonstration "game" for the stateMachine library.
//
// It can be compiled via the included makefile with
//
//	# t3make -f basicTest.t3m
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
		is dropped (the order matters).
		<.p> ";
	}
;

startRoom: Room 'Void' "This is a featureless void.";
+me: Person;
++pebble: Thing 'small round pebble' 'pebble' "A small, round pebble. ";
++rock: Thing 'ordinary rock' 'rock' "An ordinary rock. ";

myController: RuleEngine;

StateMachine stateID = 'foo';
+State 'foo';
++Transition toState = 'bar';
+++Trigger dstObject = pebble action = DropAction;
+State 'bar';
++Transition toState = 'baz';
+++Trigger dstObject = rock action = DropAction;
+State 'baz' 
	stateStart() { "<.p>The state is now <q>baz</q>. "; }
;
