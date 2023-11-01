#charset "us-ascii"
//
// toaster.t
// Version 1.0
// Copyright 2022 Diegesis & Mimesis
//
// This is a very simple demonstration "game" for the stateMachine library.
//
// It can be compiled via the included makefile with
//
//	# t3make -f toaster.t3m
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
		//toasterState.debugStateMachine();
		runGame(true);
	}
	showIntro() {
		"This demo includes toaster whose logic is managed
		via a StateMachine instance.
		<.p> ";
	}
;

class Slice: Thing
	desc = "It's <<aName>>. "
	isEquivalent = true
;
class Bread: Slice '(slice) bread' 'slice of bread';
class Toast: Slice '(slice) toast' 'slice of toast';

startRoom: Room 'Void' "This is a featureless void.";
+toaster: Container '(silver) (metal) toaster slot' 'toaster'
	"A silver toaster with a single slot on its top. "
	dobjFor(TurnOn) { verify() {} }
	iobjFor(PutIn) {
		verify() {
			if(contents.length != 0)
				illogicalNow('The toaster can only hold one
					thing at a time. ');
		}
	}
	canFitObjThruOpening(obj) { return(obj.ofKind(Slice)); }
;

+me: Person;
++Bread;
++Bread;

class BreadInToaster: Rule
	_breadTest() {
		local l;

		l = toaster.allContents();

		if(l.length != 1)
			return(nil);

		return(l[1].ofKind(Bread));
	}

	matchRule(data?) { return(_breadTest()); }
;

class NoBreadInToaster: BreadInToaster
	matchRule(data?) { return(!_breadTest()); }
;

class StartToaster: Trigger dstObject = toaster action = TurnOnAction;

// We always have to declare a RuleEngine instance when we're using rules.
RuleEngine;

// The state machine itself.
toasterState: StateMachine stateID = 'empty';

+State 'empty';
++Transition 'hasBread' 'ready'
	"The bread goes in the toaster. "
;
+++BreadInToaster;
++NoTransition 'foo'
	"You start the toaster and it immediately stops because it
	doesn't have anything to toast. "
;
+++StartToaster;

+State 'ready';
++Transition 'toasting' 'empty'
	transitionAction() {
		"The toaster toasts. ";
		// Kludge.  In a real game we'd make sure it's the bread.
		toaster.contents[1].moveInto(nil);
		Toast.createInstance().moveInto(toaster);
	}
;
+++StartToaster;

++Transition 'noBread' 'empty';
+++NoBreadInToaster;
