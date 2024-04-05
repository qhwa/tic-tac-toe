defmodule TicTacToe.GameServer do
  alias TicTacToe.Core.Game

  use GenServer

  def start_link(opts) do
    {gen_server_opts, opts} = Keyword.split(opts, [:name])

    GenServer.start_link(__MODULE__, opts, gen_server_opts)
  end

  def play(server, player, pos) do
    GenServer.call(server, {:play, player, pos})
  end

  def get_game(server) do
    GenServer.call(server, :get_game)
  end

  @impl true
  def init(_opts) do
    game = Game.new()

    {:ok, %{game: game}}
  end

  @impl true
  def handle_call(
        {:play, player, pos},
        from,
        %{game: %Game{winner: nil} = game} = state
      ) do
    case Game.play(game, player, pos) do
      %Game{winner: nil} = new_game ->
        {:reply, new_game, %{state | game: new_game}}

      %Game{} = new_game ->
        GenServer.reply(from, new_game)
        {:stop, state}

      {:error, reason} ->
        {:reply, {:error, reason}, state}
    end
  end

  def handle_call({:play, _, _}, _from, %{game: %Game{winner: winner}} = state)
      when not is_nil(winner) do
    {:reply, {:error, :game_is_over}, state}
  end

  def handle_call({:play, _, _}, _from, state) do
    {:reply, {:error, :not_in_turn}, state}
  end

  def handle_call(:get_game, _from, state) do
    {:reply, state.game, state}
  end
end
