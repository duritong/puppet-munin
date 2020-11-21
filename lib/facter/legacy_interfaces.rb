# return the set of active interfaces as an array
Facter.add("legacy_interfaces") do
  setcode do
    `ip -o link show`.split(/\n/).collect do |line|
      matches = line.match(/^\d*: ([^:]*): <(.*,)?UP(,.*)?>/)
      if !matches.nil?
        matches[1].split('@',2).first
      else
        nil
      end
    end.compact.sort.join(',')
  end
end
