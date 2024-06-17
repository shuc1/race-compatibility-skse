#pragma once

namespace race_compatibility
{
	namespace ini
	{
		static inline std::vector<std::string> GetConfigFiles()
		{
			return clib_util::distribution::get_configs(R"(Data\)", "_RCS"sv);
		}

		bool ParseConfigs(const std::vector<std::string>& files);
	}
}