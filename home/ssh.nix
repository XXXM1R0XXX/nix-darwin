{...}: {
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    
    matchBlocks = {
      "*" = {
        # Automatically add keys to agent
        addKeysToAgent = "yes";
        # TODO: Update this path if your SSH key has a different name
        # Generate a new key with: ssh-keygen -t ed25519 -C "your_email@example.com"
        identityFile = "~/.ssh/id_ed25519";
        
        # macOS-specific option to save passphrase in Keychain
        extraOptions = {
          UseKeychain = "yes";
        };
      };
    };
  };
}
