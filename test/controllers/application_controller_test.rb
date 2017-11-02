require 'test_helper'

class ApplicationControllerTest < ActionDispatch::IntegrationTest
  test 'should get application index' do
    get root_path
    assert_response :success
    assert_select 'a', 6
    assert_select 'img', 1
    assert_select 'button', 4
  end
end
