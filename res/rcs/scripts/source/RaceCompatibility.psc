Scriptname RaceCompatibility Hidden

; return: if akRace is managed by RCS as a vampire race, return the correspond normal race; else return None
Race Function GetRaceByVampireRace(Race akRace) global native

; return: if akRace is managed by RCS as a normal race, return the correspond vampire race; else return None
Race Function GetVampireRaceByRace(Race akRace) global native

; return: if akSourceRace equals akTargetRace, OR proxies for akSourceRace contains akTargetRace, return true, else false
Bool Function GetIsRaceByProxy(Race akSourceRace, Race akTargetRace) global native

; return: return head part type id(from 0 ot 12)
; None: 0, Argonian: 1,
; Elf: 2, Dark Elf: 3, High Elf: 4, Wood Elf: 5
; Human: 6, Breton: 7, Imperial: 8, Nord: 9, Redguard: 10
; Khajiit: 11, Orc: 12
; CAUTION: Human means general human type
; CAUTION: If head part of a race is Breton type, it does NOT mean it's Human type!
Int Function GetHeadPartTypeByRace(Race akRace) global native
