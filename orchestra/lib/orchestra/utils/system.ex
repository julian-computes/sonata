defmodule Orchestra.Utils.System do
  @callback cmd(binary(), [binary()], keyword()) ::
              {Collectable.t(), exit_status :: non_neg_integer()}
  def cmd(command, args, opts \\ []) do
    impl().cmd(command, args, opts)
  end

  defp impl do
    Process.get(:orchestra_utils_system, Orchestra.Utils.SystemImpl)
  end
end

defmodule Orchestra.Utils.SystemImpl do
  @behaviour Orchestra.Utils.System

  @impl true
  def cmd(command, args, opts \\ []) do
    System.cmd(command, args, opts)
  end
end
