require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "GET /login renders login form" do
    get login_path
    assert_response :success
  end

  test "GET /login redirects to root if already authenticated" do
    log_in_as(:admin_user)
    get login_path
    assert_redirected_to root_path
  end

  test "POST /login with valid credentials establishes session and redirects to root" do
    post login_path, params: { username: "root", password: "root" }
    assert_redirected_to root_path
    assert session[:user_id].present?
  end

  test "POST /login with wrong password re-renders login with error" do
    post login_path, params: { username: "root", password: "wrong" }
    assert_response :unprocessable_entity
    assert_select "p", "login failed"
    assert_nil session[:user_id]
  end

  test "POST /login with unknown username re-renders login with error" do
    post login_path, params: { username: "nobody", password: "x" }
    assert_response :unprocessable_entity
    assert_select "p", "login failed"
  end

  test "POST /login with missing fields re-renders login with error" do
    post login_path, params: { username: "", password: "" }
    assert_response :unprocessable_entity
    assert_select "p", "login failed"
  end

  test "DELETE /logout clears session and redirects to login" do
    log_in_as(:admin_user)
    delete logout_path
    assert_redirected_to login_path
    assert_nil session[:user_id]
  end

  test "DELETE /logout without active session redirects to login" do
    delete logout_path
    assert_redirected_to login_path
  end

  test "authenticated request reaches protected page" do
    log_in_as(:admin_user)
    get root_path
    assert_response :success
  end

  test "session expires after 60 minutes of inactivity" do
    log_in_as(:admin_user)
    travel_to 61.minutes.from_now do
      get root_path
      assert_redirected_to login_path
    end
  end

  test "session remains valid within 60 minutes of activity" do
    log_in_as(:admin_user)
    travel_to 59.minutes.from_now do
      get root_path
      assert_response :success
    end
  end

  private

  def log_in_as(fixture_key)
    password = fixture_key == :admin_user ? "root" : "guestpass"
    post login_path, params: { username: users(fixture_key).username, password: password }
  end
end
