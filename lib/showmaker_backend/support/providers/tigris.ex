defmodule ShowmakerBackend.Support.Providers.Tigris do
  @moduledoc """
  Module responsible to interact with Tigris object storage
  """

  alias ExAws.S3
  alias ShowmakerBackend.Support.Behaviours.ObjectStorage

  @behaviour ObjectStorage

  @impl ObjectStorage
  def insert_object(file_path, bucket_name, bucket_path) do
    file_path
    |> S3.Upload.stream_file()
    |> insert_stream(bucket_name, bucket_path)
  end

  @impl ObjectStorage
  def insert_stream(file_stream, bucket_name, bucket_path) do
    file_stream
    |> S3.upload(bucket_name, bucket_path)
    |> ExAws.request!()
  end
end
