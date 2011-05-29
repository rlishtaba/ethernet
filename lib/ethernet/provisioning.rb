require 'rbconfig'


# :nodoc: namespace
module Ethernet

# Setup issues such as assigning permissions for Ethernet-level transmission.
module Provisioning
  @platform = Config::CONFIG['target_os']
  def self.platform
    @platform
  end
  
  # Allow non-root users to create low-level Ethernet sockets.
  #
  # This is a security risk, because Ethernet sockets can be used to spy on all
  # traffic on the machine's network. This should not be called on production
  # machines.
  #
  # Returns true for success, false otherwise. If the call fails, it is most
  # likely because it is not run by root / Administrator.
  def self.usermode_sockets
    case platform
    when /darwin/
      return false unless Kernel.system("chmod o+rw /dev/bpf*")
    when /linux/
      ruby = File.join Config::CONFIG['bindir'],
                       Config::CONFIG['ruby_install_name']
      unless Kernel.system("setcap 'CAP_NET_RAW+eip CAP_NET_ADMIN+eip' #{ruby}")
        return false
      end
      
      # Try to enable Wireshark packet capture for debugging.
      # No big deal if this fails.
      dumpcap = '/usr/bin/dumpcap'
      if File.exist? dumpcap
        Kernel.system("setcap 'CAP_NET_RAW+eip CAP_NET_ADMIN+eip' #{dumpcap}")
      end
    when /win/
      # NOTE: this might not work
      return false unless Kernel.system("sc config npf start= auto")
    else
      raise "Unsupported os #{Ethernet::Provisioning.platform}"
    end
    true
  end
end  # class Ethernet::Provisioning

end  # namespace Ethernet
