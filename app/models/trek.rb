##
# classe de gestion des treks
class Trek < Trace
  has_many :randonnees, class_name: 'Trace', foreign_key: 'traces_id',
                        dependent: :nullify
  # fusionne les gpx fournis
  # retourne le nom du fichier créé
  def fusionne(gpx)
    raise 'la méthode fusionne attend un tableau de String' unless gpx.is_a?(Array) &&
                                                                   !gpx.empty? &&
                                                                   gpx[0].is_a?(String)
    resultat = construit_fichier_fusionne(gpx)
    xml = Nokogiri::XML(resultat)
    maj_apres_lecture(xml)
    xml = simplifie_fichier(xml)
    resultat = xml.to_s.gsub(/^ +\n/, '')
    resultat = maj_bounds(xml, resultat)
    ecrit_fichier(resultat)
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
      if heure_debut.nil?
        heure_debut = Time.parse(trkpt.xpath('xmlns:time').text) if heure_debut.nil?
      else
        heure = Time.parse(trkpt.xpath('xmlns:time').text)
        if heure.to_i - heure_debut.to_i >= 60
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
                 "<bounds maxlat=\"#{latitudes.max}\" maxlong=\"#{longitudes.max}\" minlat=\"#{latitudes.min}\" minlon=\"#{longitudes.min}\"/>")
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

  private :construit_fichier_fusionne, :simplifie_fichier, :maj_bounds, :ecrit_fichier
end
