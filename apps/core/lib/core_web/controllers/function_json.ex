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

defmodule CoreWeb.FunctionJSON do
  alias Core.Schemas.Function

  @doc """
  Renders a list of functions.
  """
  def index(%{functions: functions}) do
    %{data: for(function <- functions, do: data(function))}
  end

  @doc """
  Renders a single function.
  """
  # If we receive only the sinks
  def show(%{function: _function, sinks: [_ | _], events: []} = content) do
    %{
      data: data(content)
    }
  end

  # If we receive only the events
  def show(%{function: _function, events: [_ | _], sinks: []} = content) do
    %{
      data: data(content)
    }
  end

  # If we receive empty events and sinks
  def show(%{function: function, events: [], sinks: []}) do
    %{data: data(function)}
  end

  # If we receive both sinks and events
  def show(%{function: _function, events: _events, sinks: _sinks} = content) do
    %{
      data: data(content)
    }
  end

  # If we receive only the function
  def show(%{function: function}) do
    %{data: data(function)}
  end

  defp data(%Function{} = function) do
    %{
      name: function.name
    }
  end

  defp data(%{function: function, sinks: [_ | _] = sinks, events: []}) do
    successful_sinks = sinks |> Enum.count(fn e -> e == :ok end)
    failed_sinks = length(sinks) - successful_sinks

    %{
      name: function.name,
      sinks: for(sink <- sinks, do: status_data(sink)),
      sinks_metadata: %{
        successful: successful_sinks,
        failed: failed_sinks,
        total: length(sinks)
      }
    }
  end

  defp data(%{function: function, events: [_ | _] = events, sinks: []}) do
    successful_events = events |> Enum.count(fn e -> e == :ok end)
    failed_events = length(events) - successful_events

    %{
      name: function.name,
      events: for(event <- events, do: status_data(event)),
      events_metadata: %{
        successful: successful_events,
        failed: failed_events,
        total: length(events)
      }
    }
  end

  defp data(%{function: function, events: [_ | _] = events, sinks: [_ | _] = sinks}) do
    Map.merge(
      data(%{function: function, events: events}),
      data(%{function: function, sinks: sinks})
    )
  end

  defp status_data(:ok), do: %{status: "ok"}
  defp status_data({:error, err}), do: %{status: "error", message: "#{inspect(err)}"}
end
