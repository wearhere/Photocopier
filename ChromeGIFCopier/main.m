//
//  main.m
//  ChromeGIFCopier
//
//  This is the ChromeGIFCopier native messaging "host", in the parlance of the
//  native messaging documentation (https://developer.chrome.com/extensions/messaging#native-messaging ).
//
//  The tool receives the URL of the GIF to be copied to the pasteboard from
//  `stdin`, copies it, and if an error occurs, writes that back to the extension
//  via `stdout`.
//
//  Created by Jeffrey Wear on 10/1/14.
//  Copyright (c) 2014 Jeffrey Wear. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/**
 A note re: communicating with the Chrome extension, reproduced from the documentation
 (https://developer.chrome.com/extensions/messaging#native-messaging ):
 
 > "The same format is used to send messages in both directions: each message
 is serialized using JSON, UTF-8 encoded and is preceded with 32-bit message
 length in native byte order."
 */

/**
 Log an error to the Console and also back to the extension.

 It's necessary to provide a prototype to apply the format function attribute.
 */
void logError(NSString *format, ...) NS_FORMAT_FUNCTION(1, 2);
void logError(NSString *format, ...) {
    va_list args;
    va_start(args, format);
    NSString *formattedError = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    NSLog(@"Error: %@", formattedError);
    
    // Not only must we send the message as JSON, but we must send a JSON object.
    NSData *messageData = [NSJSONSerialization dataWithJSONObject:@{ @"error": formattedError } options:0 error:NULL];
    int32_t messageLength = (int32_t)[messageData length];
    NSData *messageLengthData = [[NSData alloc] initWithBytes:&messageLength length:sizeof(messageLength)];

    NSFileHandle *standardOutput = [NSFileHandle fileHandleWithStandardOutput];
    [standardOutput writeData:messageLengthData];
    [standardOutput writeData:messageData];
}

NSURL *readGIFURL() {
    NSFileHandle *standardInput = [NSFileHandle fileHandleWithStandardInput];
    
    const NSUInteger kMessageLengthSize = sizeof(int32_t);
    NSData *messageLengthBytes = [standardInput readDataOfLength:kMessageLengthSize];
    if ([messageLengthBytes length] != kMessageLengthSize) return nil;
    
    int32_t messageLength;
    [messageLengthBytes getBytes:&messageLength length:kMessageLengthSize];
    
    NSData *messageData = [standardInput readDataOfLength:messageLength];
    if ([messageData length] != messageLength) return nil;
    
    NSDictionary *message = [NSJSONSerialization JSONObjectWithData:messageData options:0 error:NULL];
    NSString *gifURLString = message[@"url"];
    NSURL *gifURL = [NSURL URLWithString:gifURLString];
    
    return gifURL;
}

/**
 The following technique for copying a GIF to the pasteboard in animated format–
 as RTFD–is reproduced from https://github.com/BigZaphod/Chameleon/blob/master/UIKit/Classes/UIPasteboard.m#L58.
 As the link says, it's weird to copy it as RFTD but that's how Safari does it.
 
 We also add an actual (but static) image representation of the image to the
 pasteboard for applications that won't process the RTFD version. Again, Safari does that.
 
 Safari also appends URL representations of the GIF to the pasteboard, I guess
 for applications that don't support any image representations, but I don't care
 about supporting that. That behavior is more explicitly provided by "Copy Image URL"
 anyway.
 */
BOOL copyGIFAtURLToPasteboard(NSURL *gifURL) {
    NSData *gifData = [NSData dataWithContentsOfURL:gifURL];
    
    NSImage *plainImage = [[NSImage alloc] initWithData:gifData];
    
    // RTFD data is obtained from an attributed string that embeds the image.
    NSPasteboardItem *gifImage = [[NSPasteboardItem alloc] init];
    NSFileWrapper *fileWrapper = [[NSFileWrapper alloc] initRegularFileWithContents:gifData];
    // This file name does not matter, but without one, the file can't be attached to the attributed string.
    [fileWrapper setPreferredFilename:@"image.gif"];
    NSTextAttachment *attachment = [[NSTextAttachment alloc] initWithFileWrapper:fileWrapper];
    NSAttributedString *str = [NSAttributedString attributedStringWithAttachment:attachment];
    NSData *gifRFTDData = [str RTFDFromRange:NSMakeRange(0, [str length]) documentAttributes:nil];
    [gifImage setData:gifRFTDData forType:NSPasteboardTypeRTFD];
    
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    [pasteboard clearContents];
    return [pasteboard writeObjects:@[ plainImage, gifImage ]];
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSURL *imageURL = readImageURL();
        if (!imageURL) {
            logError(@"Could not read image URL from extension.");
            return 1;
            return 1;
        }
        
        if (!copyGIFAtURLToPasteboard(gifURL)) {
            logError(@"Could not copy GIF at URL: %@", [gifURL absoluteString]);
            return 1;
        }
    }
    return 0;
}
