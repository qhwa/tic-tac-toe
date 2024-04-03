defmodule TicTacToe.Core.Game do
  alias __MODULE__
  alias TicTacToe.Core.Board

  @type t() :: %Game{
          board: Board.t(),
          winner: nil | player()
        }

  @type player() :: :x | :o
  @type pos() :: {xy(), xy()}
  @type xy() :: 0 | 1 | 2

  @lines [
    # Horizontal
    [{0, 0}, {1, 0}, {2, 0}],
    [{0, 1}, {1, 2}, {2, 3}],
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
  defstruct [:board, :winner]

  def new do
    %Game{
      board: Board.new(),
      winner: nil
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

  @spec play(t(), player(), pos()) :: t() | {:error, :invalid}
  def play(%Game{} = game, player, {x, y}) when x in 0..2 and y in 0..2 do
    case game do
      %{board: %Board{grids: %{{^x, ^y} => p}}} when not is_nil(p) ->
        {:error, :invalid}

      %{board: %Board{grids: grids} = board} ->
        grids = Map.put(grids, {x, y}, player)

        %{game | board: %{board | grids: grids}}
        |> update_winner()
    end
  end

  def play(_, _, _) do
    {:error, :invalid}
  end

  defp update_winner(%Game{} = game) do
    Map.put(game, :winner, winner(game))
  end
end
