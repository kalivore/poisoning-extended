Scriptname _BB_TestEffectScript extends ActiveMagicEffect  

Keyword Property MagicAlchHarmful Auto
Keyword Property VendorItemPoison Auto

Actor Myself

Event OnEffectStart(Actor akTarget, Actor akCaster)
	Myself = akTarget
	string msg = "Test Poison Magic effect was started on " + Myself.GetLeveledActorBase().GetName() + " by " + akCaster.GetLeveledActorBase().GetName()
	Debug.Notification(msg)
	Debug.Trace(msg)
endEvent

Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
	if (akSource.HasKeyword(MagicAlchHarmful) || akSource.HasKeyword(VendorItemPoison))
		string msg = Myself.GetLeveledActorBase().GetName() + " hit by " + (akAggressor as Actor).GetLeveledActorBase().GetName() + " with " + akSource.GetName()
		Debug.Trace(msg)
	endIf
endEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
	string msg = "Test Poison Magic effect finished on " + akTarget.GetLeveledActorBase().GetName() + " from " + akCaster.GetLeveledActorBase().GetName()
	Debug.Notification(msg)
	Debug.Trace(msg)
endEvent

