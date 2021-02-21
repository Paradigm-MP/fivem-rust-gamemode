$(document).ready(function() 
{
    const states = {}

    const names = 
    {
        ["INIT_BEFORE_MAP_LOADED"]: "Asset Warmup",
        ["MAP"]: "Map",
        ["INIT_AFTER_MAP_LOADED"]: "Initialization",
        ["INIT_SESSION"]: "Session"
    }

    function UpdateLoadStatus(name)
    {
        const load_status = states[name]
        load_status.progress = Math.min(load_status.progress, load_status.max_progress)
        name = names[name] || name;
        let text_str = `${name} (${load_status.progress}/${load_status.max_progress})`;
        if (load_status.max_progress == 0)
        {
            text_str = `START ${name}`
        }

        $('div.subtitle').text(text_str)
    }

    $('div.cancel-button').on('click', function(){
        invokeNative("exit", "");
    })

    if (typeof OOF != 'undefined')
    {
        OOF.Subscribe('Update', (args) => 
        {
            let text_str = `${args.name} [${args.progress}/${args.progress_max}]`;
            $('div.subtitle').text(text_str);
        })

        OOF.CallEvent('Ready');
    }

    const handlers = {

        startInitFunction(data)
        {
            if (states[data.type] == null)
            {
                states[data.type] = {};
                states[data.type].progress = 0;
                states[data.type].max_progress = 0;
            }
        },

        startInitFunctionOrder(data)
        {
            if (states[data.type] != null)
            {
                states[data.type].max_progress += data.count;
                UpdateLoadStatus(data.type);
            }

        },
    
        initFunctionInvoking(data)
        {
            if (states[data.type] != null)
            {
                states[data.type].progress += data.idx;
                UpdateLoadStatus(data.type);
            }
        },
    
        initFunctionInvoked(data)
        {
            if (states[data.type] != null)
            {
                states[data.type].progress++;
                UpdateLoadStatus(data.type);
            }
        },
    
        endInitFunction(data)
        {
        },
    
        performMapLoadFunction(data)
        {
            states["MAP"].progress++;
            UpdateLoadStatus("MAP");
        },
    
        startDataFileEntries(data)
        {
            states["MAP"] = {};
            states["MAP"].max_progress = data.count;
            states["MAP"].progress = 0; 
            UpdateLoadStatus("MAP");
        },
    
        onDataFileEntry(data)
        {
        },
    
        endDataFileEntries()
        {
        },
    };

    window.addEventListener('message', function(e)
    {
        (handlers[e.data.eventName] || function() {})(e.data);
    });

})