require "test_helper"

class SpectatorControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get spectator_index_url
    assert_response :success
  end

  test "should get show" do
    get spectator_show_url
    assert_response :success
  end

  test "should get track" do
    get spectator_track_url
    assert_response :success
  end
end
