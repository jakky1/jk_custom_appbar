#include "include/jk_custom_appbar/jk_custom_appbar_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "jk_custom_appbar_plugin.h"

void JkCustomAppbarPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  jk_custom_appbar::JkCustomAppbarPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
