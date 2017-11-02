require 'test_helper'

class TraceTest < ActiveSupport::TestCase
  setup do
    @rando = Randonnee.new(fichier_gpx: '2017-08-12_09:08:31.GPX')
    @rando.maj
  end
  test "l'altitude minimum est 1238 m" do
    assert_equal 1013, @rando.altitude_minimum
  end
  test "l'altitude maximum est 2449 m" do
    assert_equal 1356, @rando.altitude_maximum
  end
  test "l'heure de début est Fri, 11 Aug 2017 11:05:26 UTC +00:00" do
    assert_equal DateTime.parse('Fri, 11 Aug 2017 11:05:26 UTC +00:00'), @rando.heure_debut
  end
  test "l'heure de fin est Fri, 11 Aug 2017 15:02:30 UTC +00:00" do
    assert_equal DateTime.parse('Fri, 11 Aug 2017 15:02:30 UTC +00:00'), @rando.heure_fin
  end
  test "l'ascension totale est 503" do
    assert_equal 505, @rando.ascension_totale
  end
  test "la descente totale est 287" do
    assert_equal 289, @rando.descente_totale
  end
  test "la distance parcourue est 12533" do
    assert_equal 12533, @rando.distance_totale
  end
  test "les coordonnées de départ sont [0.42642169464379549e2, -0.107746180146933e0]" do
    assert_equal [0.42642169464379549e2.to_f, -0.107746180146933e0.to_f],
                 [@rando.lat_depart.to_f, @rando.long_depart.to_f]
  end
  test "les coordonnées d'arrivée sont [0.42677340265363455e2, -0.123980417847633e0]" do
    assert_equal [0.42677340265363455e2.to_f, -0.123980417847633e0.to_f],
                 [@rando.lat_arrivee.to_f, @rando.long_arrivee.to_f]
  end
  test "le nombre de coordonnees est 524" do
    assert_equal 524, @rando.points.size
  end
end
