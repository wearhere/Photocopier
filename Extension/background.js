chrome.runtime.onInstalled.addListener(function(reason, previousVersion, id) {
    var reallyCopyImageItemId = "com.jeffreywear.Photocopier.contextMenus.reallyCopyImage";

    // Avoid adding a duplicate menu item.
    chrome.contextMenus.remove(reallyCopyImageItemId, function() {
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
