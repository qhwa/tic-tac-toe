defmodule TicTacToe.Gui.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts)
  end

  def init(_opts) do
    children = [
      {Scenic, [main_viewport_config()]}
      # {TicTacToe.Gui.Server, []}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  defp main_viewport_config do
    [
      name: :main,
      size: {800, 800},
      default_scene: TicTacToe.Gui.Scene,
      drivers: [
        [
          module: Scenic.Driver.Local,
          name: :local,
          window: [resizeable: false, title: "Example Application"]
        ]
      ]
    ]
  end
end
