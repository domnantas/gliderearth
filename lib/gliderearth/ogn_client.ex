defmodule Gliderearth.OgnClient do
  use GenServer
  require Logger
  alias Gliderearth.OgnParser

  def start_link(_args) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_args) do
    {:ok, socket} = connect_to_glidernet()
    :ok = login_to_glidernet(socket, "GLDRERTH", "-1")
    {:ok, socket}
  end

  defp connect_to_glidernet() do
    glidernet_hostname = 'aprs.glidernet.org'
    glidernet_port = 10152
    Logger.debug("Attempting to make TCP connection to #{glidernet_hostname}:#{glidernet_port}")
    options = [:binary, packet: :line, active: true]
    :gen_tcp.connect(glidernet_hostname, glidernet_port, options)
  end

  defp login_to_glidernet(socket, username, password) do
    login_string = "user #{username} pass #{password} vers Gliderearth 0.0.1\n"

    :gen_tcp.send(socket, login_string)
  end

  def handle_info({:tcp, _socket, packet}, state) do
    process_packet(packet)

    {:noreply, state}
  end

  def handle_info({:tcp_closed, _socket}, state) do
    Logger.info("Socket has been closed")
    {:stop, :normal, state}
  end

  def handle_info({:tcp_error, _socket, reason}, state) do
    Logger.error("Connection closed due to #{inspect(reason)}")
    {:stop, :normal, state}
  end

  def process_packet(packet) do
    # {:ok, parsed_packet} = OgnParser.parse(packet)
    IO.inspect(OgnParser.parse(packet))
    # |> Map.put(:server_timestamp, DateTime.now!("Etc/UTC"))
    # |> Map.put(:raw_data, packet)

    # TODO: enhance the positions

    # case parsed_packet.data_type do
    #   :status -> nil
    #   :timestamped_position -> IO.inspect(parsed_packet.data_extended.position.lat_fractional)
    #   _ -> Logger.error("Unknown packet type: #{parsed_packet.data_type}")
    # end
  end
end
