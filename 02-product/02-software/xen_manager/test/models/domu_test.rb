require "test_helper"

class DomuTest < ActiveSupport::TestCase
  test "can be constructed with all attributes" do
    d = Domu.new(name: "vm-1", vcpus: 2, memory_mb: 1024, disk_gb: 20, nic_type: "NAT", status: "running")
    assert_equal "vm-1",    d.name
    assert_equal 2,         d.vcpus
    assert_equal 1024,      d.memory_mb
    assert_equal 20,        d.disk_gb
    assert_equal "NAT",     d.nic_type
    assert_equal "running", d.status
  end

  test "nic_type can be nil" do
    d = Domu.new(name: "vm-2", vcpus: 1, memory_mb: 512, disk_gb: 4, nic_type: nil, status: "idle")
    assert_nil d.nic_type
  end

  test "status can be idle" do
    d = Domu.new(name: "vm-3", vcpus: 1, memory_mb: 512, disk_gb: 4, nic_type: nil, status: "idle")
    assert_equal "idle", d.status
  end
end
