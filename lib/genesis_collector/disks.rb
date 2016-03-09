module GenesisCollector
  module Disks

    def collect_disks
      @payload[:disks] = enumerate_disks
      @payload[:disks].each do |d|
        info = get_disk_info(d.delete(:smartctl_cmd))
        d[:vendor_name] = info.match(/^Vendor:\s+(.*)$/)[1] rescue nil
        d[:vendor_name] ||= info.match(/^Device Model:\s+(\w+)[_ ](?:.*)$/)[1] rescue nil
        d[:product] = info.match(/^(?:Device Model|Product):\s+(.*)$/)[1]
        d[:serial_number] = info.match(/^Serial (?:n|N)umber:\s+(.*)$/)[1]
        d[:size] = info.match(/^User Capacity:\s+(.*)$/)[1].split('bytes')[0].strip.gsub(',', '')
      end
    end

    private

    def enumerate_disks
      raw = shellout_with_timeout('smartctl --scan').strip
      raw.split("\n").map do |line|
        parts = line.split('#')
        {
          smartctl_cmd: parts[0].gsub('-d scsi', '').strip,
          dev: parts[1].split(',')[0].strip.split(' ')[0],
          kind: parts[1].split(',')[1].strip
        }
      end
    end

    def get_disk_info(cmd_params)
      shellout_with_timeout("smartctl -i #{cmd_params}")
    end

  end
end