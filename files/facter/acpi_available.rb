# return whether acpi is available -- used for desiding whether to install the munin plugin
Facter.add("acpi_available") do
	setcode do
		if `acpi -t -B -A 2>/dev/null`.match(/\d/).nil? 
			"false"
		else
			"true"
		end
	end
end
