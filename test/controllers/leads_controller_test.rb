require 'test_helper'

class LeadsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get leads_new_url
    assert_response :success
  end

  test "should get edit" do
    get leads_edit_url
    assert_response :success
  end

  test "should get index" do
    get leads_index_url
    assert_response :success
  end

end
