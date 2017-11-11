##
# ajoute au module math une fonction de conversion
# en radians d'un angle en degré
module Math
  def self.to_radians(angle)
    angle / 180 * Math::PI
  end
end

##
# classe de gestion des traces
class Trace < ApplicationRecord
  validates :titre, presence: true
  validates :sous_titre, presence: true
  validates :description, presence: true
  validates :altitude_minimum, allow_nil: true, numericality: { only_integer: true }
  validates :altitude_maximum, allow_nil: true, numericality: { only_integer: true }
  validates :ascension_totale, allow_nil: true, numericality: { only_integer: true }
  validates :descente_totale, allow_nil: true, numericality: { only_integer: true }
  validates :distance_totale, allow_nil: true, numericality: { only_integer: true }
  validates :lat_depart, allow_nil: true, numericality: true
  validates :lat_arrivee, allow_nil: true, numericality: true
  validates :long_depart, allow_nil: true, numericality: true
  validates :long_arrivee, allow_nil: true, numericality: true
  validates :lat_depart, presence: true, unless: :tout_vide?
  validates :lat_arrivee, presence: true, unless: :tout_vide?
  validates :long_depart, presence: true, unless: :tout_vide?
  validates :long_arrivee, presence: true, unless: :tout_vide?

  has_many :points, dependent: :delete_all
  accepts_nested_attributes_for :points
  has_and_belongs_to_many :materiels, autosave: true
  accepts_nested_attributes_for :materiels

  # permet de construire le profil en limitant le dénivelé à 1000 points
  # ce faisant, la distance parcourue est représentée sur 2000 points
  PRECISION = BigDecimal(1000)

  # teste si aucune coordonnées, même partielle, n'est fournie
  def tout_vide?
    lat_arrivee.nil? && lat_depart.nil? && long_arrivee.nil? && long_depart.nil?
  end

  # calcule la distance en mètres entre deux points dont on fournit
  # les coordonnées gps
  def distance(p1, p2)
    a = 6_378_137
    b = 6_356_752.314245
    f = 1 / 298.257223563
    l_maj = Math.to_radians((p2[1] - p1[1]))
    u_maj1 = Math.atan((1 - f) * Math.tan(Math.to_radians(p1[0])))
    u_maj2 = Math.atan((1 - f) * Math.tan(Math.to_radians(p2[0])))
    sin_u_maj1 = Math.sin(u_maj1)
    cos_u_maj1 = Math.cos(u_maj1)
    sin_u_maj2 = Math.sin(u_maj2)
    cos_u_maj2 = Math.cos(u_maj2)
    cos_sq_alpha = 0.0
    sin_sigma = 0.0
    cos2_sigma_m = 0.0
    cos_sigma = 0.0
    sigma = 0.0
    lambda = l_maj
    iter_limit = 100
    loop do
      sin_lambda = Math.sin(lambda)
      cos_lambda = Math.cos(lambda)
      sin_sigma = Math.sqrt((cos_u_maj2 * sin_lambda) * (cos_u_maj2 *
                               sin_lambda) + (cos_u_maj1 * sin_u_maj2 -
                               sin_u_maj1 * cos_u_maj2 * cos_lambda) *
                               (cos_u_maj1 * sin_u_maj2 - sin_u_maj1 *
                               cos_u_maj2 * cos_lambda))
      return 0 if sin_sigma.zero?
      cos_sigma = sin_u_maj1 * sin_u_maj2 + cos_u_maj1 * cos_u_maj2 * cos_lambda
      sigma = Math.atan2(sin_sigma, cos_sigma)
      sin_alpha = cos_u_maj1 * cos_u_maj2 * sin_lambda / sin_sigma
      cos_sq_alpha = 1 - sin_alpha * sin_alpha
      cos2_sigma_m = cos_sigma - 2 * sin_u_maj1 * sin_u_maj2 / cos_sq_alpha
      c_maj = f / 16 * cos_sq_alpha * (4 + f * (4 - 3 * cos_sq_alpha))
      lambda_p = lambda
      lambda = l_maj + (1 - c_maj) * f * sin_alpha *
                       (sigma + c_maj * sin_sigma * (cos2_sigma_m + c_maj *
                       cos_sigma * (-1 + 2 * cos2_sigma_m * cos2_sigma_m)))
      iter_limit -= 1
      break if ((lambda - lambda_p).abs < 1e-12) || (iter_limit <= 0)
    end
    return 0 if iter_limit.zero?
    u_sq = cos_sq_alpha * (a * a - b * b) / (b * b)
    a_maj = 1 + u_sq / 16_384 * (4096 + u_sq *
        (-768 + u_sq * (320 - 175 * u_sq)))
    b_maj = u_sq / 1024 * (256 + u_sq * (-128 + u_sq * (74 - 47 * u_sq)))
    delta_sigma = b_maj * sin_sigma * (cos2_sigma_m + b_maj / 4 *
                          (cos_sigma * (-1 + 2 * cos2_sigma_m * cos2_sigma_m) -
                          b_maj / 6 * cos2_sigma_m * (-3 + 4 * sin_sigma *
                          sin_sigma) * (-3 + 4 * cos2_sigma_m * cos2_sigma_m)))
    b * a_maj * (sigma - delta_sigma)
  end

  # met à jour les caractéristiques de la randonnées et construit
  # le profil après ouverture du fichier gpx
  def maj
    doc = File.open(File.join('public', 'gpx',
                               self.class == Randonnee ? 'randos' : 'treks',
                               fichier_gpx)) { |f| Nokogiri::XML(f) }
    init_trace
    @altitudes = []
    @distances_cumulees = []
    doc.xpath('//xmlns:trk').each do |trk|
      traite_altitudes(trk)
      traite_distances(trk)
    end
    calcule_heures_debut_et_fin(doc)
    calc_coord_depart_et_arrivee(doc)
    self.points.clear
    self.points = traite_profil
  end

  # initialise les données de la trace qui seront
  # mises à jour
  def init_trace
    self.altitude_minimum = 10_000
    self.altitude_maximum = -10_000
    self.ascension_totale = 0
    self.descente_totale = 0
    self.distance_totale = 0
    self.heure_debut = ''
    self.heure_fin = ''
  end

  # traite les altitudes
  def traite_altitudes(trk)
    alt = trk.xpath('.//xmlns:ele').map { |ele| ele.text.to_i }
    @altitudes += alt
    self.altitude_minimum = [altitude_minimum, alt.min].min
    self.altitude_maximum = [altitude_maximum, alt.max].max
    diff_altitudes = alt.zip(alt.drop(1))[0..-2].map { |t| t[1] - t[0] }
    self.ascension_totale += diff_altitudes.select { |dif| dif > 0 }
                                           .reduce(0, :+)
    self.descente_totale += diff_altitudes.select { |dif| dif < 0 }
                                          .reduce(0, :+).abs
  end

  # calcule et traite les distances
  def traite_distances(trk)
    trkpt = trk.xpath('.//xmlns:trkpt').map do |t|
      [BigDecimal(t.xpath('@lat').text), BigDecimal(t.xpath('@lon').text)]
    end
    distances = trkpt.zip(trkpt.drop(1))[0..-2]
                    .map { |p| distance(p[0], p[1]) }
    dist_cumulees = BigDecimal(distance_totale)
    distances.each do |d|
      dist_cumulees += d
      @distances_cumulees << dist_cumulees
    end
    self.distance_totale = dist_cumulees.to_i
  end

  # détermine les heures de début et de fin
  def calcule_heures_debut_et_fin(doc)
    times = doc.xpath('//xmlns:trkpt//xmlns:time')
    unless times.empty?
      first_time = times.first.text
      last_time = times.last.text
      self.heure_debut = DateTime.iso8601(first_time) unless first_time.blank?
      self.heure_fin = DateTime.iso8601(last_time) unless last_time.blank?
    end
  end

  # détermine les coordonnées des points de départ et d'arrivée
  def calc_coord_depart_et_arrivee(doc)
    trkpt = doc.xpath('//xmlns:trkpt')
    arrivee = trkpt.last
    depart = trkpt.first
    self.lat_depart = BigDecimal(depart.xpath('@lat').text)
    self.long_depart = BigDecimal(depart.xpath('@lon').text)
    self.lat_arrivee = BigDecimal(arrivee.xpath('@lat').text)
    self.long_arrivee = BigDecimal(arrivee.xpath('@lon').text)
  end

  # traite le profil
  def traite_profil
    reduction_alt = (altitude_maximum - altitude_minimum) / PRECISION
    altitudes_pix = @altitudes.map do |a|
      (1000 - (a - altitude_minimum) / reduction_alt).to_i
    end
    reduction_dist = distance_totale / (2 * PRECISION)
    distances_cumulees_pix = @distances_cumulees
                             .map { |a| (a / reduction_dist).to_i }.unshift(0)
    distances_cumulees_pix.zip(altitudes_pix).uniq
                          .map { |c| Point.new(distance: c[0], altitude: c[1]) }
  end

  private :distance, :init_trace, :traite_altitudes, :traite_distances,
          :calcule_heures_debut_et_fin, :calc_coord_depart_et_arrivee, :traite_profil
end
