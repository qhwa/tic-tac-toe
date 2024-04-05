defmodule TicTacToe.GameServer do
  alias TicTacToe.Core.Game

  use GenServer

  def start_link(opts) do
    {gen_server_opts, opts} = Keyword.split(opts, [:name])

    GenServer.start_link(__MODULE__, opts, gen_server_opts)
  end

  def play(server, pos),
    do: GenServer.call(server, {:play, pos})

  def play(server, player, pos),
    do: GenServer.call(server, {:play, player, pos})

  def get_game(server),
    do: GenServer.call(server, :get_game)

  def reset(server),
    do: GenServer.call(server, :reset)

  def undo(server),
    do: GenServer.call(server, :undo)

  @impl true
  def init(_opts) do
    {:ok, init_state()}
  end

  defp init_state do
    game = Game.new()
    %{game: game, histories: [game]}
  end

  @impl true
  def handle_call({:play, pos}, from, %{game: game} = state),
    do: handle_call({:play, game.current_player, pos}, from, state)

  def handle_call({:play, player, pos}, _from, %{game: %Game{} = game} = state) do
    case Game.play(game, player, pos) do
      %Game{} = new_game ->
        {:reply, :ok, %{state | game: new_game, histories: [new_game | state.histories]}}

      {:error, reason} ->
        {:reply, {:error, reason}, state}
    end
  end

  def handle_call(:get_game, _from, state) do
    {:reply, state.game, state}
  end

  def handle_call(:reset, _from, _state) do
    {:reply, :ok, init_state()}
  end

  def handle_call(:undo, _from, state) do
    case state do
      %{histories: [game]} ->
        {:reply, :ok, %{state | game: game}}

      %{histories: [_game, game | histories]} ->
        {:reply, :ok, %{state | game: game, histories: [game | histories]}}

      _ ->
        {:reply, {:error, :no_history}, state}
    end
  end
end
