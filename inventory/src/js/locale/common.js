const LOCALES = {}

// Import languages here
import LOCALE_EN_US from "./en-US";
LOCALES["en-US"] = LOCALE_EN_US;

class Localization
{
    constructor ()
    {
        this.locale = "en-US";
        this.fallback_locale = "en-US"; // Fallback in case the specified locale does not contain everything
    }

    /**
     * Sets the locale to the one specified. Must be in the LOCALE list.
     * @param {*} locale Locale to change to
     */
    SetLocale (locale)
    {
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

        let locale = LOCALES[this.locale] ? this.locale : this.fallback_locale;
        let menu_data = LOCALES[locale].menu[menu_item_name];
        
        return menu_data || "NULL";
    }

    /**
     * Gets the localized name of an attribute, such as "instant_health".
     * @param {*} menu_item_name Non-localized attribute name
     */
     GetAttributeName (attr_name)
     {
         if (attr_name == null)
         {
             console.error(`No attribute name given - cannot continue with localization.`);
             return;
         }
 
         let locale = LOCALES[this.locale] ? this.locale : this.fallback_locale;
         let attr_data = LOCALES[locale].attributes[attr_name];
         
         return attr_data || "NULL";
     }
 
    GetItemData (item_name, field)
    {
        if (item_name == null)
        {
            console.error(`No item name given - cannot continue with localization.`);
            return;
        }

        let locale = LOCALES[this.locale] ? this.locale : this.fallback_locale;
        let item_data = LOCALES[locale].items[item_name];

        if (typeof item_data == 'undefined') {return;}
        
        return item_data[field] || {};
    }

    /**
     * Gets the localized name of an item
     * @param {*} item_name Non-localized item name
     */
    GetItemName (item_name)
    {
        return this.GetItemData(item_name, "name") || "NULL";
    }

    /**
     * Gets the localized description of an item
     * @param {*} item_name Non-localized item name
     */
    GetItemDescription (item_name)
    {
        return this.GetItemData(item_name, "description") || "NULL";
    }
}

const Localizations = new Localization();
export default Localizations;