{ pkgs, ... }: {
  programs.vscode = {
      enable = true;
      package = pkgs.vscodium;

      mutableExtensionsDir = false;

      profiles.default = {
        enableUpdateCheck = false;
        enableExtensionUpdateCheck = false;
        extensions = with pkgs.open-vsx; [
          jnoortheen.nix-ide
        ];
        userSettings = {
          "nix.enableLanguageServer" = true;
          "nix.formatterPath" = "${pkgs.alejandra}/bin/alejandra";
          "nix.serverPath" = "${pkgs.nil}/bin/nil";
          "nix.serverSettings"."nil"."formatting"."command" = ["${pkgs.alejandra}/bin/alejandra"];

          # personal preferences
          "git.autofetch" = true;
          "git.confirmSync" = false;
          "git.enableSmartCommit" = true;
          
          # nag settings
          "explorer.confirmDragAndDrop" = false;
          "explorer.confirmDelete" = false;
          "explorer.confirmPasteNative" = false;
          "security.workspace.trust.untrustedFiles" = "newWindow";
        };
      };
    };
}
