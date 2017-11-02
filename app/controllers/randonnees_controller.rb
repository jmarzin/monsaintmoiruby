class RandonneesController < TracesController
  before_action :set_class
  before_action :set_trace, only: %i[show edit update destroy]
  before_action :test_admin, only: %i[edit update destroy new create]
  before_action :set_menu

  # GET /randonnees/trek/1/page/1
  def trek_index
    @page_a_afficher = params[:idpage]
    @idtrek = params[:idtrek].to_i
    if @page_a_afficher.nil?
      redirect_to randonnees_trek_page_url(@idtrek, 1)
      return
    end
    @page_a_afficher = @page_a_afficher.to_i
    @traces = Trek.find(@idtrek).randonnees.order(heure_debut: :desc)
    @nb_pages = [((@traces.size + 8.0) / TaillePage).floor, 1].max
    if @page_a_afficher > @nb_pages
      redirect_to randonnees_trek_page_url(@idtrek, @nb_pages)
      return
    end
    @traces = @traces.to_a.slice((@page_a_afficher - 1) * TaillePage, TaillePage)
  end

  # POST /randonnees
  def create
    @trace = Trace.new(trace_params)
    unless params[@class_symbol][:points_attributes].nil?
      params[@class_symbol][:points_attributes].each do |_cle, pa|
        @trace.points << Point.new(distance: pa[:distance].to_i, altitude: pa[:altitude].to_i)
      end
    end
    @trace.materiel_ids = params[@class_symbol][:materiel_ids]
    @gpx_avant = params[:gpx_avant]
    fichier_gpx = traite_traces_si_besoin
    @trace.fichier_gpx = fichier_gpx unless fichier_gpx.nil?
    if @trace.save
      redirect_to @trace, notice: 'La randonnée a bien été créée.'
    else
      @gpx_candidats = params[:gpx_candidats].map { |gpx| [gpx, gpx] }
      @rep_photos_candidats = rep_photos_candidats
      render :new
    end
  end

  # DELETE /randonnees/1
  def destroy
    @trace.destroy
    redirect_to randonnees_url, notice: 'La randonnée a bien été supprimée.'
  end

  private

  def gpx_candidats
    repertoire = Rails.root.join('public', 'gpx', 'randos')
    gpx_repertoire = Dir.entries(repertoire)
                        .select do |f|
      (!File.directory? File.join(repertoire, f)) &&
        File.extname(f).casecmp('.GPX').zero?
    end

    gpx_base = Randonnee.select(:fichier_gpx)
                        .distinct
                        .collect(&:fichier_gpx)
    resultat = [['', '']]
    resultat += [[@trace.fichier_gpx]] unless @trace.fichier_gpx.blank?
    resultat + (gpx_repertoire - gpx_base).collect { |p| [p, p] }
  end

  def gpx_avant
    @trace.fichier_gpx.blank? ? [''] : [@trace.fichier_gpx]
  end

  def traite_traces_si_besoin
    uploaded_io = params[@class_symbol][:nouveau_fichier_gpx]
    if uploaded_io.nil?
      @trace.maj unless @trace.fichier_gpx.blank? || @trace.fichier_gpx == @gpx_avant[0]
      nil
    else
      File.open(Rails.root.join('public', 'gpx',
                                @trace.class == Randonnee ? 'randos' : 'treks',
                                uploaded_io.original_filename), 'wb') do |file|
        file.write(uploaded_io.read)
      end
      @trace.fichier_gpx = uploaded_io.original_filename
      @trace.maj
      uploaded_io.original_filename
    end
  end

  def set_menu
    session[:menu] = 'Randos'
  end
end
