# lib/neko_frame_web/live/card_live.ex
defmodule NekoFrameWeb.CardLive do
  use NekoFrameWeb, :live_view
  import NekoFrameWeb.CardComponents

  require Logger

  @card_types Enum.sort(~w|Gato Criaturinha Auxílio Treco Recurso Divindade Tutor|)
  @cost_types [
    {"suprimento_comum", "Suprimento Comum"},
    {"favor", "Favor"},
    {"dinheiro", "Dinheiro"},
    {"suprimento_especial", "Suprimento Especial"},
    {"energy", "Energia"}
  ]
  @default_font_size "8"

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
        "font_size" => @default_font_size
      })

    Logger.info("CardLive mounted, setting up upload configuration")

    {:ok,
     socket
     |> assign(:card_types, @card_types)
     |> assign(:form, form)
     |> assign(:card_type, "gato")
     |> assign(:preview_url, nil)
     |> assign(:font_size, 8)
     |> allow_upload(:card_art,
       accept: ~w(.jpg .jpeg .png),
       max_entries: 1,
       max_file_size: 10_000_000,
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
              options={@card_types}
              default="Gato"
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
          <div :if={has_stats?(@form[:type].value)} class="form-section">
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
                <div class="upload-hint">PNG, JPG ou JPEG</div>
              </div>
            </div>
          </div>
        </.form>
      </div>
      
    <!-- Live Preview -->
      <div class="preview-panel">
        <div class={"card-frame #{@card_type}"}>
          <!-- Full art area with name overlay -->
          <div class="card-art-area">
            <img
              src={@preview_url || "/images/placeholder.png"}
              alt="Card Art"
              class="card-art-image"
            />
            
    <!-- Name and cost overlay on top of art -->
            <div class="card-name-overlay">
              <span class="card-name">{@form[:name].value || "Nome da Carta"}</span>
              {render_cost_badges(@form)}
            </div>
          </div>
          
    <!-- Bottom section with type and description -->
          <div class="card-bottom-section">
            <div class="card-type-line">
              <span class="card-type-badge">
                {@form[:type].value}{if @form[:class].value && @form[:class].value != "",
                  do: " — #{@form[:class].value}",
                  else: ""}
              </span>
            </div>
            <div class="card-description" style={"font-size: #{@form[:font_size].value}pt;"}>
              {@form[:description].value || "Descrição da carta..."}
            </div>
          </div>
          
    <!-- Stats overlay -->
          <div :if={has_stats?(@form[:type].value)} class="card-stats">
            <span class="stat-value">{@form[:briga].value || "0"}</span>
            <span class="stats-divider">—</span>
            <span class="stat-value">{@form[:coragem].value || "0"}</span>
          </div>
        </div>
        
    <!-- Export buttons -->
        <div class="export-controls">
          <button type="button" onclick={~s|exportCard('#{@form[:name].value}')|} class="btn-export">
            Exportar como PNG
          </button>
        </div>
      </div>
    </div>
    """
  end

  def has_stats?(type), do: type not in ~w(Auxílio Recurso Treco)

  @impl true
  def handle_event("update_card", params, socket) do
    form = to_form(params)
    card_type = determine_card_type(params["type"])

    {:noreply,
     socket
     |> assign(:form, form)
     |> assign(:card_type, card_type)}
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

  defp determine_card_type("Gato"), do: "gato"
  defp determine_card_type("Divindade"), do: "divindade"
  defp determine_card_type("Criaturinha"), do: "criaturinha"
  defp determine_card_type("Auxílio"), do: "auxilio"
  defp determine_card_type("Treco"), do: "treco"
  defp determine_card_type("Recurso"), do: "recurso"
  defp determine_card_type("Tutor"), do: "tutor"
  defp determine_card_type(_), do: "gato"

  defp render_cost_badges(form) do
    badge_strings =
      @cost_types
      |> Enum.map(&gen_badge_string(form, &1))
      |> Enum.reject(&is_nil/1)

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
