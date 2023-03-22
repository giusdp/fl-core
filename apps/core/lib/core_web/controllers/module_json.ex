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

defmodule CoreWeb.ModuleJSON do
  alias Core.Schemas.Module
  alias CoreWeb.FunctionJSON

  @doc """
  Renders a list of module.
  """
  def index(%{module: module}) do
    %{data: for(module <- module, do: data(module))}
  end

  @doc """
  Renders a single module.
  """
  def show(%{module: module}) do
    %{data: data(module)}
  end

  def show_functions(%{module_name: name, functions: functions}) do
    %{data: %{name: name, functions: for(function <- functions, do: FunctionJSON.show(function))}}
  end

  defp data(%Module{} = module) do
    %{
      name: module.name
    }
  end
end
