require "test_helper"

class DomusControllerTest < ActionDispatch::IntegrationTest
  setup    { XlSimulator.reset! }
  teardown { XlSimulator.reset! }

  test "unauthenticated request redirects to login" do
    get root_path
    assert_redirected_to login_path
  end

  test "admin can access listing" do
    log_in_as(:admin_user, "root")
    get root_path
    assert_response :success
  end

  test "user role can access listing" do
    log_in_as(:normal_user, "normalpass")
    get root_path
    assert_response :success
  end

  test "guest role can access listing" do
    log_in_as(:guest_user, "guestpass")
    get root_path
    assert_response :success
  end

  test "page contains Running section heading" do
    log_in_as(:admin_user, "root")
    get root_path
    assert_select "h2", text: "Running"
  end

  test "page contains Configured section heading" do
    log_in_as(:admin_user, "root")
    get root_path
    assert_select "h2", text: "Configured"
  end

  test "configured table shows all domus" do
    log_in_as(:admin_user, "root")
    get root_path
    XlSimulator.configured_list.each do |domu|
      assert_select "td", text: domu.name
    end
  end

  test "running table shows cpu_percent column header" do
    log_in_as(:admin_user, "root")
    get root_path
    assert_select "th", text: "CPU %"
  end

  test "session expiry redirects to login" do
    log_in_as(:admin_user, "root")
    travel_to 61.minutes.from_now do
      get root_path
      assert_redirected_to login_path
    end
  end

  private

  def log_in_as(fixture_key, password)
    post login_path, params: { username: users(fixture_key).username, password: password }
  end
end
