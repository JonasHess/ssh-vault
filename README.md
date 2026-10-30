# SSH key vault

Encrypted SSH keys and machine bootstrap, managed by dfm (dotfile-manager).
Private keys live in personas/<name>/bundle.age, encrypted with age and a passphrase.
Public keys and persona.env are plaintext. Nothing else confidential is committed;
.githooks/pre-commit and the guard workflow enforce that.

## New machine

    curl -fsSL https://raw.githubusercontent.com/JonasHess/ssh-vault/main/install.sh | sh

The wizard asks for a persona, the roles for this machine and the passphrase, then does the rest.

## Clone and inspect first

    git clone <this repo> && cd <repo> && sh install.sh
