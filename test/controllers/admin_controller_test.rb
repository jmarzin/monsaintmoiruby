require 'test_helper'

class AdminControllerTest < ActionDispatch::IntegrationTest
  test 'Route GET for admin exists' do
    assert_routing '/admin', controller: 'admin', action: 'password'
  end

  test 'Should get password' do
    get admin_url
    assert_response :success
    assert_select "input:match('name', ?)", /password/
  end

  test 'Route POST for admin exists' do
    assert_routing({ method: 'post', path: '/admin' }, { controller: "admin", action: "check_password" })
  end

  test 'Should post password' do
    post admin_url, params: { password: '51julie2' }
    assert_redirected_to root_path
    assert_equal 'Vous êtes administrateur', flash[:notice]
  end

  test 'Notice error password' do
    post admin_url, params: {password: ''}
    assert_equal 'Erreur de saisie', flash[:alert]
  end

  test 'Admin in session' do
    post admin_url, params: {password: ''}
    assert_nil session[:admin]
    post admin_url, params: {password: '51julie2'}
    assert_equal true, session[:admin]
  end
end
