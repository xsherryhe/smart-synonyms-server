require "test_helper"

class WordsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get words_show_url
    assert_response :success
  end
end
