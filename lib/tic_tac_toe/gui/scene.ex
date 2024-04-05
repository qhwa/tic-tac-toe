defmodule TicTacToe.Gui.Scene do
  alias Scenic.Graph

  alias TicTacToe.GameServer
  alias TicTacToe.Core.Game
  alias TicTacToe.Core.Board

  use Scenic.Scene

  import Scenic.Primitives
  import Scenic.Components

  @grid_size 200

  @impl true
  def init(scene, _param, _opts) do
    {:ok, server} = GameServer.start_link([])

    scene =
      scene
      |> assign(:server, server)
      |> update_graph()

    :ok = scene |> capture_input([:key])

    {:ok, scene}
  end

  defp update_graph(%{assigns: %{server: server}} = scene) when is_pid(server) do
    game = GameServer.get_game(server)

    scene
    |> push_graph(render_graph(game))
  end

  defp render_graph(%Game{} = game) do
    Graph.build()
    |> then(fn graph ->
      winner = Game.winner(game)
      game_over? = Game.game_over?(game)

      cond do
        winner != nil ->
          graph
          |> text("Winner: #{winner |> to_string() |> String.upcase()}",
            font_size: 20,
            translate: {0, 20}
          )

        game_over? ->
          graph
          |> text("Draw!",
            font_size: 20,
            translate: {0, 20}
          )

        :otherwise ->
          graph
          |> text("Player: #{game.current_player |> to_string() |> String.upcase()}",
            font_size: 20,
            translate: {0, 20}
          )
      end
    end)
    |> group(
      fn
        graph ->
          graph
          |> render_board(game)
          |> render_cells(game)
      end,
      translate: {5, 50}
    )
    |> render_buttons(game)
  end

  defp render_board(graph, game) do
    input = if game.winner == nil, do: [:cursor_button, :cursor_pos], else: []

    graph =
      graph
      |> rect({3 * @grid_size, 3 * @grid_size},
        id: :board,
        input: input,
        fill: :grey
      )

    for x <- 0..3, reduce: graph do
      graph ->
        graph
        |> line({{x * @grid_size, 0}, {x * @grid_size, 3 * @grid_size}}, stroke: {4, :white})
        |> line({{0, x * @grid_size}, {3 * @grid_size, x * @grid_size}}, stroke: {4, :white})
    end
  end

  defp render_cells(graph, %Game{board: board}) do
    for x <- 0..2, y <- 0..2, reduce: graph do
      graph ->
        graph
        |> draw_cell(board, x, y)
    end
  end

  defp draw_cell(graph, %Board{grids: grids}, x, y) do
    scale = @grid_size / 100

    case Map.get(grids, {x, y}) do
      :x ->
        graph
        |> group(
          fn graph ->
            graph
            |> line({{20, 20}, {80, 80}}, stroke: {5, :red}, scale: scale, pin: {0, 0})
            |> line({{80, 20}, {20, 80}}, stroke: {5, :red}, scale: scale, pin: {0, 0})
          end,
          translate: {x * @grid_size, y * @grid_size}
        )

      :o ->
        graph
        |> circle(30,
          stroke: {5, :yellow},
          scale: scale,
          pin: {0, 0},
          translate: {x * @grid_size + div(@grid_size, 2), y * @grid_size + div(@grid_size, 2)}
        )

      _ ->
        graph
    end
  end

  defp render_buttons(graph, %Game{} = game) do
    graph
    |> group(
      fn graph ->
        graph
        |> render_reset_button()
        |> render_undo_button(game)
      end,
      translate: {0, 3 * @grid_size + 70}
    )
  end

  defp render_reset_button(graph) do
    graph
    |> button("Reset", translate: {100, 0}, id: :reset_button)
  end

  defp render_undo_button(graph, _game) do
    graph
    |> button("<-", translate: {200, 0}, id: :undo_button)
  end

  @impl true
  def handle_input(
        {:cursor_button, {:btn_left, 0, _, {x, y}}},
        :board,
        %{assigns: %{server: server}} = scene
      ) do
    {x, y} = {x - 5, y - 50}

    col = floor(x / @grid_size)
    row = floor(y / @grid_size)

    case GameServer.play(server, {col, row}) do
      :ok ->
        {:noreply, update_graph(scene)}

      {:error, _reason} ->
        {:halt, scene}
    end
  end

  def handle_input(_input, _id, scene) do
    {:halt, scene}
  end

  @impl true
  def handle_event({:click, :reset_button}, _from, %{assigns: %{server: server}} = scene) do
    :ok = GameServer.reset(server)

    {:noreply, update_graph(scene)}
  end

  def handle_event({:click, :undo_button}, _from, %{assigns: %{server: server}} = scene) do
    GameServer.undo(server)

    {:noreply, update_graph(scene)}
  end
end
