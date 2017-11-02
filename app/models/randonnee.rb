class Randonnee < Trace
  belongs_to :trek, class_name: 'Trace', foreign_key: 'traces_id', optional: true

  def fichier_titre
    fichier_gpx + ' ' + titre
  end
end