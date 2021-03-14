<p align="center"><img src="icon.png"></p>

# FiveM Rust Gamemode
Rust-inspired survival gamemode for FiveM using [OOF](https://github.com/Paradigm-MP/oof).

This gamemode is set to release in **Q2 2021**, but will continue to be developed afterwards.

## Disclaimer
This gamemode is not currently functional in any sense. When this gamemode reaches a working state, this readme will be updated. The goal of open sourcing this gamemode to encourage more people to learn and use OOF as well as this gamemode.

## Setting Up

### Set Language
If you plan on using a language other than English on your server, you'll want to add this line to your server config:
```
setr locale "en-US"
```
Replace `en-US` with the locale of your choice.

Unsupported locales will fallback to the `en-US` locale by default. If a locale for your language does not exist, please feel free to add it and create a PR! Follow the steps below to add a locale.

**Supported Locales:**
 - `en-us`: English

### Adding a New Locale
If you'd like to use a language other than English and your locale currently isn't added, follow these steps.

1. Set your locale in the server config to the desired locale (instructions above).
2. Navigate to `inventory/src/js/locale`.
3. Copy `en-US.js` to a new file and rename it to your locale, eg. `aa-AA.js`. 
4. Open the file you just renamed and edit the localized strings. Do not edit the keys inside brackets (`["key"]`), but edit their values instead: `["key"]: "value"`. 
5. Once you have finished editing the file, we now need to import it. Open `inventory/src/js/locale/common.js`.
6. Near the top you should see a comment saying: `// Import languages here`. Copy these two lines and paste them under the existing localizations.
```js
import LOCALE_EN_US from "./en-US";
LOCALES["en-US"] = LOCALE_EN_US;
```
Replace the localization names with your own, for example:
```js
import LOCALE_AA_AA from "./aa-AA";
LOCALES["aa-AA"] = LOCALE_AA_AA;
```

Now you'll need to build the UI again, which is covered in the below step.

Now you should be all set with your new localization! Please make a [PR](https://github.com/Paradigm-MP/fivem-rust-gamemode/pulls) so it can be included in the main repository.


### Inventory UI
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

### Resource Generation
When you start the server for the first time, you should see a lot of messages saying that the server is generating and loading the different resources, such as trees and rocks. This is a normal part of starting the server for the first time. It takes all the raw data from `resources/server/resource_data/raw` and converts it all into a cell based format which it stores in `resources/server/resource_data/cells`. This is important because the server should only send players nearby resources instead of all resources.

In the case that your generated resource data becomes corrupted or you'd like to regenerate it using a different cell size, just delete `resources/server/resource_data/generated.txt` and restart the server. It should automatically generate for you.

### Server Customization
Every server that uses this gamemode will be a little bit different, thanks to a few global configuration options.

You can find these config options in `config/shared/RustConfig.lua`. After adjusting the config options, you might also want to update your server title to include any options that you changed so that players know what kind of server it is. 

For example, if you set `BaseUpkeepModifier` to `0.25` and `MaxGroupSize` to `2`, you might include something like this in your server title: `[Duos Only] [Low Upkeep]`. Or if you set `MaxGroupSize` to `0` and `BaseUpkeepModifier` to `0`, you might add something like this to your title: `[Anarchy] [No Decay]`.

## Bugs
- The trees/rocks change size when I get close to them. How do I fix it?
  - Not possible to fix right now. The objects are converted from CBuildings which have custom scales, but custom scaling of object entities is not currently possible during runtime.

## Contact Us
You can get in touch with us on our [Discord](https://discord.gg/XAQ34Td).
