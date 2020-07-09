defmodule PhoenixCms.Repo.Http do
  @moduledoc false

  alias __MODULE__.Decoder
  alias PhoenixCms.Repo
  alias Services.Airtable

  @behaviour Repo

  @impl Repo
  def all(table) do
    case Airtable.all(table) do
      {:ok, %{"records" => records}} ->
        {:ok, Decoder.decode(records)}

      other ->
        other
    end
  end

  @impl Repo
  def get(table, id) do
    case Airtable.get(table, id) do
      {:ok, response} ->
        {:ok, Decoder.decode(response)}

      other ->
        other
    end
  end
end
