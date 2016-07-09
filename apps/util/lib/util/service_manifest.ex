defmodule Util.ServiceManifest do
  def get do
    %{
      router: {:global, :router_server},
      bouncer: {:global, :bouncer_server},
      friends: {:global, :friends_server},
      chat: {:global, :chat_server},
      auth: {:global, :auth_server}
    }
  end
end
