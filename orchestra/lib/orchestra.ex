defmodule Orchestra do
  @moduledoc """
  Orchestra keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  def system do
    Application.get_env(:orchestra, :system, Orchestra.Utils.System)
  end

  def cloner do
    Application.get_env(:orchestra, :git_cloner, Orchestra.Git.Cloner)
  end

  def deno_runtime do
    Application.get_env(:orchestra, :deno_runtime, Orchestra.Runtime.DenoRuntime)
  end
end
