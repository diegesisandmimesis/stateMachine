//
// stateMachine.h
//

// Uncomment to enable debugging options.
//#define __DEBUG_STATE_MACHINE

#include "ruleEngine.h"
#ifndef RULE_ENGINE_H
#error "This module requires the ruleEngine module."
#error "https://github.com/diegesisandmimesis/ruleEngine"
#error "It should be in the same parent directory as this module.  So if"
#error "stateMachine is in /home/user/tads/stateMachine, then"
#error "ruleEngine should be in /home/user/tads/ruleEngine ."
#endif // RULE_ENGINE_H

State template 'id';
Transition template 'id' 'toState' "transitionAction"?;
NoTransition template 'id'? "transitionAction"?;

#ifdef SYSLOG
#define gDebugStateMachines() { \
	forEachInstance(StateMachine, function(o) { o.debugStateMachine(); }); }
#else // SYSLOG
#define gDebugStateMachines() {}
#endif // SYSLOG

#define STATE_MACHINE_H
