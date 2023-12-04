# Mutiny Wallet

Mutiny Wallet is a lightning wallet that runs in your web browser. Mutiny is unlike other lightning apps on Start9, it
is not a server that you run on your StartOS Server. Instead, your StartOS server hosts the web app that you can access
from any device on your local network or via TOR. This means that you can access your wallet from your phone, tablet, or
laptop. The first time you set up a wallet, it will have a lightning channel to Mutiny's LSP to get your started. This
is not your StartOS lightning node.

Because you host the web app, the app will not be updated by someone else's server without you knowing it. Changes to
the wallet are only made when you update the StartOS service. This also means that if the Mutiny Wallet team release a
new version, you will not see any of those features until the new Mutiny Wallet version has been packaged into the
StartOS .s9pk format and updated on your StartOS server.

This comes pre-packaged with encrypted cloud storage and all the other backend services that Mutiny Wallet needs to
run, so you don't need to worry about any changes from the Mutiny Wallet team breaking your wallet.

The only external dependency is a block explorer, which is used to get blockchain data. By default, Mutiny uses
[mempool.space](https://mempool.space), but you can change this in the settings of your wallet if you wish to use to
your own.

## Instructions

1. Click launch UI to access your personal Mutiny Wallet website. You now have a lightning wallet!
2. If your browser asks for persistent storage, click yes. This will make the wallet more performant.
3. (Optional) Install as a PWA on your phone or tablet for easy
   access. [Guide](https://developer.mozilla.org/en-US/docs/Web/Progressive_web_apps/Guides/Installing)
4. Backup your seed phrase. This is the only way to recover your funds if you lose access to your wallet. Settings ->
   Backup -> Tap to Reveal Seed Words
5. Send funds to your wallet by clicking the receive button sending to the on-chain address or lightning invoice.
