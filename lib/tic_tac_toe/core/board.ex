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
end
