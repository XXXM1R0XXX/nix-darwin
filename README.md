# nix-darwin

This repository contains a nix-darwin configuration with font management.

## Features

- **Font Management**: Automatically installs custom fonts using nix-darwin
- **CI/CD**: GitHub Actions workflow for testing on macOS
- **Home Manager Integration**: User environment configuration

## Files

- `flake.nix`: Main nix-darwin configuration with font packages
- `home.nix`: Home Manager user configuration  
- `.github/workflows/macos-nix-darwin.yml`: CI workflow for testing font installation

## GitHub Workflow

The workflow automatically:

1. Installs Nix and nix-darwin on macOS runners
2. Builds and applies the nix-darwin configuration
3. Verifies font installation success
4. Optimizes execution time with caching and cleanup

### Manual Testing

You can manually trigger the workflow with debug mode:

1. Go to Actions tab in GitHub
2. Select "macOS nix-darwin Font Installation" workflow
3. Click "Run workflow"
4. Enable debug mode for detailed logging

## Usage

To use this configuration locally:

```bash
# Clone the repository
git clone https://github.com/XXXM1R0XXX/nix-darwin.git
cd nix-darwin

# Apply the configuration (requires nix-darwin installed)
darwin-rebuild switch --flake .#nihilist
```

## Font Configuration

The configuration includes fonts specified in the `fonts.packages` section of `flake.nix`. In CI, public fonts (Fira Code, JetBrains Mono) are used for testing, while the original configuration references a private font repository.