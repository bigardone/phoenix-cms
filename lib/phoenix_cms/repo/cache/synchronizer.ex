defmodule PhoenixCms.Repo.Cache.Synchronizer do
  @moduledoc """
  Syncs periodically the cache with Airtable
  """

  require Logger

  alias PhoenixCms.Repo.Cache

  use GenServer

  @refresh_time :timer.seconds(1)

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  @impl GenServer
  def init(opts) do
    cache = Keyword.fetch!(opts, :cache)

    send(self(), :sync)

    {:ok, cache}
  end

  @impl GenServer
  def handle_info(:sync, cache) do
    case apply(cache, :fetch_fn, []).() do
      {:ok, items} ->
        Cache.set_all(cache, items)
        schedule(cache)
        {:noreply, cache}

      _ ->
        schedule(cache)
        {:noreply, cache}
    end
  end

  defp schedule(cache) do
    Logger.debug("#{cache} scheduling...")

    Process.send_after(self(), :sync, @refresh_time)
  end
end
