defmodule Orchestra.Utils.SystemBehaviour do
  @callback cmd(binary(), [binary()], keyword()) :: {Collectable.t(), exit_status :: non_neg_integer()}
end

defmodule Orchestra.Utils.System do
  @behaviour Orchestra.Runtime.SystemBehaviour

  @impl true
  def cmd(command, args, opts) do
    System.cmd(command, args, opts)
  end
end
