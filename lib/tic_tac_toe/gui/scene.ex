defmodule TicTacToe.Gui.Scene do
  alias Scenic.Graph
  alias TicTacToe.Core.Game
  alias TicTacToe.Core.Board

  use Scenic.Scene

  import Scenic.Primitives

  @grid_size 100

  @impl true
  def init(scene, _param, _opts) do
    game =
      Game.new()
      |> Game.play(:x, {1, 1})
      |> Game.play(:o, {0, 0})
      |> Game.play(:x, {2, 2})
      |> Game.play(:o, {0, 2})
      |> Game.play(:x, {0, 1})
      |> Game.play(:o, {1, 0})
      |> Game.play(:x, {2, 1})

    scene =
      scene
      |> push_graph(build_graph(game))

    {:ok, scene}
  end

  defp build_graph(%Game{} = game) do
    Graph.build()
    |> text("Tic Tac Toe v1.0", font_size: 20, translate: {0, 20})
    |> then(fn graph ->
      case game do
        %{winner: winner} when winner != nil ->
          graph
          |> text("Winner: #{winner |> to_string() |> String.upcase()}",
            font_size: 20,
            translate: {200, 20}
          )

        %{} ->
          graph
          |> text("Player: #{game.current_player |> to_string() |> String.upcase()}",
            font_size: 20,
            translate: {200, 20}
          )
      end
    end)
    |> group(
      fn
        graph ->
          graph
          |> build_board(game)
          |> build_cells(game)
      end,
      translate: {5, 50}
    )
  end

  defp build_board(graph, _) do
    for x <- 0..3, reduce: graph do
      graph ->
        graph
        |> line({{x * @grid_size, 0}, {x * @grid_size, 3 * @grid_size}}, stroke: {4, :white})
        |> line({{0, x * @grid_size}, {3 * @grid_size, x * @grid_size}}, stroke: {4, :white})
    end
  end

  defp build_cells(graph, %Game{board: board}) do
    for x <- 0..2, y <- 0..2, reduce: graph do
      graph ->
        graph
        |> draw_cell(board, x, y)
    end
  end

  defp draw_cell(graph, %Board{grids: grids}, x, y) do
    case Map.get(grids, {x, y}) do
      :x ->
        graph
        |> line({{20, 20}, {80, 80}}, stroke: {5, :red}, translate: {x * 100, y * 100})
        |> line({{80, 20}, {20, 80}}, stroke: {5, :red}, translate: {x * 100, y * 100})

      :o ->
        graph
        |> circle(30, stroke: {5, :yellow}, translate: {x * 100 + 50, y * 100 + 50})

      _ ->
        graph
    end
  end
end
