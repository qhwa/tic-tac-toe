# Tic-Tac-Toe

This is a simple implementation of the game Tic-Tac-Toe in Elixir. It is a GUI game based on [Scenic](https://hex.pm/packages/scenic).

## Motivation

I wanted to apply my latest, as of writing in 2024, understanding of constructing an application to a fun project.
I also wanted to learn more about Scenic and how to build GUI applications in Elixir, when choosing a UI for it.

## Running the game

To run the game, you need to have Elixir installed on your machine. You can find instructions on how to install Elixir [here](https://elixir-lang.org/install.html). For the GUI, you need to install glfw which is a dependency of Scenic. You can find instructions on how to install glfw [here](https://github.com/ScenicFramework/scenic_driver_local).

After you have installed Elixir and glfw, you can run the game by running `mix run --no-halt` in the root of the project.

## Playing the game

Currently there's no AI implemented, so you can only play against yourself. To make a move, click on the cell you want to place your mark in.
