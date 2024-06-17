#pragma once

namespace lookup
{
	namespace form
	{
		using lookup_table_t = std::map<std::shared_ptr<record_t>, RE::TESRace*>;

#define AS_RACE(form) (skyrim_cast<RE::TESRace*>(form))
		static inline bool LookupRaces(lookup_table_t& table)
		{
			if (const auto data_handler = RE::TESDataHandler::GetSingleton(); data_handler != nullptr) {
				for (auto&& [id, form] : table) {
					if (const auto form_id = std::get_if<form_mod_pair_t>(&*id); form_id != nullptr) {
						if (form_id->first.has_value()) {
							if (form_id->second.has_value()) {
								form = AS_RACE(data_handler->LookupForm(form_id->first.value(), form_id->second.value()));
							} else {
								form = AS_RACE(RE::TESForm::LookupByID(form_id->first.value()));
							}
						}
					} else {
						form = AS_RACE(RE::TESForm::LookupByEditorID(std::get<std::string>(*id)));
					}
				}
				return true;
			}
			return false;
		}
#undef AS_RACE
	}  // namespace form
}  // namespace lookup