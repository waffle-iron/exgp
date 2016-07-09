defmodule Bouncer.Connection do
  defstruct gid:        nil,
            email:      nil,
            transport:  nil,
            socket:     nil

  def new(transport, socket) do
    %Bouncer.Connection {
      transport: transport,
      socket: socket
    }
  end
end
