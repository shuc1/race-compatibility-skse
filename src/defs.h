#pragma once

using form_mod_pair_t = std::pair<
	RE::FormID,                   // formID
	std::optional<std::string>>;  // modName

using record_t = std::variant<
	form_mod_pair_t,  // formID~modName
	std::string>;     // editorID