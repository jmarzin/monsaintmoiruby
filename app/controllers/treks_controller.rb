class TreksController < TracesController

  before_action :set_class
  before_action :set_trace, only: %i[show edit update destroy]
  before_action :test_admin, only: %i[edit update destroy new create]
  before_action :set_menu

  def show
    unless @trace.repertoire_photos.blank?
      super
      return
    end
    @photos = []
    for randonnee in @trace.randonnees
      unless randonnee.repertoire_photos.blank?
        repertoire = Rails.root.join('public', 'images', randonnee.repertoire_photos)
        photos = Dir.entries(repertoire)
        unless photos.empty?
          @photos += photos.select {|f| File.extname(f).casecmp('.JPG').zero?}
                         .map {|f| File.join('/images', randonnee.repertoire_photos, f)}
        end
      end
    end
  end

  def a_propos
    session[:menu] = 'A propos'
    @trek = Trek.where(titre: 'Le projet')
    if @trek.empty?
      redirect_to root_url
    else
      @trace = @trek.first
      show
      render 'show'
    end
  end

  # POST /treks
  def create
    @trace = Trace.new(trace_params)
    @trace.materiel_ids = params[@class_symbol][:materiel_ids]
    @trace.randonnee_ids = params[@class_symbol][:randonnee_ids]
    @gpx_avant = params[:gpx_avant]
    fichier_gpx = traite_traces_si_besoin
    @trace.fichier_gpx = fichier_gpx unless fichier_gpx.nil?
    if @trace.save
      redirect_to @trace, notice: 'La randonnée a bien été créée.'
    else
      @gpx_candidats = gpx_candidats
      @rep_photos_candidats = rep_photos_candidats
      render :new
    end
  end

  def update
    @trace.assign_attributes(trace_params)
    @gpx_avant = params[:gpx_avant]
    @trace.randonnee_ids = params[@class_symbol][:randonnee_ids]
    fichier_gpx = traite_traces_si_besoin
    @trace.fichier_gpx = fichier_gpx unless fichier_gpx.nil?
    @trace.materiel_ids = params[@class_symbol][:materiel_ids]
    if @trace.save
      @trace.points.clear if @trace.fichier_gpx.blank?
      redirect_to @trace, notice: 'La randonnée a bien été modifiée.'
    else
      @gpx_candidats = gpx_candidats
      @rep_photos_candidats = (@trace.repertoire_photos.nil? ? [] : [@trace.repertoire_photos]) +
          rep_photos_candidats
      render :edit
    end
  end

  # DELETE /treks/1
  def destroy
    @trace.destroy
    redirect_to treks_url, notice: 'La randonnée a bien été supprimée.'
  end

  private

  def gpx_candidats
    Randonnee.where("traces_id IS NULL AND  fichier_gpx <> ''")
             .order(:fichier_gpx)
  end

  def gpx_avant
    if @trace.fichier_gpx.blank?
      ['']
    else
      @trace.randonnees.collect(&:fichier_gpx).sort
    end
  end

  def traite_traces_si_besoin
    @gpx_apres = @trace.randonnees.collect(&:fichier_gpx).sort
    ((@gpx_avant <=> @gpx_apres).zero?) ? nil : @trace.fusionne(@gpx_apres)
  end

  def set_menu
    session[:menu] = 'Treks'
  end
end