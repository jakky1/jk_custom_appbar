#ifndef FLUTTER_PLUGIN_JK_CUSTOM_APPBAR_PLUGIN_H_
#define FLUTTER_PLUGIN_JK_CUSTOM_APPBAR_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace jk_custom_appbar {

class JkCustomAppbarPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  JkCustomAppbarPlugin();

  virtual ~JkCustomAppbarPlugin();

  // Disallow copy and assign.
  JkCustomAppbarPlugin(const JkCustomAppbarPlugin&) = delete;
  JkCustomAppbarPlugin& operator=(const JkCustomAppbarPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace jk_custom_appbar

#endif  // FLUTTER_PLUGIN_JK_CUSTOM_APPBAR_PLUGIN_H_
