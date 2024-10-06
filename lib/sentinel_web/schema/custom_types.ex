defmodule SentinelWeb.Schema.CustomTypes do
  use Absinthe.Schema.Notation

  defmacro paginate(type) do
    quote do
      object unquote(:"paginated_#{type}") do
        field :data, list_of(unquote(type))
        field :page_number, :integer
        field :page_size, :integer
        field :total_pages, :integer
        field :total_data, :integer
      end
    end
  end

  enum :pagination_sort do
    value(:asc)
    value(:desc)
  end
end
