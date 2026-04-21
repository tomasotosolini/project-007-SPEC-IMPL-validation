class XlSimulator
  SEED = [
    Domu.new(name: "web-01",  vcpus: 2, memory_mb: 2048,  disk_gb: 20,  nic_type: "NAT",       status: "running"),
    Domu.new(name: "db-01",   vcpus: 4, memory_mb: 8192,  disk_gb: 100, nic_type: "BRIDGED",    status: "running"),
    Domu.new(name: "dev-box", vcpus: 1, memory_mb: 1024,  disk_gb: 10,  nic_type: "HOST ONLY",  status: "idle"),
    Domu.new(name: "backup",  vcpus: 1, memory_mb: 512,   disk_gb: 50,  nic_type: nil,           status: "idle")
  ].freeze

  @@registry = SEED.map(&:dup)

  def self.registry
    @@registry
  end

  def self.reset!
    @@registry = SEED.map(&:dup)
  end

  def self.configured_list
    @@registry.dup
  end

  def self.running_list
    @@registry.select { |d| d.status == "running" }.map do |d|
      { domu: d, cpu_percent: simulated_cpu(d), memory_used_mb: simulated_memory(d) }
    end
  end

  def self.simulated_cpu(domu)
    (domu.name.bytes.sum % 71) + 5
  end

  def self.simulated_memory(domu)
    ((domu.name.bytes.sum % 60) / 100.0 * domu.memory_mb + domu.memory_mb * 0.15).round
  end
end
