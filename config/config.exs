# Copyright 2023 Giuseppe De Palma, Matteo Trentin
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import Config

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id, :file, :line]

# --- Core Configs ---
config :core, Core.Repo, start_apps_before_migration: [:logger]
config :core, Core.SubjectsRepo, start_apps_before_migration: [:logger]

config :core, Core.Domain.Ports.Commands, adapter: Core.Adapters.Commands.Worker
config :core, Core.Domain.Ports.Cluster, adapter: Core.Adapters.Cluster
config :core, Core.Domain.Ports.Telemetry.Metrics, adapter: Core.Adapters.Telemetry.Metrics
config :core, Core.Domain.Ports.Connectors.Manager, adapter: Core.Adapters.Connectors.Manager
config :core, Core.Domain.Ports.DataSinks.Manager, adapter: Core.Adapters.DataSinks.Manager
config :core, Core.Domain.Ports.SubjectCache, adapter: Core.Adapters.Subjects.Cache

config :core,
  ecto_repos: [Core.Repo, Core.SubjectsRepo]

config :core,
  generators: [context_app: :core]

# Configures the endpoint, we need to listen to 0.0.0.0 because it's in a container
config :core, CoreWeb.Endpoint,
  url: [host: "0.0.0.0"],
  render_errors: [formats: [json: CoreWeb.ErrorJSON], layout: false],
  live_view: [signing_salt: "sRzweIOe"]

# pubsub_server: Core.PubSub,

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :core, CoreWeb.PromEx,
  disabled: false,
  manual_metrics_start_delay: :no_delay,
  drop_metrics_groups: [],
  metrics_server: :disabled,
  grafana: :disabled

config :core, Core.Seeds, path: "/tmp/funless/tokens"

# --- Worker Configs ---
config :worker, Worker.Domain.Ports.Runtime.Provisioner,
  adapter: Worker.Adapters.Runtime.Wasm.Provisioner

config :worker, Worker.Domain.Ports.Runtime.Runner, adapter: Worker.Adapters.Runtime.Wasm.Runner
config :worker, Worker.Domain.Ports.Runtime.Cleaner, adapter: Worker.Adapters.Runtime.Wasm.Cleaner

config :worker, Worker.Domain.Ports.Runtime.Supervisor,
  adapter: Worker.Adapters.Runtime.Wasm.Supervisor

config :worker, Worker.Domain.Ports.ResourceCache, adapter: Worker.Adapters.ResourceCache

config :os_mon,
  start_cpu_sup: true,
  start_memsup: true,
  start_disksup: false,
  start_os_sup: false,
  memsup_system_only: true

config :worker, Worker.PromEx,
  disabled: false,
  manual_metrics_start_delay: :no_delay,
  drop_metrics_groups: [],
  grafana: :disabled,
  metrics_server: [
    port: 4021,
    # This is an optional setting and will default to `"/metrics"`
    path: "/metrics",
    # This is an optional setting and will default to `:http`
    protocol: :http,
    # This is an optional setting and will default to `5`
    pool_size: 5,
    # This is an optional setting and will default to `[]`
    cowboy_opts: [],
    # This is an optional and will default to `:none`
    auth_strategy: :none
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
