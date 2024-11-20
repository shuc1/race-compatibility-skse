Scriptname NNLunarTransform extends Quest
{Main Cycle Script for Hunger & Lunar Transformation}

NNMCM Property MCM Auto
PlayerWerewolfChangeScript Property WWQ Auto
Keyword Property WerebeastKeyword Auto

GlobalVariable Property GameHour Auto
GlobalVariable Property GameDaysPassed Auto

GlobalVariable Property HungerLevel Auto
GlobalVariable Property HungerFeedings Auto
GlobalVariable Property HungerLastFeed Auto

Message[] Property MoonPhaseNotifies Auto
Message Property LunarTransformNotify Auto
ImageSpaceModifier Property LunarTransformFlashImod Auto
ImageSpaceModifier[] Property LunarTransformWarnImod Auto
Spell Property LunarTransformSpell Auto

Actor[] Property SpiritPrey Auto
GlobalVariable Property WolfKillCount Auto

bool Property LunarTransform Auto Hidden
bool IsPreySpawned = false

Race Function GetWerebearRace() global
  return Game.GetForm(0x0401E17B) as Race
EndFunction

Event OnUpdateGameTime()
  If(Game.GetPlayer().HasSpell(MCM.WerewolfImmunity) == false)
    ; Nothing to do if the Player isnt a Werebeast
    ; Update will be re-registered after transforming to a WW once
    return
  EndIf

  float g = GameHour.Value
  Debug.Trace("NIGHTMARE NIGHT - Update Game Time at = " + g)

  If(g >= 20.00 || g < 1.00)
    float moonphase = GetMoonphase()
    int moonphaseINT = moonphase as int
    If(moonphase < 1 && !(moonphase > 0 && moonphase < 0.5))
      ; Fullmoon 1st or 3rd day
      moonphase = 8
    EndIf
    If(MCM.bLunarEnable)
      MoonPhaseNotifies[moonphaseINT].Show()
      If(Utility.RandomFloat(0, 99.9) < MCM.LunarChances[Math.Floor(moonphase)])
        ; Debug.Trace("NIGHTMARE NIGHT - Lunar Transform Trigger with Moon Phase = " + moonphase)
        ; Dont transform if were already shifted..
        If(Game.GetPlayer().HasKeyword(WerebeastKeyword))
          WWQ.ExtendToDawn()
          GoToState("SpawnSpirits")
        Else
          GoToState("Transform") ; Spawns Spirit Prey
        EndIf
        return
      EndIf
    EndIf
    If(!IsPreySpawned)
      GoToState("SpawnSpirits")
    EndIf
  ElseIf(IsPreySpawned)
    DespawnSpiritPrey()
  EndIf

  CreateNextUpdate()
EndEvent

Function CreateNextUpdate()
  float g = GameHour.Value
  float update
  If(g < 5.0)
    update = 5.0 - g ; This days 5.00
  ElseIf(g > 20)
    update = 29.0 - g ; Following days 5.00
  Else
    update = 20.0 - g ; This days 20.00
  EndIf
  If(update < 0.025)
    update = 0.025
  EndIf
  RegisterForSingleUpdateGameTime(update)
EndFunction

; Assume this to only be called between 20.00 and 1.00
float Function TimeTill21()
  float gh = GameHour.Value
  If(gh < 21.00 && gh > 1.0)
    float till_21 = 21.00 - gh
    If(till_21 < 0.025)
      till_21 = 0.025
    EndIf
    ; Debug.Trace("NIGHTMARE NIGHT - GameHour = " + gh + "TimeTill21 = " + till_21)
    return till_21
  Else ; 21.00 and 1.00
    ; Debug.Trace("NIGHTMARE NIGHT - GameHour = " + gh + "TimeTill21 = 0.025")
    return 0.025
  EndIf
EndFunction

State SpawnSpirits
  Event OnBeginState()
    ; Spirits spawn at 21.00
    RegisterForSingleUpdateGameTime(TimeTill21())
  EndEvent

  Event OnUpdateGameTime()
    float h = GameHour.Value
    If(h <= 1 || h >= 21) ; Check time window, in case player waited
      SpawnSpiritPrey()
    EndIf
    GoToState("")
    CreateNextUpdate()
  EndEvent
EndState

State Transform
  Event OnBeginState()
    ; Called between 20.00 and 1.00
    float t = TimeTill21()
    If(t > 0.025) ; Somewhere 20.xx; Randomize & shift interval
      t = Utility.RandomFloat(0.025, t) + 0.75 ; ..between 20.45 & 21.45
    EndIf
    ; Debug.Trace("NIGHTMARE NIGHT - Transformation in = " + t)
    RegisterForSingleUpdateGameTime(t)
  EndEvent

  Event OnUpdateGameTime()
    float h = GameHour.Value
    If(h > 2 && h < 20) ; Player waited past time window
      GoToState("")
      CreateNextUpdate()
      return
    EndIf
    SpawnSpiritPrey()
    If(WWQ.IsRunning())
      WWQ.ExtendToDawn()
      return
    EndIf
    LunarTransform = true
    int imod = 2 ; HungerLevel.GetValueInt()
    ;/ All Imods have a Rampup time which is dependend on the Hunger Stage which colors the Screen dark red over time
      After the Initial Rampup time theres a 1.5s delay for a quick Flash which stays active for 0.8. During this time
      the color will fade into a greyish black. Over the following 2.5 seconds the Imod will fade out and dispel
      (E.g. 10 Seconds => 0s -> [RAMP UP] -> 5.2s -> [+1.5s] -> 6.7s -> [+0.8s] -> 7.5s -> [+2.5s] -> 10s)
    /;
    LunarTransformWarnImod[imod].Apply()
    float time
    If(imod == 0) ; - ; 5.2 (Total Dur: 10)
      time = 4.5
    ElseIf(imod == 1) ; 13.2 (Total Dur: 18)
      time = 12.5
    ElseIf(imod == 2) ; 21.2 (Total Dur: 26)
      time = 20.5
    Else ; ---------- ; 28.2 (Total Dur: 33)
      time = 27.5
    EndIf
    Utility.Wait(time) ; Waiting the RampUp Time
    LunarTransformNotify.Show()
    LunarTransformSpell.Cast(Game.GetPlayer())
    ; Next Update schedule is made by the WW Quest
    GoToState("")
  EndEvent
EndState

;/ =======================================
  Spirit Prey
  Those are Bosses that spawn during the Night and vanish again at Dawn. Each of them grants
  the Player a special Perk. They can be hunted in either Beast or Human Form (though they are have
  fairly high stats which might make them feel unfair outside of beast form \o/)
  • Skeever: Scent of Blood differs between Friendly & Hostile
  • Deer: +10 Movement Speed out of Beast Form
  • Wolf: Howl of Pack inherits Stats from Player
  • Sabrecat: +15 Claw Damage, heal for 15 Hp with each Hit
  • Draugr: Howl of Terror +20 Magnitude & stops affected Enemies from moving until hit once
  • Dragon: Reduce Howl Cooldowns by 20%
======================================= /;
GlobalVariable Property SpiritWolfKills Auto

Function SpawnSpiritPrey()
  If(IsPreySpawned || MCM.bDisableSpirit)
    return
  EndIf
  IsPreySpawned = true
  int n = 0
  While(n < SpiritPrey.Length)
    If(!SpiritPrey[n].IsDead())
      SpiritPrey[n].Enable()
    ElseIf(n == 2 && WolfKillCount.Value < 32)
      SpiritPrey[n].Reset()
      WolfKillCount.Value = 0
    EndIf
    n += 1
  EndWhile
EndFunction

Function DespawnSpiritPrey()
  int i = 0
  While(i < SpiritPrey.Length)
    SpiritPrey[i].Disable(true)
    i += 1
  EndWhile
  IsPreySpawned = false
EndFunction

bool wolfProcessing = false
int Function HandleWolfTakedown()
  While(wolfProcessing)
    Utility.Wait(0.2)
  EndWhile
  wolfProcessing = true
  int ret = SpiritWolfKills.GetValueInt() + 1
  SpiritWolfKills.SetValue(ret)
  wolfProcessing = false
  return ret
EndFunction

;/ =======================================
  The Lunar Cycle
  - A Lunar Cycle is divided in 8 Phases, all lasting 3 Days each (-> 24 Days for one entire Phase)
  - The first day in a new Game is the 3rd day of Waxing Gibbous (the next night will be a Fragmented Full Moon)
  - Masser isnt tied to Gamedays, manipulating the Time (Date) is not affecting its phases
  - In Skyrim, Secunda is mimicing Masser and can be ignored for any Interaction

  Defining IDs:
  0 = Full Moon
  1 = Waning Gibbous
  2 = Second Quarter
  3 = Waning Cresent
  4 = New Moon
  5 = Waxing Cresent
  6 = First Quarter
  7 = Waxing Gibbous
======================================= /;
float Function GetMoonPhase()
  int daysPassed = GameDaysPassed.GetValueInt()
  ; If we are before 12.00, calcuate Moonphase based on the previous Night
  If(GameHour.Value < 12)
    daysPassed -= 1
  EndIf
  return ((daysPassed % 24) as float) / 3.0
EndFunction

;/ =======================================
  Radiant Encounter Attacks from the Silverhand (IDEA: Add Vigilant Hunters?)
  Number of Silverhand Encounters will increase as the Player progresses through
  the Companions Questline. Once Kodlak dies, Encounters will be slightly less
======================================= /;
GlobalVariable Property NNWENextAttack Auto
Quest Property C04 Auto
Quest Property C06 Auto
Function SetNNWENextAttack()
	int DaysUntilNextAttack = 5 ;default value
  If(C06.IsCompleted())
    DaysUntilNextAttack += 1
  ElseIf(C04.IsCompleted())
    DaysUntilNextAttack -= 2
  EndIf
	NNWENextAttack.SetValue(GameDaysPassed.GetValue() + DaysUntilNextAttack)
	Debug.Trace(self + "SetNNWENextAttack() NNWENextAttack = " + NNWENextAttack.GetValue())
EndFunction
