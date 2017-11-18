require 'response'
##
# classe du contrôleur admin
class AdminController < ApplicationController

  ##
  # demande du mot de passe de l'administrateur
  def password; end

  ##
  # vérification du mot de passe de l'administrateur
  def check_password
    if params[:password].crypt('ld') == 'ldrGUIh/JewKE'
      session[:admin] = true
      redirect_to root_url, notice: 'Vous êtes administrateur'
    else
      flash.now[:alert] = 'Erreur de saisie'
      render :password
    end
  end

  def maj_polylines
    Trace.all.each do |t|
      profil = []
      t.points.each do |p|
        profil << [p.distance, p.altitude]
      end
      t.polylines = [profil]
      t.save
    end
    redirect_to root_url, notice: 'Mise à jour effectuée.'
  end
end
