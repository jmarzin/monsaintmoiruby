class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  def index
    session[:menu] = "Home"
    @date_du_jour = Date.today
    @ma_date_du_jour = Madate.new(@date_du_jour.day, @date_du_jour.month, @date_du_jour.year)
    @ecart_retraite = @ma_date_du_jour.ecart(1, 7, 2018)
    @ecart_depart = @ma_date_du_jour.ecart(11, 5, 2019)
  end
end