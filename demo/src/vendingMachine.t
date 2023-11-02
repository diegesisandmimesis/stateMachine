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

startRoom: Room 'Void'
	"This is a featureless void with a vending machine in one corner."
;
+machine: VendingMachine stateMachine = vendingMachineState;

// The player and a slightly infringing zorkmid.
+me: Person;
++Coin;
++Coin;

modify vendingMachineState statefulObject = machine;
