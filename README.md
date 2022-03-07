![License](https://img.shields.io/github/license/mbund/nix-home?color=dgreen&style=flat-square) ![Size](https://img.shields.io/github/repo-size/mbund/nix-home?color=red&label=size&style=flat-square) [![NixOS](https://img.shields.io/badge/nixpkgs-unstable-9cf.svg?style=flat-square&logo=NixOS&logoColor=white)](https://nixos.org)  

## About
My dotfiles and home conguration, using [home-manager](https://github.com/nix-community/home-manager). This *should* work on macOS as well with minimal changes, but it is only tested with [NixOS 21.11](https://nixos.org). Check out [my NixOS config](https://github.com/mbund/nixos-config) to see how I set it up in conjunction with this home configuration.

## Structure: taking flakes to the max
Flake inputs can be simplified by splitting up the root flake into multiple subflakes. This makes it much more readable and puts the external inputs to flakes where they are actually used instead of polluting the root flake. In my root flake I define all my subflakes, one for each user, and one for each component. I then pass every input along to the users, who can generate their required `homeConfigurations` which `home-manager` expects.

To explain it with code:
```nix
# root flake.nix
{
  inputs = {
    # users
    mbund.url = "./mbund";

    # components
    common.url = "./common";
    cli.url = "./cli";
    firefox.url = "./firefox";
  };
  
  outputs = { self, mbund, ... }@inputs: {
    homeConfigurations = mbund.genHomeConfigurations inputs;
  };
}
```
```nix
# mbund/flake.nix
{
  description = "mbund's home-manager configuration for all systems";

  inputs = {
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };
  
  outputs = { self, nixpkgs, home-manager, ... }@mbund-inputs:
    let
      pkgs = import nixpkgs { system = "x86_64-linux"; };
    in {
      
      genHomeConfigurations = parentInputs: {
      
        "mbund@mbund-desktop" = home-manager.lib.homeManagerConfiguration {
          system = "x86_64-linux";
          stateVersion = "21.11";
          homeDirectory = "/home/mbund";
          username = "mbund";
          configuration = { config, ... }: ({
          
            # We can now use the parentInputs to access our neighboring `cli/flake.nix`,
            # for example and import it here for composability
            imports = with parentInputs; [
              common.home
              cli.home
              firefox.home
            ];
            
            # otherwise this is a normal home-manager configuration at this point...
            home.packages = with pkgs; [
              htop
            ];
            
          });
        };
        
      };
      
    };
}
```

Now that we can isolate everything into flakes a subflakes, we can use flake inputs to replace littering the code with `pkgs.fetchFromGithub`, take advantage of flake pinning, and generally just consolidate outside dependencies into where they belong.

## Before you install
To run the installation, `git` must be installed and the **experimental nix commands must be enabled**. On NixOS you would set something like this in your configuration.
```nix
nix.extraOptions = ''
    # enable the new standalone nix commands
    experimental-features = nix-command flakes
'';
```
If you're on a barebones NixOS without even git, then run `nix shell nixpkgs#git` before proceding with the installation.

## Installation
Clone the repository and make edits to the root `flake.nix` file to something like this, replacing `MY_USERNAME` and `MY_ARCHITECTURE_AND_OPERATING_SYSTEM` as necessary. Note that your `MY_USERNAME` must be an actual user on the system.
```nix
MY_USERNAME = inputs.home-manager.lib.homeManagerConfiguration {
    system = "MY_ARCHITECTURE_AND_OPERATING_SYSTEM";
    homeDirectory = "/home/MY_USERNAME";
    username = "MY_USERNAME";
    ...
```
Likely values for `MY_ARCHITECTURE_AND_OPERATING_SYSTEM` are as follows, along with examples for what platforms they are probably for:
```nix
x86_64-linux   # NixOS or really any other linux distro
aarch64-darwin # M1 macbooks
x86_64-darwin  # Intel macbooks
aarch64-linux  # Raspberry pi
```

Then run this command once while in the directory of the repository to initialize your home-manager. Replace `MY_USERNAME` with what you set above.
```
nix run home-manager --no-write-lock-file -- switch --flake .#MY_USERNAME
```
In total it could look something like this
```
git clone https://github.com/mbund/nix-home
cd nix-home
...make your edits...
nix run home-manager --no-write-lock-file -- switch --flake .#MY_USERNAME
```

## Updating
Any time you make changes to the home configuration files (after it has been installed) just run (while in the directory of the repository):
```
home-manager switch --flake .#MY_USERNAME
```

## Good to know
Home-manager still uses `nix-env` and not the new `nix profile`, so the `nix profile` family of commands will not work. Check out [this awesome blog post](https://blog.ysndr.de/posts/guides/2021-12-01-nix-shells) to learn more about the new nix commands.
