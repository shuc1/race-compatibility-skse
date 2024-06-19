#pragma once

namespace lookup
{
	namespace form
	{
		using race_lookup_table_t = std::map<std::shared_ptr<record_t>, RE::TESRace*>;

		static inline bool LookupRaces(race_lookup_table_t& table)
		{
#define AS_RACE(a_form) (skyrim_cast<RE::TESRace*>(a_form))
			if (const auto data_handler = RE::TESDataHandler::GetSingleton(); data_handler != nullptr) {
				for (auto&& [id, form] : table) {
					if (const auto form_id = std::get_if<form_mod_pair_t>(&*id); form_id != nullptr) {
						if (form_id->second.has_value()) {
							form = AS_RACE(data_handler->LookupForm(form_id->first, form_id->second.value()));
						} else {
							form = AS_RACE(RE::TESForm::LookupByID(form_id->first));
						}
					} else {
						form = AS_RACE(RE::TESForm::LookupByEditorID(std::get<std::string>(*id)));
					}
				}
				return true;
			}
			return false;
#undef AS_RACE
		}

		static inline RE::BGSListForm* LookupFormIdLists(const std::string_view& editor_id)
#define AS_FORM_ID_LIST(a_form) (skyrim_cast<RE::BGSListForm*>(a_form))
		{
			return AS_FORM_ID_LIST(RE::TESForm::LookupByEditorID(editor_id));
#undef AS_FORM_ID_LIST
		}
	}  // namespace form
}  // namespace lookup