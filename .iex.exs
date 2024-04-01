defmodule Presentation do
  @moduledoc """
  For presentation only:
  > hyprctl monitors all
  > hyprctl keyword monitor HDMI-A-3,preferred,auto,1,mirror,eDP-1

  > cp reviews.xml reviews2.xml
  > flyctl storage dashboard
  > iex...

  iex> Presentation.upload_file("reviews2.xml")
  """

  alias ShowmakerBackend.Support.Behaviours.ObjectStorage

  def upload_file(file_path) do
    {:ok, module} = ObjectStorage.get_module(:tigris)
    module.insert_object(file_path, "showmaker", file_path)
  end
end
