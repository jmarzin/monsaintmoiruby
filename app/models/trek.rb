##
# classe de gestion des treks
class Trek < Trace
  has_many :randonnees, class_name: 'Trace', foreign_key: 'traces_id',
                        dependent: :nullify
  # fusionne les gpx fournis
  # retourne le nom du fichier créé
  def fusionne(gpx, gpx_avant)
    raise 'la méthode fusionne attend un tableau de String' unless gpx.is_a?(Array) &&
                                                                   !gpx.empty? &&
                                                                   gpx[0].is_a?(String)
    resultat = construit_fichier_fusionne(gpx)
    xml = Nokogiri::XML(resultat)
    maj_sql(gpx, gpx_avant)
    xml = simplifie_fichier(xml)
    resultat = xml.to_s.gsub(/^ +\n/, '')
    resultat = maj_bounds(xml, resultat)
    ecrit_fichier(resultat)
  end

  # calcule les caractéristiques du trek à partir
  # de celles des randonnées
  def maj_sql(gpx, gpx_avant)
    traces = Trace.where(fichier_gpx: gpx).order(:heure_debut)
    # préparation des profils à concaténer
    traces_a_traiter = prepare_traces(traces, gpx_avant)
    # traitement des profils
    @distances_cumulees = []
    dist_prec = 0
    @altitudes = []
    traces_a_traiter.each do |trace|
      reduction_dist = trace.distance_totale / (2 * PRECISION)
      reduction_alt = (trace.altitude_maximum - trace.altitude_minimum) / PRECISION
      JSON.parse(trace.polylines).each do |polyline|
        altitudes_polyline = []
        distances_cumulees_polyline = []
        polyline.each do |point|
          dist = dist_prec + point[0] * reduction_dist
          distances_cumulees_polyline << dist
          alt = trace.altitude_minimum - (point[1] - 1000) * reduction_alt
          altitudes_polyline << alt
        end
        @distances_cumulees << distances_cumulees_polyline
        @altitudes << altitudes_polyline
      end
      dist_prec = @distances_cumulees.last.last
    end
    maj_donnees_trek(traces)
    self.polylines = traite_profil
  end

  # mise à jour des données du trek
  # à partir des données des randonnées
  def maj_donnees_trek(traces)
    self.altitude_minimum = traces.minimum('altitude_minimum')
    self.altitude_maximum = traces.maximum('altitude_maximum')
    self.ascension_totale = traces.sum('ascension_totale')
    self.descente_totale = traces.sum('descente_totale')
    self.heure_debut = traces.first.heure_debut
    self.heure_fin = traces.last.heure_fin
    self.distance_totale = traces.sum('distance_totale')
    self.lat_depart = traces.first.lat_depart
    self.long_depart = traces.first.long_depart
    self.lat_arrivee = traces.last.lat_arrivee
    self.long_arrivee = traces.last.long_arrivee
  end

  #
  # si on ne fait qu'ajouter des randonnees à celles du trek
  # existant, on part du gpx du trek qu'on complète, sinon on part du gpx de
  # toutes les randonnées qui constituent le trek
  def prepare_traces(traces, gpx_avant)
    traces_a_traiter = traces.map { |t| gpx_avant.include?(t.fichier_gpx) ? nil : t}
    nb_traces = 0
    traces_a_traiter.each do |t|
      if t.nil?
        nb_traces += 1
      else
        break
      end
    end
    if nb_traces == gpx_avant.size
      traces_a_traiter.reject{ |t| t.nil? }.
                       sort{ |x,y| x.heure_debut <=> y.heure_debut }.
                       unshift(self)
    else
      traces.order(:heure_debut)
    end
  end

  # construit un nouvelle chaîne qui cumule
  # les trks des fichiers fournis
  # retourne la chaîne résultat
  def construit_fichier_fusionne(gpx)
    resultat = ''
    for fichier in gpx
      xml = IO.read(Rails.root.join('public', 'gpx', 'randos', fichier))
      if resultat.empty?
        resultat = xml
      else
        track = /.*(?<track><trk>.*?<\/trk>).*/m.match(xml)[:track]
        resultat = resultat.sub(/<\/gpx>/,
                                "  #{track}\n\n</gpx>")
      end
    end
    resultat
  end

  # simplifie le fichier en gardant
  # un point toutes les minutes
  # retourne le nouveau xml
  def simplifie_fichier(xml)
    heure_debut = nil
    xml.xpath('//xmlns:trkpt').each do |trkpt|
      next if trkpt.xpath('xmlns:time').text.blank?
      if heure_debut.blank?
        heure_debut = Time.parse(trkpt.xpath('xmlns:time').text)
      else
        heure = Time.parse(trkpt.xpath('xmlns:time').text)
        if heure.to_i < heure_debut.to_i || (heure.to_i - heure_debut.to_i) >= 60
          heure_debut = heure
        else
          trkpt.remove
        end
      end
    end
    xml
  end

  # calcule les coordonnées extrêmes du nouveau gpx
  # retourne le résultat
  def maj_bounds(xml, resultat)
    trkpts = xml.xpath('//xmlns:trkpt')
    latitudes = trkpts.map { |l| BigDecimal(l.attribute('lat').text) }
    longitudes = trkpts.map { |l| BigDecimal(l.attribute('lon').text) }
    resultat.sub(/<bounds .*?\/>/m,
                 "<bounds maxlat=\"#{latitudes.max}\" maxlon=\"#{longitudes.max}\" minlat=\"#{latitudes.min}\" minlon=\"#{longitudes.min}\"/>")
  end

  # détermine le nom du fichier et l'écrit
  def ecrit_fichier(resultat)
    nom_fichier = id
    if nom_fichier.nil?
      nom_fichier = Trace.find_by_sql("SELECT nextval('traces_id_seq') AS trace_id")[0].trace_id + 1
    end
    File.write(Rails.root.join('public', 'gpx', 'treks',
                               "#{nom_fichier}.gpx"),
               resultat.to_s)
    "#{nom_fichier}.gpx"
  end

  private :construit_fichier_fusionne, :simplifie_fichier, :maj_bounds, :ecrit_fichier, :maj_sql
end
