;/ Decompiled by Champollion v1.3.2
PEX format v3.2 GameID: 1
Source   : HRI_Unwerepeople_Script.psc
Modified : 2019-12-26 00:56:32
Compiled : 2019-12-26 00:56:33
User     : maxim
Computer : CANOPUS
/;
ScriptName HRI_Unwerepeople_Script Extends activemagiceffect

;-- Variables ---------------------------------------
Spell RacialSpell

;-- Properties --------------------------------------
Spell Property HRI_Lycan_Spell_BeastForm Auto
Spell Property HRI_Lycan_Spell_BeastForm_Beastblood_Ab_Drawbacks Auto
Spell Property HRI_Lycan_Spell_BeastForm_Beastblood_Ab_HuntersMoon Auto
Spell Property HRI_Lycan_Spell_BeastForm_HardCastIndicator Auto
FormList Property HRI_Racial_FormList_Races Auto
FormList Property HRI_Racial_FormList_Racials Auto
Actor Property PlayerRef Auto

;-- Functions ---------------------------------------

; Skipped compiler generated GetState

; Skipped compiler generated GotoState

Event OnEffectStart(Actor akTarget, Actor akCaster)
  akTarget.AddSpell(HRI_Lycan_Spell_BeastForm_Beastblood_Ab_Drawbacks, False)
  akTarget.AddSpell(HRI_Lycan_Spell_BeastForm_Beastblood_Ab_HuntersMoon, False)
  Race TargetRace = akTarget.GetRace()
  ; Int RaceId = HRI_Racial_FormList_Races.Find(TargetRace as Form)
  ; If RaceId != -1
  ;   RacialSpell = HRI_Racial_FormList_Racials.GetAt(RaceId) as Spell
  ;   akTarget.AddSpell(RacialSpell, False)
  ; EndIf

  ; RCS
  Int RaceID = 0
  Int Size = HRI_Racial_FormList_Races.GetSize()
  While (RaceID < Size)
    If RaceCompatibility.GetIsRaceByProxy(TargetRace, HRI_Racial_FormList_Races.GetAt(RaceID) as Race)
      RacialSpell = HRI_Racial_FormList_Racials.GetAt(RaceId) as Spell
      akTarget.AddSpell(RacialSpell, False)
      Return
    Else
      RaceID += 1
    EndIf
  EndWhile
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
  akTarget.RemoveSpell(HRI_Lycan_Spell_BeastForm_Beastblood_Ab_Drawbacks)
  akTarget.RemoveSpell(HRI_Lycan_Spell_BeastForm_Beastblood_Ab_HuntersMoon)
  akTarget.RemoveSpell(RacialSpell)
EndEvent

Event OnSpellCast(Form akForm)
  If (akForm as Spell) as Bool && (akForm as Spell == HRI_Lycan_Spell_BeastForm)
    HRI_Lycan_Spell_BeastForm_HardCastIndicator.Cast(PlayerRef as ObjectReference, None)
  EndIf
EndEvent
