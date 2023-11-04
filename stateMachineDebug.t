#charset "us-ascii"
//
// stateMachineDebug.t
//
//	Debugging stuff.
//
//	For readibility all the logging stuff is tagged.  The tags are:
//
//		transition		state transitions
//
//	To enable debugging output for a tag, use syslog.enable() with
//	the tag as the argument.  For example:
//
//		syslog.enable('transition');
//
#include <adv3.h>
#include <en_us.h>

#include "stateMachine.h"

#ifdef SYSLOG

DefineSystemAction(DebugStateMachines)
	execSystemAction() {
		gDebugStateMachines();
		defaultReport('Done. ');
	}
;
VerbRule(DebugStateMachines)
	'debugstatemachines' : DebugStateMachinesAction
	verbPhrase = 'debug/debugging'
;

modify StateMachine
	queueStateTransition(oldState, newStateID) {
		_debug('queueStateTransition:
			<<(oldState ? oldState.id : 'nil')>>
			to <<newStateID>>', 'transition');
		return(inherited(oldState, newStateID));
	}

	stateTransition() {
		_debug('stateTransition(): <<toString(stateID)>> to
                        <<toString(_nextStateID)>>', 'transition');
		inherited();
	}

	debugStateMachine() {
		local l;

		_debug('State Machine Debugging Data:');
		_debug('stateID = <<toString(stateID)>>');

		l = fsmState.keysToList();
		_debug('number of states = <<toString(l.length)>>');
		l.forEach(function(o) {
			_debug('state <<toString(o)>>:');
			fsmState[o].debugStateMachineState();
		});
	}
;

modify State
	debugStateMachineState() {
		local l;

		l = rulebook.keysToList();
		_debug('\tnumber of enabled transitions =
			<<toString(l.length)>>');
		l.forEach(function(o) {
			_debug('\t\ttransition <<toString(o)>>:');
			rulebook[o].debugStateMachineTransition();
		});
		l = disabledRulebook.keysToList();
		_debug('\tnumber of disabled transitions =
			<<toString(l.length)>>');
		l.forEach(function(o) {
			_debug('\t\ttransition <<toString(o)>>:');
			disabledRulebook[o].debugStateMachineTransition();
		});
	}
;

modify Transition
	debugStateMachineTransition() {
		_debug('\t\t\tnumber of rules: <<toString(ruleList.length)>>');
		ruleList.forEach(function(o) {
			_debug('\t\t\t\t<<toString(o)>>');
		});
	}
;

#endif // SYSLOG
