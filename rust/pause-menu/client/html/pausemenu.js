$(function() 
{
    let option_selected = false;

    $('div.option').on("click", function()
    {
        if (option_selected) {return;}
        option_selected = true;

        if ($(this).hasClass("exit"))
        {
            invokeNative("exit", "");
            return;
        }

        // Functionality for more options in the future
        OOF.CallEvent("OptionSelected", 
        {
            
        })
    })

    OOF.CallEvent("Ready");
})