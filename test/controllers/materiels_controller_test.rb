require 'test_helper'

class Dir
  def self.initialise(r)
    @tableau = r
  end

  def self.entries(*_r)
    @tableau
  end
end

class MaterielsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @materiel = materiels(:matos1)
  end

  test 'should get index with 2 materials' do
    get materiels_url
    assert_response :success
    assert_select 'div.col-md-4', 2
  end

  test 'should get index with 3 materials' do
    Materiel.new(nom: 'nom', description: 'desc', photo: 'photo', poids: 1, reforme: false).save
    get materiels_url
    assert_response :success
    assert_select 'div.col-md-4', 3
  end

  test 'new material only accessible to admin' do
    get new_materiel_url
    assert_redirected_to materiels_path
    assert_equal "Vous n'êtes pas administrateur", flash[:notice]
  end

  test 'should get new materiel' do
    post admin_url, params: { password: '51julie2' }
    Dir.initialise(['0pasdimage.jpg', 'une_autre_photo.jpg', 'encore_une.jpg'])
    get new_materiel_url
    assert_response :success
    assert_select 'option', 2
    Dir.initialise(['0pasdimage.jpg', 'une_autre_photo.jpg'])
    get new_materiel_url
    assert_response :success
    assert_select 'option', 1
  end

  test 'should create materiel' do
    post admin_url, params: { password: '51julie2' }
    assert_difference('Materiel.count') do
      post materiels_url, params: { materiel: { nom: 'nom',
                                                description: 'desc',
                                                photo: 'photo',
                                                poids: '1',
                                                reforme: false } }
    end
    assert_redirected_to materiel_url(Materiel.last)
  end

  test 'should show materiel' do
    get materiel_url(@materiel)
    assert_response :success
    assert_select 'h3', 'materiel 1'
  end

  test 'non admin should not get edit materiel' do
    get edit_materiel_url(@materiel)
    assert_redirected_to @materiel
    assert_equal "Vous n'êtes pas administrateur", flash[:notice]
  end

  test 'admin should get edit materiel' do
    post admin_url, params: { password: '51julie2' }
    Dir.initialise(['0pasdimage.jpg', 'une_autre_photo.jpg', 'encore_une.jpg'])
    get edit_materiel_url(@materiel)
    assert_response :success
  end

  test 'should update materiel' do
    patch materiel_url(@materiel), params: { materiel: {} }
    assert_redirected_to materiel_url(@materiel)
  end

  test 'non admin should not destroy materiel' do
    delete materiel_url(@materiel)
    assert_redirected_to @materiel
    assert_equal "Vous n'êtes pas administrateur", flash[:notice]
  end

  test 'admin should destroy materiel' do
    post admin_url, params: { password: '51julie2' }
    assert_difference('Materiel.count', -1) do
      delete materiel_url(@materiel)
    end
    assert_redirected_to materiels_url
  end
end
