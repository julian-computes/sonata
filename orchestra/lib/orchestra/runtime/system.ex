defmodule Orchestra.Runtime.SystemBehaviour do
  @callback cmd(binary(), [binary()], keyword()) :: {Collectable.t(), exit_status :: non_neg_integer()}
end

defmodule Orchestra.Runtime.System do
  @behaviour Orchestra.Runtime.SystemBehaviour

  @impl true
  def cmd(command, args, opts) do
    System.cmd(command, args, opts)
  end
end
