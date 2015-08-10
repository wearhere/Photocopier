# Photocopier

Chrome can't copy animated GIFs. Oh, it copies the images all right&mdash;but not
as animated GIFs. Try it:

1. Load up a sweet animated GIF like [this][sweet gif].
2. Copy the image using the right-click menu.
3. Paste the image into Messages.
4. Send that message to a friend.
5. Look foolish.

This extension adds a right-click menu item to "really" copy the image:

![][menu item]

And it'll work for regular images too.

## Installation

1. Clone this repo.
2. Open [chrome://extensions][extension settings].
3. Enable "Developer mode" using the checkbox at the top of the page.
4. Click the "Load unpacked extension…" button that appears at the top of the page.
5. In the file picker that appears, select the "Extension" folder within the cloned repo.
6. In the Terminal, `cd` to the cloned repo and run `./Host/install_host.sh`.

### Why Isn't This on the Chrome Web Store?

To actually copy GIFs, the extension needs the help of a
[native host][native hosts], and
Chrome [doesn't support distributing those][can't bundle native hosts]
through the Web Store.

## Usage

1. Right-click on a GIF.
2. Click "Really Copy Image".
3. Wait for an "Image copied!" OS X notification.

There may be a little bit of a delay for the GIF to be processed since the
extension has to re-download the GIF (see "How It Works" below).

## How It Works

If we compare Safari to Chrome, Safari Does The Right Thing™. That's because
Safari [represents the image differently][pasteboard concepts]
than Chrome does. Using Apple's [ClipboardViewer][ClipboardViewer] app,
we can see that Chrome only copies GIFs as flat images (and their URLs, in case
you try to paste into a plain-text editor):

![][pasteboard item from Chrome]

But Safari also copies GIFs as RTFD format:

![][pasteboard item from Safari]

That's the format that's read "as a GIF" by Messages. So, all we have to do is
download the image ourself and put it onto the pasteboard as RTFD. (Tip of the
hat to the Chameleon project for initially [putting me onto][Chameleon] this
technique.)

### How Weird Is This?

Pretty weird. Weird enough that I'm not _altogether_ mad at Chrome for not
supporting it. To boot, it seems to be Apple-specific given that
[only OS X supports RTFD][RTFD]. Being a good Mac citizen's not nothing, though.

The real solution would be for everyone to use the GIF clipboard format but
[no one does][no one uses the GIF UT type] and for it to make a difference, the
copying _and_ pasting applications would have to support it. Perhaps when Apple
developed Messages, they just took advantage of existing applications' support
for RTFD (TextEdit accepts GIF pastes, lolol).

Then again, [iOS supports the GIF UT type][iOS supports the GIF UT type].

![](http://www.technobuffalo.com/wp-content/uploads/2013/06/Seinfeld-Leaving.gif)

## Upgrading

1. `cd` to the cloned repo and `git pull && ./Host/install_host.sh`.
2. Open chrome://extensions.
3. Click "Reload" under Photocopier.

## Uninstallation

1. Click the trash can next to Photocopier at [chrome://extensions][extension settings].
2. `cd` to the cloned repo and run `./Host/uninstall_host.sh`.

## Contributions

I don't know what more there is to do here but if you have ideas feel free to
submit pull requests or otherwise chime in!

## Copyright and License

Photocopier Copyright 2015 Jeffrey Wear.

Photocopier is available under the MIT license. See the LICENSE file for more
info.

[sweet gif]: http://giphy.com/gifs/upvote-tears-joy-eHOxorWR8d1mM
[menu item]: ./Images/menu_item.png
[extension settings]: chrome://extensions
[native hosts]: https://developer.chrome.com/extensions/nativeMessaging
[can't bundle native hosts]: https://code.google.com/p/chromium/issues/detail?id=321628
[pasteboard concepts]: https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/PasteboardGuide106/Articles/pbConcepts.html#//apple_ref/doc/uid/TP40008101-SW5
[ClipboardViewer]: https://developer.apple.com/library/mac/samplecode/ClipboardViewer/Introduction/Intro.html
[pasteboard item from Chrome]: ./Images/Chrome_pasteboard_item.png
[pasteboard item from Safari]: ./Images/Safari_pasteboard_item.png
[Chameleon]: https://github.com/BigZaphod/Chameleon/blob/master/UIKit/Classes/UIPasteboard.m#L58
[RTFD]: https://en.wikipedia.org/wiki/Rich_Text_Format_Directory
[no one uses the GIF UT type]: http://stackoverflow.com/a/14945981/495611
[iOS supports the GIF UT type]: https://github.com/BigZaphod/Chameleon/blob/master/UIKit/Classes/UIPasteboard.m#L65