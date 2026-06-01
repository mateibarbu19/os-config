{ config, pkgs, lib, ... }:

let
  # 1. Define the routing script
  url-router = pkgs.writeShellScriptBin "url-router" ''
    URL="$1"

    # If no URL is passed, just open the fallback browser
    if [[ -z "$URL" ]]; then
      exec zen-beta
    
    # 2. Check if the URL starts with https://accounts.google.com
    elif [[ "$URL" == https://accounts.google.com* ]]; then
      # Open in Chromium with a specific profile. 
      # Replace "Profile 1" with your actual profile directory name.
      exec chromium "--profile-directory=Profile 2" "$URL"
    
    else
      # 3. Fallback for all other URLs
      # IMPORTANT: Do not use xdg-open here, or you will create an infinite loop!
      # Replace firefox with your preferred default browser if different.
      exec zen-beta "$URL"
    fi
  '';

  # 4. Create a .desktop file so the system recognizes the script as a browser
  url-router-desktop = pkgs.makeDesktopItem {
    name = "url-router";
    desktopName = "Custom URL Router";
    exec = "${url-router}/bin/url-router %U";
    terminal = false;
    noDisplay = true;
    type = "Application";
    categories = [ "Network" "WebBrowser" ];
    mimeTypes = [
      "text/html"
      "x-scheme-handler/http"
      "x-scheme-handler/https"
      "x-scheme-handler/about"
      "x-scheme-handler/unknown"
    ];
  };

in
{
  # Add the script and desktop item to the specific user's packages
  home.packages = [
    url-router
    url-router-desktop
  ];

  # 5. Tell XDG to use our custom router as the default web browser for this user
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = ["url-router.desktop"];
      "x-scheme-handler/http" = ["url-router.desktop"];
      "x-scheme-handler/https" = ["url-router.desktop"];
      "x-scheme-handler/about" = ["url-router.desktop"];
      # "x-scheme-handler/unknown" = ["url-router.desktop"];
    };
  };
}
