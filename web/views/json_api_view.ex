defmodule CanvasAPI.JSONAPIView do
  @moduledoc """
  A view of a resource according to the JSON API spec.

  http://jsonapi.org
  """

  @doc """
  Include a resource object in a JSON object.

  http://jsonapi.org/format/#fetching-includes
  """
  @spec include(map, boolean, map, (() -> map | [map])) :: map
  def include(json_object, false, _, _), do: json_object

  def include(json_object = %{included: _}, true, resource, resource_func) do
    do_include(json_object, apply(resource_func, [resource]))
  end

  def include(json_object, true, resource, resource_func) do
    json_object
    |> Map.put(:included, [])
    |> include(true, resource, resource_func)
  end

  defp do_include(json_object, resource_objects)
       when is_list(resource_objects) do
    json_object
    |> update_in([:included], &(&1 ++ resource_objects))
  end

  defp do_include(json_object, resource_object) do
    json_object
    |> update_in([:included], &([resource_object|&1]))
  end

  @doc """
  Add pagination links to a JSON object.

  http://jsonapi.org/format/#fetching-pagination
  """
  @spec paginate(map, map, map, (... -> any), atom) :: map
  def paginate(json_object, params, page, func, action) do
    first_page = %{limit: page.limit}

    next_page = %{
      limit: page.limit,
      offset: page.offset + page.limit
    }

    first_params = params |> Map.put("page", first_page)
    next_params = params |> Map.put("page", next_page)

    json_object
    |> link(:first, apply(func, [API.Endpoint, action, first_params]))
    |> link(:next, apply(func, [API.Endpoint, action, next_params]))
  end

  @doc """
  Get a top-level JSON object of the `data` or `errors` type.

  http://jsonapi.org/format/#document-top-level
  """
  @spec json_object(map, :data | :errors) :: map
  def json_object(data, type \\ :data)
  def json_object(data, :data), do: %{data: data}
  def json_object(errors, :errors), do: %{errors: errors}

  @doc """
  Add a link to a JSON object or a resource object.

  http://jsonapi.org/format/#document-links
  """
  @spec link(map, atom, String.t) :: map
  def link(resource_object = %{links: _}, rel, url) do
    resource_object
    |> update_in([:links, rel], fn(_) -> url end)
  end

  def link(resource_object, rel, url) do
    resource_object
    |> Map.put(:links, %{})
    |> link(rel, url)
  end

  @doc """
  Add a relationship identity object to a resource object.

  http://jsonapi.org/format/#document-resource-object-relationships
  """
  @spec relate(map, atom, map) :: map
  def relate(resource_object, key, struct = %{__struct__: mod}) do
    relate(resource_object, key, %{id: struct.id, type: mod.json_api_type})
  end

  def relate(resource_object = %{relationships: _}, key, resource_identifier) do
    resource_object
    |> update_in([:relationships, key],
                 fn(_) -> %{data: resource_identifier} end)
  end

  def relate(resource_object, key, resource_identifier) do
    resource_object
    |> Map.put(:relationships, %{})
    |> relate(key, resource_identifier)
  end

  @doc """
  Build a resource object from a given resource and attributes.

  http://jsonapi.org/format/#document-resource-objects
  """
  @spec resource_object(map, map) :: map
  def resource_object(resource, attributes) do
    resource_object(resource, attributes, resource.__struct__.json_api_type)
  end

  @spec resource_object(map, map, String.t) :: map
  def resource_object(resource, attributes, type) do
    %{
      type: type,
      id: resource.id,
      attributes: attributes
    }
  end
end
