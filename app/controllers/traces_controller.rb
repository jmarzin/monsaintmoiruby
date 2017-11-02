class TracesController < ApplicationController
  # GET /traces
  # GET /traces.json

  TaillePage = 9

  def index
    @page_a_afficher = params[:id]
    if @page_a_afficher.nil?
      if controller_name == 'randonnees'
        redirect_to randonnees_page_url(1)
      else
        redirect_to treks_page_url(1)
      end
      return
    end
    @page_a_afficher = @page_a_afficher.to_i
    @traces = Trace.where(type: controller_name.classify).order(heure_debut: :desc)
    @nb_pages = [((@traces.size + 8.0) / TaillePage).floor, 1].max
    if @page_a_afficher > @nb_pages
      if controller_name == 'randonnees'
        redirect_to randonnees_page_url(@nb_pages)
      else
        redirect_to treks_page_url(@nb_pages)
      end
      return
    end
    @traces = @traces.to_a.slice((@page_a_afficher - 1) * TaillePage, TaillePage)
  end

  # GET /traces/1
  def show
    @photos = []
    unless @trace.repertoire_photos.blank?
      repertoire = Rails.root.join('public', 'images', @trace.repertoire_photos)
      @photos = Dir.entries(repertoire)
      unless @photos.empty?
        @photos = @photos.select {|f| File.extname(f).casecmp('.JPG').zero?}
                      .map {|f| File.join('/images', @trace.repertoire_photos, f)}
      end
    end
  end

  # GET /traces/new
  def new
    @trace = Trace.new(type: controller_name.classify)
    @gpx_candidats = gpx_candidats
    @rep_photos_candidats = rep_photos_candidats
    @gpx_avant = gpx_avant
  end

  # GET /traces/1/edit
  def edit
    @gpx_avant = gpx_avant
    @gpx_candidats = gpx_candidats
    @rep_photos_candidats = (@trace.repertoire_photos.nil? ? [] : [@trace.repertoire_photos]) +
        rep_photos_candidats
  end

  # PATCH/PUT /traces/1
  def update
    @trace.assign_attributes(trace_params)
    @gpx_avant = params[:gpx_avant]
    fichier_gpx = traite_traces_si_besoin
    nouveau_fichier = fichier_gpx.nil? ? params[@class_symbol][:fichier_gpx] : fichier_gpx
    @trace.maj unless fichier_gpx.nil? &&
                      (nouveau_fichier.blank? || nouveau_fichier == @trace.fichier_gpx)
    @trace.fichier_gpx = nouveau_fichier
    @trace.materiel_ids = params[@class_symbol][:materiel_ids]
    if @trace.save
      @trace.points.clear if @trace.fichier_gpx.blank?
      redirect_to @trace, notice: 'La randonnée a bien été modifiée.'
    else
      @gpx_candidats = (@trace.fichier_gpx.nil? ? [] : [@trace.fichier_gpx]) +
                       gpx_candidats
      @rep_photos_candidats = (@trace.repertoire_photos.nil? ? [] : [@trace.repertoire_photos]) +
                              rep_photos_candidats
      @gpx_avant = [@trace.fichier_gpx]
      render :edit
    end
  end

  private

  def rep_photos_candidats
    classe = @trace.type == 'Randonnee' ? Randonnee : Trek
    repertoire = Rails.root.join('public', 'images')
    rep_photos_serveur = Dir.entries(repertoire)
                            .select do |f|
      (File.directory? File.join(repertoire, f)) &&
        !(['.', '..'].include? f)
    end
    rep_photos_base = classe.select(:repertoire_photos)
                            .distinct
                            .collect(&:repertoire_photos)
    (rep_photos_serveur - rep_photos_base).collect { |r| [r, r] }
  end

  # Use callbacks to share common setup or constraints between actions.

  def set_class
    @class_symbol = controller_name.classify.downcase.to_sym
  end

  def set_trace
    @trace = Trace.find(params[:id])
  end

  def test_admin
    if false # session[:admin].nil?
      if %w[destroy edit update].index(action_name)
        redirect_to @trace, notice: "Vous n'êtes pas administrateur"
      else
        redirect_to randonnees_url, notice: "Vous n'êtes pas administrateur"
      end
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def trace_params
    params.require(@class_symbol)
          .permit(:titre, :sous_titre, :description,
                  :fichier_gpx, :altitude_minimum,
                  :altitude_maximum, :ascension_totale,
                  :descente_totale, :heure_debut, :heure_fin,
                  :distance_totale, :lat_depart, :long_depart,
                  :lat_arrivee, :long_arrivee, :type,
                  :repertoire_photos, points: %i[distance altitude],
                                      materiels: [], gpx_candidats: [])
  end
end
