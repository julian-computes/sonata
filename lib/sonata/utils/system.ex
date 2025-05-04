defmodule Sonata.Utils.System do
  @callback cmd(binary(), [binary()], keyword()) ::
              {Collectable.t(), exit_status :: non_neg_integer()}
  def cmd(command, args, opts \\ []) do
    impl().cmd(command, args, opts)
  end

  defp impl do
    Process.get(:sonata_utils_system, Sonata.Utils.SystemImpl)
  end
end

defmodule Sonata.Utils.SystemImpl do
  @behaviour Sonata.Utils.System

  @impl true
  def cmd(command, args, opts \\ []) do
    System.cmd(command, args, opts)
  end
end
