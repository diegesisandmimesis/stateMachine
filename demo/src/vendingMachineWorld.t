#charset "us-ascii"
//
// vendingMachineWorld.t
//
//	In-game vending machine stuff.
//
#include <adv3.h>
#include <en_us.h>

#include "stateMachine.h"

// The thing being vended.  Starts out without a location.
class Pebble: Thing '(small) (round) (hot) (fresh) pebble' 'pebble'
	"A small, round pebble.  It appears to be neither hot nor fresh. "
	isEquivalent = true
;

class Coin: Thing '(weathered) zorkmid coin' 'zorkmid'
	"A weathered zorkmid. "
	isEquivalent = true
;

// The vending machine.
// All of the moving parts are Fixtures on it.
class VendingMachine: Fixture '(pebble) (vending) machine' 'vending machine'
	"The vending machine is implausibly labelled <q>Hot, Fresh Pebbles</q>.
	Below that there's a coin slot and a button. "

	stateMachine = nil

	sign = VendingMachineSign
	slot = VendingMachineSlot
	button = VendingMachineButton

	initializeThing() {
		inherited();
		_initializeVendingMachine();
	}

	_initializeVendingMachine() {
		(sign = new VendingMachineSign).moveInto(self);
		(slot = new VendingMachineSlot).moveInto(self);
		(button = new VendingMachineButton).moveInto(self);
	}
;

// The label on the machine.
class VendingMachineSign: Fixture 'sign label' 'sign'
	"<q>Hot, Fresh Pebbles</q> ";

// The coin slot.
// It's a container so PutInAction works, and we supply a
// canFitObjThruOpening() method so we can only insert the coin.
// Note that we don't put any action handling on it.
class VendingMachineSlot: Fixture, Container '(coin) slot' 'slot'
	"It looks like it accepts zorkmids. "
	canFitObjThruOpening(obj) { return(obj.ofKind(Coin)); }
;

// The button.
// We have to declare dobjFor(Push) to override the default verify(), which
// would fail because we're a Fixture.  But we don't otherwise handle the
// action here.
// Also note that we check the state machine's state to indicate whether
// or not the button is lit.
class VendingMachineButton: Fixture '(ordinary) button' 'button'
	"It's an ordinary button.  It is
		<<((location.stateMachine.stateID != 'paid') ? 'not' : '')>>
		currently lit. "
	dobjFor(Push) { verify() {} }
;
