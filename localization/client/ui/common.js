class Localization
{
    constructor ()
    {
        this.locale = LOCALE.EN_US;
        this.fallback_locale = LOCALE.EN_US; // Fallback in case the specified locale does not contain everything
    }

    /**
     * Sets the locale to the one specified. Must be in the LOCALE list.
     * @param {*} locale Locale to change to
     */
    SetLocale (locale)
    {
        if (!LOCALE[locale])
        {
            console.error(`Cannot set locale. Locale '${locale}' not found. Did you add it to the LOCALE list?`);
            return;
        }

        this.locale = locale;
    }

    /**
     * Gets the localized name of a menu item, such as INVENTORY.
     * @param {*} menu_item_name Non-localized menu item name
     */
    GetMenuItemName (menu_item_name)
    {
        if (menu_item_name == null)
        {
            console.error(`No menu name given - cannot continue with localization.`);
            return;
        }

        let menu_data = LOCALES[this.locale].menu[menu_item_name];
        
        if (menu_data == null)
        {
            console.log(`No localization found for ${menu_item_name}. Resorting to fallback localization.`);
            menu_data = LOCALES[this.fallback_locale].menu[menu_item_name];
        }

        return menu_data;
    }

    GetItemData (item_name, field)
    {
        if (item_name == null)
        {
            console.error(`No item name given - cannot continue with localization.`);
            return;
        }

        let item_data = LOCALES[this.locale].items[item_name];
        
        if (item_data == null || item_data[field] == null)
        {
            console.log(`No localization (${field}) found for ${item_name}. Resorting to fallback localization.`);
            item_data = LOCALES[this.fallback_locale].items[item_name];
        }

        return item_data[field];
    }

    /**
     * Gets the localized name of an item
     * @param {*} item_name Non-localized item name
     */
    GetItemName (item_name)
    {
        return this.GetItemData(item_name, "name");
    }

    /**
     * Gets the localized description of an item
     * @param {*} item_name Non-localized item name
     */
    GetItemDescription (item_name)
    {
        return this.GetItemData(item_name, "description");
    }
}

Localizations = Localization()