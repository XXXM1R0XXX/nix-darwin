{...}: {
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    
    matchBlocks = {
      "*" = {
        # Автоматически добавлять ключи в агент
        addKeysToAgent = "yes";
        # Укажите путь к вашему ключу
        identityFile = "~/.ssh/id_ed25519";
        
        # Специфичная опция для macOS, чтобы сохранять пароль в Keychain
        extraOptions = {
          UseKeychain = "yes";
        };
      };
    };
  };
}
