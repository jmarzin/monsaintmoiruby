class MaterielsController < ApplicationController
  before_action :set_materiel, only: %i[show edit update destroy]
  before_action :test_admin, only: %i[edit update destroy new create]
  before_action :set_menu

  # GET /materiels
  # GET /materiels.json
  def index
    @materiels = Materiel.all.order(poids: :desc)
  end

  def index_trace
    @materiels = Trace.find(params[:id]).materiels.order(poids: :desc)
    render 'index'
  end

  # GET /materiels/1
  # GET /materiels/1.json
  def show; end

  # GET /materiels/new
  def new
    @materiel = Materiel.new
    @materiel.photo = "0pasdimage.jpg"
    @photos_candidates = photos_candidates
  end

  # GET /materiels/1/edit
  def edit
    @photos_candidates = photos_candidates << @materiel.photo
  end

  # POST /materiels
  # POST /materiels.json
  def create
    @materiel = Materiel.new(materiel_params)
    photo = charge_photo_si_besoin
    @materiel.photo = photo unless photo.nil?
    respond_to do |format|
      if @materiel.save
        format.html { redirect_to @materiel, notice: 'Le matériel est bien enregistré' }
        format.json { render :show, status: :created, location: @materiel }
      else
        @photos_candidates = photos_candidates
        format.html { render :new }
        format.json { render json: @materiel.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /materiels/1
  # PATCH/PUT /materiels/1.json
  def update
    photo = charge_photo_si_besoin
    params[:materiel][:photo] = photo unless photo.nil?
    respond_to do |format|
      if @materiel.update(materiel_params)
        format.html { redirect_to @materiel, notice: 'Le matériel a bien été corrigé.' }
        format.json { render :show, status: :ok, location: @materiel }
      else
        @photos_candidates = photos_candidates
        format.html { render :edit }
        format.json { render json: @materiel.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /materiels/1
  # DELETE /materiels/1.json
  def destroy
    @materiel.destroy
    respond_to do |format|
      format.html { redirect_to materiels_url, notice: 'Le matériel a bien été détruit.' }
      format.json { head :no_content }
    end
  end

  private

  def photos_candidates
    photos_repertoire = Dir.entries(Rails.root.join('public', 'materiels')).select {|f| !File.directory? f}
    photos_base = Materiel.where.not(photo: '0pasdimage.jpg')
                      .select(:photo)
                      .distinct
                      .collect(&:photo)
    (photos_repertoire - photos_base).collect {|p| [p, p]}
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_materiel
    @materiel = Materiel.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def materiel_params
    params.require(:materiel).permit(:nom, :description, :photo, :poids, :reforme)
  end

  def set_menu
    session[:menu] = "Matériels"
  end

  def test_admin
    if session[:admin].nil?
      if ['destroy', 'edit', 'update'].index(action_name)
        redirect_to @materiel, notice: "Vous n'êtes pas administrateur"
      else
        redirect_to materiels_url, notice: "Vous n'êtes pas administrateur"
      end
    end
  end

  def charge_photo_si_besoin
    uploaded_io = params[:materiel][:nouvelle_photo]
    if uploaded_io.nil?
      nil
    else
      File.open(Rails.root.join('public', 'materiels',
                                uploaded_io.original_filename), 'wb') do |file|
        file.write(uploaded_io.read)
      end
      uploaded_io.original_filename
    end
  end
end
