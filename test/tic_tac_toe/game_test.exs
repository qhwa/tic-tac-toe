defmodule TicTacToe.GameTest do
  alias TicTacToe.Core.Game
  alias TicTacToe.Core.Board

  use ExUnit.Case

  import Game

  describe "winner/1" do
    test "works when the board is empty" do
      game = %Game{
        board: %Board{}
      }

      refute winner(game)
    end

    test "works when there's no winner" do
      game = %Game{
        board: %Board{
          grids: %{
            {1, 0} => :x,
            {0, 0} => :o
          }
        }
      }

      refute winner(game)
    end

    test "works when X wins" do
      game = %Game{
        board: %Board{
          grids: %{
            {0, 0} => :x,
            {1, 0} => :x,
            {2, 0} => :x
          }
        }
      }

      assert winner(game) == :x
    end

    test "works when O wins" do
      game = %Game{
        board: %Board{
          grids: %{
            {0, 0} => :o,
            {1, 0} => :o,
            {2, 0} => :o
          }
        }
      }

      assert winner(game) == :o
    end
  end

  describe "play/3" do
    test "works on first move" do
      game = %Game{
        board: %Board{}
      }

      assert %Game{
               board: %Board{
                 grids: %{{0, 0} => :x}
               }
             } = play(game, :x, {0, 0})
    end

    test "update winner" do
      game = %Game{
        board: %Board{
          grids: %{
            {0, 1} => :x,
            {0, 2} => :x
          }
        }
      }

      assert %Game{winner: :x} = play(game, :x, {0, 0})
    end

    test "returns `{:error, :invalid}` with invalid position" do
      assert {:error, :invalid} == play(%{}, :x, {-1, 0})
    end

    test "returns `{:error, :invalid}` when the target is already occupied" do
      game = %Game{
        board: %Board{
          grids: %{
            {0, 0} => :o
          }
        }
      }

      assert {:error, :invalid} == play(game, :x, {0, 0})
    end
  end
end
