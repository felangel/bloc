// Copyright 2018 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
  @IBOutlet weak var window: NSWindow!
  @IBOutlet weak var applicationMenu: NSMenu!

  func applicationWillFinishLaunching(_ notification: Notification) {
    // Update UI elements to match the application name.
    // TODO: Move this logic to a Flutter framework application delegate.
    // See https://github.com/flutter/flutter/issues/32419.
    let appName = applicationName()
    window.title = appName
    for menuItem in applicationMenu.items {
      menuItem.title = menuItem.title.replacingOccurrences(of: "APP_NAME", with: appName)
    }
  }

  func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  /**
   * Returns the name of the application as set in the Info.plist
   */
  private func applicationName() -> String {
    var applicationName: String? = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName")
      as? String
    if applicationName == nil {
      applicationName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
    }
    return applicationName!
  }
}
