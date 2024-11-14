#pragma once

namespace lookup
{
	namespace form
	{
		using race_lookup_table_t = std::map<std::shared_ptr<record_t>, RE::TESRace*>;

		static inline bool LookupRaces(race_lookup_table_t& table)
		{
			if (const auto data_handler = RE::TESDataHandler::GetSingleton(); data_handler != nullptr) {
				for (auto&& [id, form] : table) {
					if (const auto form_id = std::get_if<form_mod_pair_t>(&*id); form_id != nullptr) {
						if (form_id->second.has_value()) {
							form = data_handler->LookupForm(form_id->first, form_id->second.value())->As<RE::TESRace>();
						} else {
							form = RE::TESForm::LookupByID<RE::TESRace>(form_id->first);
						}
					} else {
						form = RE::TESForm::LookupByEditorID<RE::TESRace>(std::get<std::string>(*id));
					}
				}
				return true;
			}
			return false;
		}

		static inline RE::BGSListForm* LookupFormIdLists(const std::string_view& editor_id)
		{
			return RE::TESForm::LookupByEditorID<RE::BGSListForm>(editor_id);
		}
	}  // namespace form
}  // namespace lookup