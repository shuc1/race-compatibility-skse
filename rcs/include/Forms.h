#pragma once

namespace rcs::form
{
    template <typename T>
    struct FormCache
    {
        RE::TESDataHandler*                    dataHandler{ RE::TESDataHandler::GetSingleton() };
        std::map<std::string, T*, std::less<>> map;
    };

    template <typename T>
    static T* LookupCachedForm(const std::string_view form, FormCache<T>& cache)
    {
        if (const auto it = cache.map.find(form); it != cache.map.end()) {
            return it->second;
        }

        auto t = [&] {
            // do not support lookup by id, "0x800" will be treated as editor id
            // // BSFixedString(std::string_view) will copy the original string other than the span
            // // must alloc a new string before passing to LookupByEditorID/LookupForm

            // "OhmesRaht.esp|800" or "OhmesRaht.esp|0x800"
            if (const auto splitLoc = form.find('|'); splitLoc != std::string::npos) {
                const auto namePart = form.substr(0, splitLoc);
                auto       idPart = form.substr(splitLoc + 1);
                if (idPart[0] == '0' && (idPart[1] == 'x' || idPart[1] == 'X')) {
                    idPart = idPart.substr(2);
                }
                RE::FormID id{};
                std::from_chars(idPart.data(), idPart.data() + idPart.size(), id);
                return cache.dataHandler->template LookupForm<T>(id, std::string{ namePart });
            }
            // "OhmesRahtRace"
            return RE::TESForm::LookupByEditorID<T>(std::string{ form });
        }();

        cache.map.emplace(form, t);
        return t;
    }
}  // namespace rcs::form