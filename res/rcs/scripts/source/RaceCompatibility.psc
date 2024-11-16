Scriptname RaceCompatibility Hidden

; return: if aVampireRace is managed by RCS as a vampire race, return the correspond normal race; else return None
Race Function GetRaceByVampireRace(Race aVampireRace) global native

; return: if aRace is managed by RCS as a normal race, return the correspond vampire race; else return None
Race Function GetVampireRaceByRace(Race aRace) global native