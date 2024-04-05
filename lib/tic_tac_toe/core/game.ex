defmodule TicTacToe.Core.Game do
  alias __MODULE__
  alias TicTacToe.Core.Board

  @type t() :: %Game{
          board: Board.t(),
          current_player: player(),
          winner: nil | player()
        }

  @type player() :: :x | :o
  @type pos() :: {xy(), xy()}
  @type xy() :: 0 | 1 | 2

  @lines [
    # Horizontal
    [{0, 0}, {1, 0}, {2, 0}],
    [{0, 1}, {1, 1}, {2, 1}],
    [{0, 2}, {1, 2}, {2, 2}],
    # Vertical
    [{0, 0}, {0, 1}, {0, 2}],
    [{1, 0}, {1, 1}, {1, 2}],
    [{2, 0}, {2, 1}, {2, 2}],
    # Diagonal
    [{0, 0}, {1, 1}, {2, 2}],
    [{2, 0}, {1, 1}, {0, 2}]
  ]

  @enforce_keys [:board]
  defstruct [:board, :winner, current_player: :x]

  def new do
    %Game{
      board: Board.new()
    }
  end

  @spec winner(t()) :: nil | :x | :o
  def winner(%Game{} = game) do
    cond do
      win?(game, :x) ->
        :x

      win?(game, :o) ->
        :o

      :otherwise ->
        nil
    end
  end

  @spec win?(t(), player()) :: boolean()
  def win?(game, player) do
    @lines
    |> Enum.any?(&all_occupied?(game.board.grids, player, &1))
  end

  def all_occupied?(%{} = grids, player, line) do
    Enum.all?(line, fn {x, y} ->
      Map.get(grids, {x, y}) == player
    end)
  end

  @doc """
  Play at the given position as the current player.
  """
  @spec play(t(), pos()) :: t() | {:error, :invalid}
  def play(%Game{} = game, pos) do
    play(game, game.current_player, pos)
  end

  @doc """
  Play at the given position.
  """
  @spec play(t(), player(), pos()) :: t() | {:error, :invalid}
  def play(%Game{current_player: player} = game, player, {x, y}) when x in 0..2 and y in 0..2 do
    case game do
      %{board: %Board{grids: %{{^x, ^y} => p}}} when not is_nil(p) ->
        {:error, :invalid}

      %{board: %Board{grids: grids} = board} ->
        grids = Map.put(grids, {x, y}, player)

        %{game | board: %{board | grids: grids}}
        |> update_winner()
        |> next_player()
    end
  end

  def play(_, _, _) do
    {:error, :invalid}
  end

  defp update_winner(%Game{} = game) do
    Map.put(game, :winner, winner(game))
  end

  defp next_player(%Game{winner: nil, current_player: :x} = game) do
    %{game | current_player: :o}
  end

  defp next_player(%Game{winner: nil, current_player: :o} = game) do
    %{game | current_player: :x}
  end

  defp next_player(game) do
    game
  end

  @doc """
  Get the player at the given position.
  """
  @spec at(t(), pos()) :: player() | nil
  def at(%Game{board: %Board{grids: grids}}, {x, y}) do
    Map.get(grids, {x, y})
  end

  def game_over?(%Game{winner: winner}) when not is_nil(winner), do: true
  def game_over?(%Game{} = game), do: Board.full?(game.board)
  def game_over?(_), do: false
end
