require "test_helper"

class XlSimulatorTest < ActiveSupport::TestCase
  setup    { XlSimulator.reset! }
  teardown { XlSimulator.reset! }

  test "configured_list returns all seeded domus" do
    list = XlSimulator.configured_list
    assert_equal 4, list.size
    assert list.all? { |d| d.is_a?(Domu) }
  end

  test "configured_list includes both idle and running domus" do
    list = XlSimulator.configured_list
    assert list.any? { |d| d.status == "running" }
    assert list.any? { |d| d.status == "idle" }
  end

  test "running_list returns only running domus" do
    list = XlSimulator.running_list
    assert list.all? { |e| e[:domu].status == "running" }
  end

  test "running_list entries include cpu_percent and memory_used_mb keys" do
    entry = XlSimulator.running_list.first
    assert entry.key?(:domu)
    assert entry.key?(:cpu_percent)
    assert entry.key?(:memory_used_mb)
  end

  test "running_list cpu_percent is a positive integer" do
    XlSimulator.running_list.each do |entry|
      assert entry[:cpu_percent].is_a?(Integer)
      assert entry[:cpu_percent] >= 0
    end
  end

  test "running_list memory_used_mb is positive and does not exceed allocated memory" do
    XlSimulator.running_list.each do |entry|
      assert entry[:memory_used_mb] > 0
      assert entry[:memory_used_mb] <= entry[:domu].memory_mb
    end
  end

  test "configured_list returns a copy — mutations do not affect registry" do
    XlSimulator.configured_list.clear
    assert_equal 4, XlSimulator.configured_list.size
  end
end
