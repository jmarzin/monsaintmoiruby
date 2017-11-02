require "application_system_test_case"

class RootsTest < ApplicationSystemTestCase
  test 'Le menu contient monSaintMoi' do
    visit materiels_url
    assert has_link? 'monSaintMoi'
  end

  test "Le lien du menu monSaintMoi renvoit à la page d'accueil" do
    visit materiels_url
    click_link 'monSaintMoi'
    assert page.has_content? 'Petit départ'
  end

  test 'Le menu contient Matériels' do
    visit root_url
    assert has_link? 'Matériels'
  end

  test 'Le lien du menu Matériels renvoit à la liste des matériels' do
    visit root_url
    click_link 'Matériels'
    assert page.has_content? 'Poids total du sac'
    # assert_selector ''
    assert page.find('li.active.nav-item').has_link? 'Matériels'
  end
end
