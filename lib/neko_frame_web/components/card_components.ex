defmodule NekoFrameWeb.CardComponents do
  use Phoenix.Component

  attr :id, :string, required: true
  attr :name, :string
  attr :label, :string, default: nil
  attr :value, :any
  attr :type, :string, default: "text"
  attr :field, Phoenix.HTML.FormField, doc: "a form field struct"
  attr :errors, :list, default: []

  attr :rest, :global,
    include: ~w(disabled readonly placeholder rows required min max step options)

  def input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:name, field.name)
    |> assign(:value, field.value)
    |> assign(:errors, Enum.map(field.errors, &translate_error(&1)))
    |> input()
  end

  def input(%{type: "select"} = assigns) do
    ~H"""
    <div class="input-group">
      <label if={@label} for={@id} class="input-label">
        {@label}
      </label>
      <select id={@id} name={@name} class="select-input" {@rest}>
        <option :for={option <- @rest.options} value={option}>{option}</option>
      </select>
      <div :for={msg <- @errors} class="input-error">{msg}</div>
    </div>
    """
  end

  def input(%{type: "textarea"} = assigns) do
    ~H"""
    <div class="input-group">
      <label if={@label} for={@id} class="input-label">
        {@label}
      </label>
      <textarea
        id={@id}
        name={@name}
        class="textarea-input"
        rows={@rest[:rows] || 4}
        {@rest}
      >{Phoenix.HTML.Form.normalize_value("textarea", @value)}</textarea>
      <div :for={msg <- @errors} class="input-error">{msg}</div>
    </div>
    """
  end

  def input(assigns) do
    ~H"""
    <div class="input-group">
      <label if={@label} for={@id} class="input-label">
        {@label}
      </label>
      <input
        type={@type}
        id={@id}
        name={@name}
        value={Phoenix.HTML.Form.normalize_value(@type, @value)}
        class="text-input"
        {@rest}
      />
      <div :for={msg <- @errors} class="input-error">{msg}</div>
    </div>
    """
  end

  # Simple error translator
  defp translate_error({msg, _opts}) when is_binary(msg), do: msg

  defp translate_error({msg, opts}) do
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", fn _ -> to_string(value) end)
    end)
  end
end
