//
//  MXIClientBufferQuit.m
//  mxey-IRCCloud
//
//  Created by Maximilian Gaß on 07.06.14.
//  Copyright (c) 2014 Maximilian Gaß. All rights reserved.
//

#import "MXIClientBufferQuit.h"
#import "NSDictionary+MTLManipulationAdditions.h"


@implementation MXIClientBufferQuit
+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return [[super JSONKeyPathsByPropertyKey] mtl_dictionaryByAddingEntriesFromDictionary:@{
                                                                                            @"fromNick" : @"nick",
                                                                                            @"message" : @"msg",
                                                                                            }];
}

- (NSString *)string {
    return [NSString stringWithFormat:@"<<< %@ quit (%@)", self.fromNick, self.message];
}
@end
