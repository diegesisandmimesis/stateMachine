#charset "us-ascii"
//
// stateMachineGraph.t
//
#include <adv3.h>
#include <en_us.h>

#include "stateMachine.h"

#ifdef STATE_MACHINE_GRAPH

stateMachineGraphPreinit: PreinitObject
	execute() {
		forEachInstance(StateMachine, function(o) {
			o.initializeStateMachineGraph();
		});
	}
;

class StateMachineGraph: SimpleGraph
;

modify State
	addRulebook(obj) {
		local g;

		if(inherited(obj) != true)
			return(nil);

		if(obj.ofKind(NoTransition))
			return(true);

		if(stateMachine == nil)
			stateMachine = location;

		if(stateMachine == nil)
			return(nil);

		if((g = stateMachine.getStateMachineGraph()) == nil)
			return(nil);

		g.addEdge(id, obj.toState);

		return(true);
	}
;

modify StateMachine
	stateMachineGraph = nil

	addState(obj) {
		local g;

		if(inherited(obj) != true)
			return(nil);

		if((g = getStateMachineGraph()) == nil)
			return(nil);
		g.addVertex(obj.id);

		return(true);
	}

	initializeStateMachineGraph() {
		stateMachineGraph = new SimpleGraphDirected();
	}
	getStateMachineGraph() {
		if(stateMachineGraph == nil)
			initializeStateMachineGraph();
		return(stateMachineGraph);
	}
;

#endif // STATE_MACHINE_GRAPH
