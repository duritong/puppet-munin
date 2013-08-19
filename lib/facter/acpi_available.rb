# return whether acpi is available -- used for deciding whether to install the munin plugin
Facter.add("acpi_available") do
    setcode do
    	if not Facter::Util::Resolution.which('acpi') or `acpi -t -B -A 2>/dev/null`.match(/\d/).nil?
    		"absent"
    	else
    		"present"
    	end
    end
end
