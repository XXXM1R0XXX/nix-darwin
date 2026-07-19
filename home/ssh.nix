{...}: {
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    settings."*" = {
      # Automatically add keys to agent
      AddKeysToAgent = "yes";
      # TODO: Update this path if your SSH key has a different name
      # Generate a new key with: ssh-keygen -t ed25519 -C "your_email@example.com"
      IdentityFile = "~/.ssh/id_ed25519";

      # macOS-specific option to save passphrase in Keychain
      UseKeychain = "yes";
    };
  };
}
