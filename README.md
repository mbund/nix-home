# nix-home
My dotfiles and home conguration, using [home-manager](https://github.com/nix-community/home-manager). This *should* work on macOS as well with minimal changes, but it is only tested with [NixOS 21.11](https://nixos.org). Check out [my NixOS config](https://github.com/mbund/nixos-config) to see how I set it up in conjunction with this home configuration.

We like to eat pie; do you!? asjfaf gsfhjagsf asgfhj agshfjgahfgfewyuq dasf hega fhjsdajfb asdkjfbh aksdgyfe hjasdgf ja.

## Structure: taking flakes to the max
Flake inputs can be simplified by splitting up the root flake into multiple subflakes. This makes it much more readable and puts the inputs to flakes where they are actually used instead of polluting the root flake. Take a look at my home-manager configuration:
```nix
# flake.nix
inputs = {
  nixpkgs.url = "nixpkgs/nixpkgs-unstable";

  home-manager = {
    url = "github:nix-community/home-manager";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  cli.url = "./cli";
};
```
`cli` is a subflake where I configure my shell, with its inputs looking something like this:
```nix
# cli/flake.nix
inputs = {
  nixpkgs.url = "nixpkgs/nixpkgs-unstable";

  zsh-syntax-highlighting = {
    url = "github:zsh-users/zsh-syntax-highlighting";
    flake = false;
  };
};
```
Here, my `zsh` plugin, `zsh-syntax-highlighting`, is a flake input. We can use flake inputs to replace littering the code with `pkgs.fetchFromGithub`, take advantage of flake pinning, and consolidate outside dependencies into where they belong.

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
