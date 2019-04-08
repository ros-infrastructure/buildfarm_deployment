Facter.add(:busid) do
  setcode do
    Facter::Core::Execution.execute('nvidia-xconfig --query-gpu-info  | grep BusID | sed "s/.*PCI:/PCI:/g"')
  end
end
