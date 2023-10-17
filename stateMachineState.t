#charset "us-ascii"
//
// stateMachineState.t
//
#include <adv3.h>
#include <en_us.h>

class State: RuleUser
	id = nil

	defaultStateID = nil
	nextStateID = nil

	fsmRulebook = perInstance(new LookupTable())

	disableStateRulebooks() {
		rulebook.keysToList.forEach(function(id) {
			disableStateRulebookByID(id);
		});
	}

	enableStateRulebooks() {
		fsmRulebook.keysToList.forEach(function(id) {
			enableStateRulebookByID(id);
		});
	}

	disableStateRulebookByID(id) {
		local obj;

		if((obj = rulebook[id]) == nil)
			return(nil);

		return(disableStateRulebook(obj));
	}

	enableStateRulebookByID(id) {
		local obj;

		if((obj = fsmRulebook[id]) == nil)
			return(nil);

		return(enableStateRulebook(obj));
	}

	disableStateRulebook(obj) {
		if((obj == nil) || !obj.ofKind(State))
			return(nil);
		fsmRulebook[obj.id] = obj;
		return(removeRulebook(obj));
	}
	
	enableStateRulebook(obj) {
		if((obj == nil) || !obj.ofKind(State))
			return(nil);
		fsmRulebook.removeElement(obj);

		return(addRulebook(obj));
	}

	stateTransition(id) {
		local obj;

		if(owner == nil)
			return;

		if((obj = getRulebook(id)) == nil)
			return;

		owner.stateTransition(self, obj.nextStateID);
	}

	rulebookMatchCallback(id) {
		inherited(id);

		stateTransition(id);
	}
;
