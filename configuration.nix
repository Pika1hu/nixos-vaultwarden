  # Self-hosted Vaultwarden (Bitwarden-compatible password manager)
  # behind a Caddy reverse proxy with HTTPS on the local network.
  #
  # Setup:
  # 1. Replace YOUR_SERVER_IP with your server's LAN IP (3 places)
  # 2. Run: sudo nixos-rebuild switch
  # 3. Open https://YOUR_SERVER_IP and create your account

  services.vaultwarden = {
    enable = true;
    config = {
      # Listen only on localhost, Caddy forwards traffic here
      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = 8222;

      # CHANGE ME: replace YOUR_SERVER_IP with the LAN IP of your server
      # Example: 192.168.1.50 (find it with `ip a` on the server or in your router settings)
      DOMAIN = "https://YOUR_SERVER_IP";

      # Signups are disabled so nobody else can register.
      # To create your first account: set this to true, rebuild,
      # register, then set it back to false and rebuild again.
      SIGNUPS_ALLOWED = false;
    };
  };

  services.caddy = {
    enable = true;

    # CHANGE ME: same IP as above
    # HTTP (port 80): lets you download Caddy's root certificate from
    # http://YOUR_SERVER_IP/.local/share/caddy/pki/authorities/local/root.crt
    # Add it to your browser or phone as a trusted certificate,
    # otherwise HTTPS shows a security warning.
    # (Firefox has its own certificate store, import it there separately.)
    virtualHosts."http://YOUR_SERVER_IP" = {
      extraConfig = ''
        root * /var/lib/caddy
        file_server
      '';
    };

    # CHANGE ME: same IP as above
    # HTTPS (port 443): "tls internal" means Caddy signs the certificate
    # with its own local CA, then proxies requests to Vaultwarden.
    virtualHosts."https://YOUR_SERVER_IP" = {
      extraConfig = ''
        tls internal
        reverse_proxy 127.0.0.1:8222
      '';
    };
  };

  # Open ports 80 (HTTP) and 443 (HTTPS)
  networking.firewall.allowedTCPPorts = [ 80 443 ];

  # Bitwarden app / browser extension:
  # On the login screen tap the server selector (bitwarden.com),
  # choose "Self-hosted", set Server URL to https://YOUR_SERVER_IP,
  # then log in with your account.

}
