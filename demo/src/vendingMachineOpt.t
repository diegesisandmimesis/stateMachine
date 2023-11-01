#charset "us-ascii"
//
// vendingMachineOpt.t
// Version 1.0
// Copyright 2022 Diegesis & Mimesis
//
// This is a very simple demonstration "game" for the stateMachine library.
//
// It can be compiled via the included makefile with
//
//	# t3make -f vendingMachineOpt.t3m
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
		"This demo includes vending machine whose logic is managed
		via a StateMachine instance.
		<.p>
		This is functionally identical to the vendingMachine.t
		demo, written slightly differently.
		<.p> ";
	}
;

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

+machine: Fixture '(pebble) (vending) machine' 'vending machine'
	"The vending machine is implausibly labelled <q>Hot, Fresh Pebbles</q>.
	Below that there's a coin slot and a button. "
;
++Fixture 'sign label' 'sign' "<q>Hot, Fresh Pebbles</q> ";
++slot: Fixture, Container '(coin) slot' 'slot'
	"It looks like it accepts zorkmids. "
	canFitObjThruOpening(obj) { return(obj.ofKind(Coin)); }
;
++button: Fixture '(ordinary) button' 'button'
	"It's an ordinary button.  It is
		<<((vendingMachineState.stateID != 'paid') ? 'not' : '')>>
		currently lit. "
	dobjFor(Push) { verify() {} }
;

+me: Person;
++Coin;
++Coin;

// In this demo we define the trigger actions as their own subclasses
// of Trigger.
class CoinTrigger: Trigger
	srcObject = Coin
	dstObject = slot
	action = PutInAction
;

class ButtonTrigger: Trigger dstObject = button action = PushAction;


//myController: RuleEngine;

vendingMachineState: StateMachine stateID = 'default';

+State 'default';
++Transition 'insertCoin' 'paid'
	transitionAction() {
		defaultReport('The coin clatters down into the machine\'s
			innards and the button lights up. ');
		gDobj.moveInto(nil);
	}
;
+++CoinTrigger;

++NoTransition 'haventPaid'
	"When {you/he} push{es} the button, it briefly lights up red.  No
		pebble is dispensed. "
;
+++ButtonTrigger;

+State 'paid';
++Transition 'dispensing' 'default'
	transitionAction() {
		local obj;

		defaultReport('The vending machine emits a loud
			thunking sound as it spits out a pebble. ');

		obj = Pebble.createInstance();
		obj.moveInto(machine.getOutermostRoom());
	}
;
+++ButtonTrigger;

++NoTransition 'coinReturn'
	transitionAction() {
		defaultReport('The coin disappears into the slot, and then,
			after some brief clattering from the machine, it is
			spit back out. ');
		gDobj.moveInto(machine.getOutermostRoom());
	}
;
+++CoinTrigger;
