# lib/neko_frame_web/live/card_live.ex
defmodule NekoFrameWeb.CardLive do
  use NekoFrameWeb, :live_view
  import NekoFrameWeb.CardComponents

  require Logger

  @impl true
  def mount(_params, _session, socket) do
    form =
      to_form(%{
        "name" => "",
        "type" => "Gato",
        "class" => "",
        "suprimento_comum" => "0",
        "favor" => "0",
        "dinheiro" => "0",
        "suprimento_especial" => "0",
        "energy" => "0",
        "description" => "",
        "briga" => "",
        "coragem" => "",
        "font_size" => "9"
      })

    Logger.info("CardLive mounted, setting up upload configuration")

    {:ok,
     socket
     |> assign(:form, form)
     |> assign(:card_class, "gato")
     |> assign(:is_legendary, false)
     |> assign(:preview_url, nil)
     |> assign(:font_size, 9)
     |> allow_upload(:card_art,
       accept: ~w(.jpg .jpeg .png),
       max_entries: 1,
       max_file_size: 25_000_000,
       progress: &handle_progress/3,
       auto_upload: true
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="card-builder-container" id="card-builder">
      <!-- Form Section -->
      <div class="controls-panel">
        <h2>Criador de Cartas Neko</h2>
        <.form for={@form} phx-change="update_card" phx-submit="save_card">
          <!-- Basic Information -->
          <div class="form-section">
            <.input
              id="name-input"
              field={@form[:name]}
              label="Nome da Carta"
              placeholder="Ex: Pandora, Líder do Culto"
              required
            />
            <.input
              id="type-input"
              type="select"
              field={@form[:type]}
              label="Tipo da Carta"
              options={["Gato", "Criaturinha", "Auxílio", "Treco", "Recurso", "Divindade", "Tutor"]}
              required
            />
            <.input
              id="class-input"
              field={@form[:class]}
              label="Classe"
              placeholder="Ex: domestico, selvagem, mágico"
            />
            <!-- Cost Types Grid -->
            <div class="cost-inputs-grid">
              <.input
                id="suprimento-comum-input"
                field={@form[:suprimento_comum]}
                label="Suprimento Comum"
                type="number"
                min="0"
                max="9"
                placeholder="0"
              />
              <.input
                id="favor-input"
                field={@form[:favor]}
                label="Favor"
                type="number"
                min="0"
                max="9"
                placeholder="0"
              />
              <.input
                id="dinheiro-input"
                field={@form[:dinheiro]}
                label="Dinheiro"
                type="number"
                min="0"
                max="9"
                placeholder="0"
              />
              <.input
                id="suprimento-especial-input"
                field={@form[:suprimento_especial]}
                label="Suprimento Especial"
                type="number"
                min="0"
                max="9"
                placeholder="0"
              />
              <.input
                id="energy-input"
                field={@form[:energy]}
                label="Energia"
                type="number"
                min="0"
                max="9"
                placeholder="0"
              />
            </div>
          </div>
          
    <!-- Description -->
          <div class="form-section">
            <.input
              id="description-input"
              field={@form[:description]}
              type="textarea"
              label="Descrição"
              placeholder="Descreva os efeitos e habilidades da carta..."
              rows="4"
              required
            />
          </div>
          
    <!-- Font Controls -->
          <div class="form-section">
            <div class="stats-inputs">
              <.input
                id="font-size-input"
                type="range"
                field={@form[:font_size]}
                label="Tamanho da Fonte - Descrição"
                min="7"
                max="9"
                step="1"
              />
            </div>
          </div>
          
    <!-- Combat Stats (For Cats/Creatures) -->
          <%= if @form[:type].value in ["Gato", "Criaturinha", "Divindade", "Tutor"] do %>
            <div class="form-section">
              <div class="stats-inputs">
                <.input
                  id="briga-input"
                  field={@form[:briga]}
                  label="Briga"
                  type="text"
                  placeholder="0 ou X"
                  required
                />
                <.input
                  id="coragem-input"
                  field={@form[:coragem]}
                  label="Coragem"
                  type="text"
                  placeholder="0 ou X"
                  required
                />
              </div>
            </div>
          <% end %>
          
    <!-- Image Upload -->
          <div class="form-section">
            <label class="input-label">Arte da Carta</label>
            <div
              class="upload-zone"
              phx-drop-target={@uploads.card_art.ref}
              onclick="this.querySelector('input[type=file]').click()"
            >
              <.live_file_input upload={@uploads.card_art} style="display: none;" />
              <div class="upload-content">
                <div style="font-weight: 600; margin-bottom: 0.5rem;">
                  Clique ou arraste uma imagem
                </div>
                <div class="upload-hint">PNG, JPG ou JPEG • Máximo 25MB</div>
              </div>
            </div>
          </div>
        </.form>
      </div>
      
    <!-- Live Preview -->
      <div class="preview-panel">
        <div class={"card-frame #{@card_class} #{if @is_legendary, do: "legendary"}"}>
          <!-- Full art background -->
          <div
            class="card-art"
            style={"background-image: url(#{@preview_url || ~c'/images/placeholder.png'})"}
          >
            <!-- Name overlay on top -->
            <div class="card-name-overlay">
              <span class="card-name">{@form[:name].value || "Nome da Carta"}</span>
              {render_cost_badges(@form)}
            </div>
          </div>
          
    <!-- Bottom frame only -->
          <div class="card-bottom-frame">
            <div class="card-type-badge">
              {@form[:type].value}{if @form[:class].value && @form[:class].value != "",
                do: " #{@form[:class].value}",
                else: ""}
            </div>
            <div class="card-description" style={"font-size: #{@font_size}pt;"}>
              {@form[:description].value || "Descrição da carta..."}
            </div>
          </div>
          
    <!-- Simple stats in bottom-right corner -->
          <%= if @form[:type].value in ["Gato", "Criaturinha", "Divindade", "Tutor"] do %>
            <div class="card-stats">
              {@form[:briga].value || "0"}<br />-<br />{@form[:coragem].value || "0"}<br />
              <!-- <span>{@form[:briga].value || "0"}</span>
              <span>/</span>
              <span>{@form[:coragem].value || "0"}</span> -->
            </div>
          <% end %>
        </div>
        
    <!-- Export buttons -->
        <div class="export-controls">
          <button type="button" onclick="exportCard('png')" class="btn-export">
            Exportar como PNG
          </button>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("update_card", params, socket) do
    form = to_form(params)
    card_class = determine_card_class(params["type"])
    is_legendary = is_legendary_card?(params)
    font_size = atoi(params["font_size"] || "9")

    {:noreply,
     socket
     |> assign(:form, form)
     |> assign(:card_class, card_class)
     |> assign(:is_legendary, is_legendary)
     |> assign(:font_size, font_size)}
  end

  @impl true
  def handle_event("save_card", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  def handle_progress(:card_art, entry, socket) do
    if entry.done? do
      url = consume_uploaded_entry(socket, entry, &upload_file/1)
      Logger.info("Upload successful: #{url}")
      {:noreply, assign(socket, :preview_url, url)}
    else
      {:noreply, socket}
    end
  end

  defp upload_file(%{path: path}) do
    # Generate unique filename
    filename = "#{System.unique_integer([:positive])}_#{Path.basename(path)}"
    dest = Path.join(NekoFrame.upload_path(), filename)

    # Ensure uploads directory exists
    uploads_dir = Path.dirname(dest)
    File.mkdir_p!(uploads_dir)
    Logger.debug("Created uploads directory: #{uploads_dir}")

    # Copy file
    File.cp!(path, dest)
    Logger.debug("File copied to: #{dest}")

    # Return the URL in the correct tuple format
    url = "/uploads/#{filename}"
    Logger.info("Upload complete, URL: #{url}")
    {:ok, url}
  end

  defp determine_card_class("Gato"), do: "gato"
  defp determine_card_class("Divindade"), do: "divindade"
  defp determine_card_class("Criaturinha"), do: "criaturinha"
  defp determine_card_class("Auxílio"), do: "auxilio"
  defp determine_card_class("Treco"), do: "treco"
  defp determine_card_class("Recurso"), do: "recurso"
  defp determine_card_class("Tutor"), do: "tutor"
  defp determine_card_class(_), do: "gato"

  defp is_legendary_card?(params) do
    params["type"] == "Divindade"
  end

  defp render_cost_badges(form) do
    cost_types = [
      {"suprimento_comum", "Suprimento Comum"},
      {"favor", "Favor"},
      {"dinheiro", "Dinheiro"},
      {"suprimento_especial", "Suprimento Especial"},
      {"energy", "Energia"}
    ]

    badge_strings =
      cost_types
      |> Enum.map(&gen_badge_string(form, &1))
      |> Enum.filter(&(&1 != nil))

    case badge_strings do
      [] ->
        Phoenix.HTML.raw("")

      badges_list ->
        Phoenix.HTML.raw("""
        <div class="cost-badges-container">
          #{Enum.join(badges_list, "")}
        </div>
        """)
    end
  end

  defp gen_badge_string(form, {field, _label}) do
    value = form[String.to_atom(field)].value || "0"
    value = atoi(value)

    if value == 0, do: nil, else: ~s|<span class=\"cost-badge #{field}\">#{value}</span>|
  end

  defp atoi(""), do: 0
  defp atoi(nil), do: 0

  defp atoi(number) when is_binary(number) do
    case Integer.parse(number) do
      {n, _} -> n
      :error -> 0
    end
  end
end
