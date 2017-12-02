require 'test_helper'
class MadateTest < ActiveSupport::TestCase
  test"Ecart entre 1/1/2017 et 2/1/2017 est 1 jour" do
    assert_equal "1 jour", Madate.new(1, 1, 2017).ecart(2, 1, 2017)
  end
  test "Ecart entre 1/1/2017 et 3/1/2017 est 2 jours" do
    assert_equal  "2 jours",Madate.new(1, 1, 2017).ecart(3, 1, 2017)
  end
  test "Ecart entre 1/1/2017 et 1/2/2017 est 1 mois" do
    assert_equal "1 mois",  Madate.new(1, 1, 2017).ecart(1, 2, 2017)
  end
  test "Ecart entre 1/1/2017 et 3/2/2017 est 1 mois 2 jours" do
    assert_equal "1 mois 2 jours",  Madate.new(1, 1, 2017).ecart(3, 2, 2017)
  end
  test "Ecart entre 28/1/2017 et 2/2/2017 est 5 jours" do
    assert_equal "5 jours", Madate.new(28, 1, 2017).ecart(2, 2, 2017)
  end
  test "Ecart entre 28/12/2017 et 2/1/2018 est 5 jours" do
    assert_equal "5 jours",  Madate.new(28, 12, 2017).ecart(2, 1, 2018)
  end
  test "Ecart entre 28/11/2017 et 2/2/2018 est 2 mois 5 jours" do
    assert_equal "2 mois 5 jours", Madate.new(28, 11, 2017).ecart(2, 2, 2018)
  end
  test "Ecart entre 28/2/2017 et 3/3/2017 est 3 jours" do
    assert_equal  "3 jours", Madate.new(28, 2, 2017).ecart(3, 3, 2017)
  end
  test "Ecart entre 28/4/2017 et 3/5/2017 est 5 jours" do
    assert_equal  "5 jours", Madate.new(28, 4, 2017).ecart(3, 5, 2017)
  end
  test "Ecart en 30/11/2017 et 1/12/2017 est 1 jour" do
    assert_equal "1 jour", Madate.new(30, 11, 2017).ecart(1,12,2017)
  end
end