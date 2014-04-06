//
//  MXIAppDelegate.m
//  mxey-IRCCloud
//
//  Created by Maximilian Gaß on 01.09.13.
//  Copyright (c) 2013 Maximilian Gaß. All rights reserved.
//

#import "MXIAppDelegate.h"
#import "RFKeychain.h"
#import "MXIClientServer.h"


@implementation MXIAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSString *account = @"mxey@mxey.net";
    NSString *password = [RFKeychain passwordForAccount:account service:@"IRCCloud"];
    self.client = [[MXIClient alloc] init];
    self.client.delegate = self;
    [self.client loginWithEmail:account andPassword:password];
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    if (item) {
        MXIClientServer *server = item;
        return server.buffers.count;
    } else {
        return self.client.serverOrder.count;
    }
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    return [self.client.serverOrder containsObject:item];
}

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    if ([self.client.serverOrder containsObject:item]) {
        NSTableCellView *serverCellView = [outlineView makeViewWithIdentifier:@"HeaderCell" owner:self];
        MXIClientServer *server = item;
        serverCellView.textField.stringValue = [server.name uppercaseString];
        return serverCellView;
    } else {
        NSTableCellView *bufferCellView = [outlineView makeViewWithIdentifier:@"DataCell" owner:self];
        MXIClientBuffer *buffer = item;
        bufferCellView.textField.stringValue = buffer.name;
        return bufferCellView;
    }
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index1 ofItem:(id)item {
    if (item) {
        MXIClientServer *server = item;
        return server.buffers[(NSUInteger) index1];
    } else {
        return self.client.serverOrder[(NSUInteger) index1];
    }
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
    return nil;
}


- (void)client:(MXIClient *)client didReceiveBufferMsg:(MXIClientBufferMessage *)bufferMsg {
    if ([self getSelectedBuffer].bufferId == bufferMsg.bufferId) {
        [self.bufferTextView.textStorage appendAttributedString:[self formatBufferMessage:bufferMsg]];
        [self.bufferTextView scrollToEndOfDocument:self];
    }
}

- (NSAttributedString *)formatBufferMessage:(MXIClientBufferMessage *)bufferMessage {
    NSString *formattedTime = [NSDateFormatter localizedStringFromDate:bufferMessage.timestamp dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterMediumStyle];
    NSString *output = [NSString stringWithFormat:@"%@ <%@> %@\n", formattedTime, bufferMessage.fromNick, bufferMessage.message];
    NSMutableDictionary *attributes = [@{
        NSFontAttributeName : [NSFont systemFontOfSize:13]
    } mutableCopy];
    if (bufferMessage.highlightsUser.boolValue) {
        attributes[NSForegroundColorAttributeName] = [NSColor redColor];
    }
    NSAttributedString *attributedOutput = [[NSAttributedString alloc] initWithString:output attributes:attributes];
    return attributedOutput;
}

- (void)clientDidFinishInitialBacklog:(MXIClient *)client {
    [self.buffersOutlineView reloadData];
}


- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
    MXIClientBuffer *selectedBuffer = [self getSelectedBuffer];
    if (selectedBuffer) {
        NSMutableAttributedString *bufferText = [[NSMutableAttributedString alloc] init];
        for (MXIClientBufferMessage *bufferMessage in selectedBuffer.events) {
            [bufferText appendAttributedString:[self formatBufferMessage:bufferMessage]];
        }
        self.bufferTextView.textStorage.attributedString = bufferText;
        [self.bufferTextView scrollToEndOfDocument:self];
        [self focusMessageTextField];
    }
}

- (void)focusMessageTextField {
    [self.window makeFirstResponder:self.messageTextField];
    self.messageTextField.currentEditor.selectedRange = NSMakeRange(self.messageTextField.stringValue.length, 0);
}

- (MXIClientBuffer *)getSelectedBuffer {
    if (self.buffersOutlineView.selectedRow == -1) {
        return nil;
    }

    NSObject *item = [self.buffersOutlineView itemAtRow:self.buffersOutlineView.selectedRow];
    MXIClientBuffer *selectedBuffer;
    if ([item isKindOfClass:[MXIClientServer class]]) {
        MXIClientServer *server = (MXIClientServer *) item;
        selectedBuffer = server.serverConsoleBuffer;
    } else {
        selectedBuffer = (MXIClientBuffer *) item;
    }
    return selectedBuffer;
}


- (IBAction)pressedEnterInMessageTextField:(NSTextFieldCell *)sender {
    [self.getSelectedBuffer sendMessageWithString:sender.stringValue];
    sender.stringValue = @"";
}
@end
