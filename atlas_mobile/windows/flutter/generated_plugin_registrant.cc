//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <flutter_localization/flutter_localization_plugin_c_api.h>
#include <flutter_tts/flutter_tts_plugin.h>
#include <geolocator_windows/geolocator_windows.h>
#include <url_launcher_windows/url_launcher_windows.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  FlutterLocalizationPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FlutterLocalizationPluginCApi"));
  FlutterTtsPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FlutterTtsPlugin"));
  GeolocatorWindowsRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("GeolocatorWindows"));
  UrlLauncherWindowsRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("UrlLauncherWindows"));
}
