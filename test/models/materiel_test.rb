require 'test_helper'
class MaterielTest < ActiveSupport::TestCase
  test "nom obligatoire" do
    @materiel = Materiel.new(description: 'description', photo: 'photo', poids: 120, reforme: false)
    assert_not @materiel.save
  end
  test "description ogligatoire" do
    @materiel = Materiel.new(nom: 'nom', photo: 'photo', poids: 120, reforme: false)
    assert_not @materiel.save
  end
  test "photo ogligatoire" do
    @materiel = Materiel.new(nom: 'nom', description: 'description', poids: 120, reforme: false)
    assert_not @materiel.save
  end
  test "poids ogligatoire" do
    @materiel = Materiel.new(nom: 'nom', description: 'description', photo: 'photo', reforme: false)
    assert_not @materiel.save
  end
  test "poids numérique" do
    @materiel = Materiel.new(nom: 'nom', description: 'description', photo: 'photo', poids: 'poids', reforme: false)
    assert_not @materiel.save
  end
  test "poids numérique positif" do
    @materiel = Materiel.new(nom: 'nom', description: 'description', photo: 'photo', poids: 0, reforme: false)
    assert_not @materiel.save
  end

  def setup
    @materiel = Materiel.new
  end

  test "Description courte de '&acute;' est 'é'" do
    @materiel.description = '&eacute;'
    assert_equal 'é', @materiel.description_courte
  end
  test"Description courte d'un texte long termine par '...''" do
    @materiel.description = 'a' * 120 + ' '
    assert_equal '...', @materiel.description_courte[-3..-1]
  end
  test "Description courte d'un texte de 120 caractères ne termine pas par '...'" do
    @materiel.description = 'a' * 119 + ' '
    assert_not_equal '...', @materiel.description_courte[-3..-1]
  end
end