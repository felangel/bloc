// Copyright 2019 Google LLC
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

#ifndef PLUGIN_REGISTRANT_
#define PLUGIN_REGISTRANT_

// TODO: Add a plugin registry interface rather than using the view controller
// directly.
#include <flutter/flutter_view_controller.h>

// Registers Flutter plugins.
void RegisterPlugins(flutter::FlutterViewController *registry);

#endif  // PLUGIN_REGISTRANT_
