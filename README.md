<p align="center"><img src="icon.png"></p>

# fivem-rust-gamemode
Rust-inspired survival gamemode for FiveM using OOF

## Disclaimer
This gamemode is not currently functional in any sense. When this gamemode reaches a working state, this readme will be updated. The goal of open sourcing this gamemode to encourage more people to learn and use OOF as well as this gamemode.

## Bugs
- The trees/rocks change size when I get close to them. How do I fix it?
  - Not possible to fix right now. The objects are converted from CBuildings which have custom scales, but custom scaling of object entities is not currently possible during runtime.