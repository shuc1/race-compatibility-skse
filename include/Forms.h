#pragma once

namespace rcs
{
	namespace form
	{
		template <typename T>
		using FormCache = std::map<std::string, T*, std::less<>>;

		template <typename T>
		static T* LookupCachedForm(const std::string_view form_str, FormCache<T>& cache)
		{
			if (const auto it = cache.find(form_str); it != cache.end()) {
				return it->second;
			}

			T* t;
			// do not support lookup by id, "0x800" will be treated as editor id
			// // BSFixedString(std::string_view) will copy the original string other than the span
			// // must alloc a new string before passing to LookupByEditorID/LookupForm
			if (auto split_loc = form_str.find('|');
				split_loc != std::string::npos) {  // "OhmesRaht.esp|800" or "OhmesRaht.esp|0x800"
				const auto data_handler = RE::TESDataHandler::GetSingleton();
				t = data_handler ?
				        data_handler->LookupForm<T>(
							static_cast<RE::FormID>(std::stoul(std::string{ form_str.substr(split_loc + 1) }, nullptr, 16)),
							std::string(form_str.substr(0, split_loc))) :
				        nullptr;
			} else {  // "OhemsRahtRace"
				t = RE::TESForm::LookupByEditorID<T>(std::string(form_str));
			}
			cache.emplace(form_str, t);
			return t;
		}
	}  // namespace form
}  // namespace rcs