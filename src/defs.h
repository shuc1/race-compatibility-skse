#pragma once

using form_mod_pair_t = std::pair<
	std::optional<RE::FormID>,    // formID
	std::optional<std::string>>;  // modName

using record_t = std::variant<
	form_mod_pair_t,   // formID~modName
	std::string>;  // editorID

namespace race_compatibility
{
	namespace ini
	{
		using path_t = std::shared_ptr<std::string>;
		using entry_t = std::vector<std::pair<std::unique_ptr<std::string>, std::shared_ptr<std::string>>>;  // key-value
		using configs_t = std::vector<std::pair<path_t, entry_t>>;
		constexpr auto SECTION_MIN_SIZE = 2;
		constexpr auto SECTION_MAX_SIZE = 5;
	}
}