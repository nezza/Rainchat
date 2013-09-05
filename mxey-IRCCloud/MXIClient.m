//
//  MXIClient.m
//  mxey-IRCCloud
//
//  Created by Maximilian Gaß on 05.09.13.
//  Copyright (c) 2013 Maximilian Gaß. All rights reserved.
//

#import "MXIClient.h"
#import "MXIClientBuffer.h"
#import "MXIClientBufferMessage.h"
#import "MXIClientConnection.h"
#import "MXIClientInitialBacklog.h"
#import "MXIClientInitialBacklogEnd.h"

@interface MXIClient ()
@property (nonatomic) MXIClientTransport *transport;
@property (nonatomic) NSMutableArray *messageBufferDuringBacklog;
@property (nonatomic) BOOL processingBacklog;
@end

@implementation MXIClient

- (id)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.transport = [[MXIClientTransport alloc] initWithClient:self];
    self.connections = [NSMutableDictionary dictionary];
    return self;
}

- (void)loginWithEmail:(NSString *)email andPassword:(NSString *)password
{
    [self.transport loginWithEmail:email andPassword:password];
}

- (void)transport:(MXIClientTransport *)transport receivedMessage:(id)message fromBacklog:(BOOL)fromBacklog
{
    if (self.processingBacklog && !fromBacklog) {
        [self.messageBufferDuringBacklog addObject:message];
        return;
    }

    if ([message isKindOfClass:[MXIClientBufferMessage class]]) {
        MXIClientBufferMessage *bufferMessage = (MXIClientBufferMessage *)message;
        [self.delegate client:self didReceiveBufferMsg:bufferMessage];
    }
    else if ([message isKindOfClass:[MXIClientInitialBacklog class]]) {
        MXIClientInitialBacklog *backlog = (MXIClientInitialBacklog *)message;
        NSLog(@"Initial backlog start");
        self.messageBufferDuringBacklog = [NSMutableArray array];
        self.processingBacklog = YES;
        [self.transport loadBacklogFromRelativeURL:backlog.url];
    }
    else if ([message isKindOfClass:[MXIClientInitialBacklogEnd class]]) {
        self.processingBacklog = NO;
        NSLog(@"Initial backlog finished");
        
        NSLog(@"Handling messages received during backlog replay");
        for (id backlogMessage in self.messageBufferDuringBacklog) {
            [self transport:self.transport receivedMessage:backlogMessage fromBacklog:NO];
        }
        self.messageBufferDuringBacklog = nil;
        [self.delegate clientDidFinishInitialBacklog:self];
    }
    else if ([message isKindOfClass:[MXIClientConnection class]]) {
        MXIClientConnection *connection = (MXIClientConnection *)message;
        self.connections[connection.connectionId] = connection;
    }
    else if ([message isKindOfClass:[MXIClientBuffer class]]) {
        MXIClientBuffer *buffer = (MXIClientBuffer *)message;
        MXIClientConnection *connection = self.connections[buffer.connectionId];
        if (connection) {
            [connection.buffers addObject:buffer];
        }
    }
  
}


@end
