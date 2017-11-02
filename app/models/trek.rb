class Trek < Trace
  has_many :randonnees, class_name: 'Trace', foreign_key: 'traces_id',
                        dependent: :nullify
  def fusionne(gpx)
    raise 'la méthode fusionne attend un tableau de String' unless gpx.is_a?(Array) &&
                                                                   !gpx.empty? &&
                                                                   gpx[0].is_a?(String)
    puts "début de fusion #{Time.now.to_f}"
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
    xml = Nokogiri::XML(resultat)
    maj_apres_lecture(xml)
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
    resultat = xml.to_s.gsub(/^ +\n/, '')
    trkpts = xml.xpath('//xmlns:trkpt')
    latitudes = trkpts.map { |l| BigDecimal(l.attribute('lat').text) }
    longitudes = trkpts.map { |l| BigDecimal(l.attribute('lon').text) }
    resultat = resultat.sub(/<bounds .*?\/>/m,
                            "<bounds maxlat=\"#{latitudes.max}\" maxlong=\"#{longitudes.max}\" minlat=\"#{latitudes.min}\" minlon=\"#{longitudes.min}\"/>")
    nom_fichier = id
    if nom_fichier.nil?
      nom_fichier = Trace.find_by_sql("SELECT nextval('traces_id_seq') AS trace_id")[0].trace_id + 1
    end
    File.write(Rails.root.join('public', 'gpx', 'treks',
                               "#{nom_fichier}.gpx"),
               resultat.to_s)
    "#{nom_fichier}.gpx"
  end
end
