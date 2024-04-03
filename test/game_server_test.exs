defmodule TicTacToe.GameServerTest do
  alias TicTacToe.Core.Game
  alias TicTacToe.GameServer

  use ExUnit.Case

  setup do
    {:ok, server} = GameServer.start_link([])

    on_exit(fn ->
      if Process.alive?(server) do
        GenServer.stop(server)
      end
    end)

    {:ok, server: server}
  end

  describe "get_game/1" do
    test "works", %{server: server} do
      assert Game.new() == GameServer.get_game(server)
    end
  end

  describe "play/3" do
    test "works", %{server: server} do
      assert %Game{} = GameServer.play(server, :x, {0, 0})
    end

    test "works with sequencies", %{server: server} do
      sequencies = [
        {:x, {0, 0}},
        {:o, {0, 1}},
        {:x, {1, 0}},
        {:o, {1, 1}},
        {:x, {2, 0}}
      ]

      games =
        for {player, pos} <- sequencies do
          assert %Game{} = GameServer.play(server, player, pos)
        end

      assert %Game{winner: :x} = List.last(games)
    end

    test "refuses when not in turn", %{server: server} do
      assert {:error, :not_in_turn} = GameServer.play(server, :o, {0, 0})
    end
  end
end
