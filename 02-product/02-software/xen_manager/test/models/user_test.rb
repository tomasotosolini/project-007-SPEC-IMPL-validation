require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "valid user with all fields" do
    u = User.new(username: "alice", password: "secret", role: "user")
    assert u.valid?
  end

  test "requires username" do
    u = User.new(password: "secret", role: "user")
    assert_not u.valid?
    assert_includes u.errors[:username], "can't be blank"
  end

  test "requires unique username" do
    User.create!(username: "bob", password: "secret", role: "guest")
    u = User.new(username: "bob", password: "other", role: "guest")
    assert_not u.valid?
    assert_includes u.errors[:username], "has already been taken"
  end

  test "requires role" do
    u = User.new(username: "carol", password: "secret")
    assert_not u.valid?
  end

  test "rejects unknown role" do
    u = User.new(username: "dave", password: "secret", role: "superuser")
    assert_not u.valid?
    assert_includes u.errors[:role], "is not included in the list"
  end

  test "requires password" do
    u = User.new(username: "eve", role: "guest")
    assert_not u.valid?
  end

  test "authenticates with correct password" do
    u = User.create!(username: "frank", password: "mypass", role: "user")
    assert u.authenticate("mypass")
  end

  test "does not authenticate with wrong password" do
    u = User.create!(username: "grace", password: "mypass", role: "user")
    assert_not u.authenticate("wrong")
  end

  test "guest can MONITOR only" do
    u = User.new(role: "guest")
    assert u.can?("MONITOR")
    assert_not u.can?("ACTIVATOR")
    assert_not u.can?("CREATOR")
    assert_not u.can?("EDITOR")
  end

  test "user can MONITOR and ACTIVATOR" do
    u = User.new(role: "user")
    assert u.can?("MONITOR")
    assert u.can?("ACTIVATOR")
    assert_not u.can?("CREATOR")
    assert_not u.can?("EDITOR")
  end

  test "admin can all entitlements" do
    u = User.new(role: "admin")
    assert u.can?("MONITOR")
    assert u.can?("ACTIVATOR")
    assert u.can?("CREATOR")
    assert u.can?("EDITOR")
  end
end
