;/ Decompiled by Champollion v1.3.2
PEX format v3.2 GameID: 1
Source   : SCS_AbilityHolder_Script.psc
Modified : 2016-11-16 06:52:25
Compiled : 2016-11-17 06:31:43
User     : Maximilian
Computer : MARUNAE
/;
ScriptName SCS_AbilityHolder_Script Extends ActiveMagicEffect

;-- Variables ---------------------------------------

;-- Properties --------------------------------------
Race[] Property SCS_Race Auto
Spell[] Property SCS_RacialSpell Auto

;-- Functions ---------------------------------------

; Skipped compiler generated GetState

; Skipped compiler generated GotoState

Event OnEffectStart(Actor akTarget, Actor akCaster)
  Utility.Wait(1.0)
  ; Int RaceID = SCS_Race.find(akTarget.GetRace(), 0)
  ; If RaceID >= 0
  ;   akTarget.AddSpell(SCS_RacialSpell[RaceID], False)
  ; EndIf

  ; RCS
  Int RaceID = 0
  Race TargetRace = akTarget.GetRace()
  While (RaceID < SCS_Race.Length)
    If RaceCompatibility.GetIsRaceByProxy(TargetRace, SCS_Race[RaceID] as Race)
      akTarget.AddSpell(SCS_RacialSpell[RaceID], False)
      Return
    Else
      RaceID += 1
    EndIf
  EndWhile
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
  Int i = 0
  While i < SCS_RacialSpell.Length
    akTarget.RemoveSpell(SCS_RacialSpell[i])
    i += 1
  EndWhile
EndEvent
