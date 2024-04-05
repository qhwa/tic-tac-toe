defmodule TicTacToe.Core.Board do
  alias __MODULE__

  @type t() :: %Board{
          grids: %{optional(pos()) => nil | :x | :o}
        }

  @type pos() :: {xy(), xy()}
  @type xy() :: 0 | 1 | 2

  defstruct grids: %{}

  def new do
    %Board{}
  end

  def full?(%Board{grids: grids}) do
    map_size(grids) == 9 && Enum.all?(grids, fn {_pos, value} -> value end)
  end
end
