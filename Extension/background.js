chrome.runtime.onInstalled.addListener(function(reason, previousVersion, id) {
    var reallyCopyImageItemId = "com.jeffreywear.Photocopier.contextMenus.reallyCopyImage";

    // Avoid adding a duplicate menu item.
    chrome.contextMenus.remove(reallyCopyImageItemId, function() {
        if (chrome.runtime.lastError) {
            // Ignore the error we'll get when trying to install the item for the
            // first time, when the item can't be found. We must check the error
            // or else the runtime will barf.
        }

        chrome.contextMenus.create({
            id: reallyCopyImageItemId,
            title: "Really Copy Image",
            contexts:["image"]
        });

        chrome.contextMenus.onClicked.addListener(function(info, tab) {
            if (info.menuItemId !== reallyCopyImageItemId) return;

            chrome.runtime.sendNativeMessage(
                "com.jeffreywear.Photocopier",
                {url: info.srcUrl},
                function(response) {
                    // Chrome will call this handler even if the host doesn't
                    // output anything.
                    if (!response) return;

                    // The host only outputs errors.
                    // Note: this will appear in the console of the "background page"
                    // ("Inspect views: 'background page'" under Photocopier
                    // on chrome://extensions), not in the console of the page with
                    // the image.
                    console.log(response.error);
                }
            );
        });
    });
});
