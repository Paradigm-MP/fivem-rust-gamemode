<p align="center"><img src="icon.png"></p>

# fivem-rust-gamemode
Rust-inspired survival gamemode for FiveM using [OOF](https://github.com/Paradigm-MP/oof).

This gamemode is set to release in **Q2 2021**, but will continue to be developed afterwards.

## Disclaimer
This gamemode is not currently functional in any sense. When this gamemode reaches a working state, this readme will be updated. The goal of open sourcing this gamemode to encourage more people to learn and use OOF as well as this gamemode.

## Setting Up
The inventory/crafting UI uses React, so you'll need to compile it using webpack first.

Navigate to the `inventory` directory and run the following commands:
```
npm install
npm run build
```

This will generate the compiled JS for the inventory/crafting UI to use.

If you'd like to develop the UI, run this command:
```
npm run dev
```

This will open up the UI in your browser to quickly develop it. Keep in mind that you have to manually refresh the page after you make changes, but changes will be automatically compiled. To refresh in FiveM, restart the `rust` resource.


## Bugs
- The trees/rocks change size when I get close to them. How do I fix it?
  - Not possible to fix right now. The objects are converted from CBuildings which have custom scales, but custom scaling of object entities is not currently possible during runtime.

## Contact Us
You can get in touch with us on our [Discord](https://discord.gg/XAQ34Td).
