# immerda 
module Puppet::Parser::Functions
    newfunction(:muninport, :type => :rvalue) do |args|
        args[0]+65400
    end
end

