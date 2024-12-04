Scriptname RaceCompatibility Hidden

; return: if akRace is managed by RCS as a vampire race, return the correspond normal race; else return None
Race Function GetRaceByVampireRace(Race akRace) global native

; return: if akRace is managed by RCS as a normal race, return the correspond vampire race; else return None
Race Function GetVampireRaceByRace(Race akRace) global native

; return: if akActorRace equals akRace, OR proxies for akActorRace contains akRace, return true, else false
; a true returnval case:
; RCS = akActorRace|akActorRaceVampire|akRace|akRaceVampire
; GetIsRaceByProxy(akActorRace, akRace) -> True
Bool Function GetIsRaceByProxy(Race akActorRace, Race akRace) global native

; return: return head part flag as 'A', 'E', 'H', 'K' or 'O' (char as int)
; A: 65, E: 69, H: 72, K: 75, O: 79
; an example:
; RCS = akRace|akRaceVampire|||H
; GetHeadPartFlagByRace(akRace) -> 72 (0x48, for 'H')
; TODO: refactor
Int Function GetHeadPartFlagByRace(Race akRace) global native

; TODO: add removeProxy, addProxy functions