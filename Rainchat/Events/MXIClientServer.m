//
//  MXIClientServer.m
//  Rainchat
//
//  Created by Maximilian Gaß on 02.09.13.
//

#import "MXIClientServer.h"
#import <Mantle/NSValueTransformer+MTLPredefinedTransformerAdditions.h>

@implementation MXIClientServer
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Woverriding-method-mismatch"
- (instancetype)initWithDictionary:(NSDictionary *)dict error:(NSError **)err {
    self = [super initWithDictionary:dict error:err];
    if (self) {
        self.buffers = [NSMutableArray array];
    }
    return self;
}
#pragma clang diagnostic pop

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
        @"connectionId" : @"cid",
        @"name" : @"name",
        @"nick" : @"nick",
        @"status": @"status"
    };
}

+ (NSValueTransformer *)statusJSONTransformer {
    return [MXIClient statusJSONTransformer];
}

- (void)addBuffer:(MXIClientBuffer *)buffer {
    if (buffer.type == MXIClientBufferTypeServerConsole) {
        self.serverConsoleBuffer = buffer;
    } else {
        [self.buffers addObject:buffer];
    }
}

- (void)processWithClient:(MXIClient *)client {
    client.servers[self.connectionId] = self;
    [client.serverOrder addObject:self];
}

@end
