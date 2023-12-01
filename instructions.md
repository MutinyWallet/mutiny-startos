# Mutiny Wallet

Mutiny Wallet is a lightning wallet that runs in the web. Mutiny is unlike other lightning apps on Start9, it is not a
server that you run on your Embassy. Instead, it is a web app that you can access from any device on your local network.
This means that you can access your wallet from your phone, tablet, or laptop.

This comes pre-packaged with VSS and the websocket proxy, so everything you need to run a lightning wallet is included.

The only external dependency is esplora, which is used to get blockchain data. This can be configured in the settings
page if you have your own esplora instance running.

## Instructions

1. Click launch UI to access your personal Mutiny Wallet website. You now have a lightning wallet!
2. If your browser asks for persistent storage, click yes. This will make the wallet more performant.
3. (Optional) Install as a PWA on your phone or tablet for easy access.
4. Backup your seed phrase. This is the only way to recover your funds if you lose access to your wallet.
5. Send funds to your wallet by clicking the receive button sending to the on-chain address or lightning invoice.
