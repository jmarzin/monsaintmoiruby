require 'response'
class AdminController < ApplicationController
  skip_before_action :verify_authenticity_token
  def upload_image
    uploaded_io = params[:file]
    if uploaded_io.nil?
      json_f = {}
      statut = :ok
    else
      json_f = {"location" => File.join('..', 'images', uploaded_io.original_filename)}
      begin
        File.open(Rails.root.join('public', 'images', uploaded_io.original_filename), 'wb') do |file|
          file.write(uploaded_io.read)
        end
        statut = :ok
      rescue
        statut = :internal_server_error
      end
    end
    render json: json_f, status: statut
  end

  def password; end

  def check_password
    respond_to do |format|
      if params[:password].crypt('ld') == "ldrGUIh/JewKE"
        session[:admin] = true
        format.html { redirect_to root_url, notice: 'Vous êtes administrateur' }
      else
        flash.now[:alert] = 'Erreur de saisie'
        format.html { render :password }
      end
    end
  end

  def agenda
    session[:menu] = 'Dans les jours qui viennent'
  end
end