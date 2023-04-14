{ config, pkgs, ... }:

{
  imports =
    [ # Include the NixOS hardware configuration
      ./hardware-configuration.nix
    ];

  # Set your hostname here
  networking.hostName = "my-backend-dev-machine";

  # Configure your network interfaces here
  networking.interfaces.eth0.useDHCP = true;

  # Set up SSH access for remote administration
  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDGa4n2..."
  ];

  # Install and configure the NGINX web server
  services.nginx.enable = true;
  services.nginx.virtualHosts."example.com" = {
    locations."/" = {
      proxyPass = "http://localhost:3000";
      proxyWebsockets = true;
    };
  };

  # Install and configure the PostgreSQL database
  services.postgresql.enable = true;
  services.postgresql.package = pkgs.postgresql13;
  services.postgresql.extraPlugins = [ pkgs.postgresql_plugins.postgis ];
  services.postgresql.enableTCPIP = true;
  services.postgresql.authentication = ''
    local   all             all                                     trust
    host    all             all             127.0.0.1/32            trust
    host    all             all             ::1/128                 trust
  '';
  services.postgresql.initialScript = ''
    CREATE ROLE myuser LOGIN PASSWORD 'mypassword';
    CREATE DATABASE mydb OWNER myuser;
  '';

  # Install and configure Node.js and npm
  environment.systemPackages = with pkgs; [
    nodejs
    npm
  ];

  # Set up a user account for development work
  users.users.myuser = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    home = "/home/myuser";
    shell = "/usr/bin/bash";
    uid = 1000;
    gid = 100;
  };
}
