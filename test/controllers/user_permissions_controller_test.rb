require 'test_helper'

class UserPermissionsControllerTest < ActionDispatch::IntegrationTest
  test "should get edit" do
    get user_permissions_edit_url
    assert_response :success
  end

end
