# Copyright 2022 Giuseppe De Palma, Matteo Trentin
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

defmodule CoreWeb.FnController do
  use CoreWeb, :controller

  alias Core.Domain.Api.FunctionRepo
  alias Core.Domain.Api.Invoker

  action_fallback(CoreWeb.FnFallbackController)

  def invoke(conn, params) do
    with {:ok, %{result: res}} <- Invoker.invoke(params) do
      json(conn, %{result: res})
    end
  end

  def create(conn, %{"code" => %Plug.Upload{path: tmp_code_path}} = params) do
    func = params |> Map.put("code", File.read!(tmp_code_path))

    with {:ok, function_name} <- FunctionRepo.new(func) do
      conn
      |> put_status(:created)
      |> json(%{result: function_name})
    end
  end

  def create(_conn, _params) do
    {:error, :bad_params}
  end

  def delete(conn, params) do
    with {:ok, function_name} <- FunctionRepo.delete(params) do
      conn
      |> put_status(:ok)
      |> json(%{result: function_name})
    end
  end
end

defmodule CoreWeb.FnFallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """

  use Phoenix.Controller

  def call(conn, {:error, :bad_params}) do
    res = %{errors: %{detail: "Failed to perform operation: bad request"}}

    conn
    |> put_status(:bad_request)
    |> json(res)
  end

  def call(conn, {:error, :not_found}) do
    res = %{errors: %{detail: "Failed to invoke function: not found in given namespace"}}

    conn
    |> put_status(:not_found)
    |> json(res)
  end

  def call(conn, {:error, :no_workers}) do
    res = %{errors: %{detail: "Failed to invoke function: no worker available"}}

    conn
    |> put_status(:service_unavailable)
    |> json(res)
  end

  def call(conn, {:error, :worker_error}) do
    res = %{errors: %{detail: "Failed to invoke function: worker error"}}

    conn
    |> put_status(:internal_server_error)
    |> json(res)
  end

  def call(conn, {:error, {kind, reason}}) when kind == :bad_insert or kind == :bad_delete do
    action =
      if kind == :bad_insert do
        "create"
      else
        "delete"
      end

    message = "Failed to #{action} function: database error because #{reason}"
    res = %{errors: %{detail: message}}

    conn
    |> put_status(:service_unavailable)
    |> json(res)
  end
end
