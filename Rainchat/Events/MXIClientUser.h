//
//  MXIClientUser.h
//  Rainchat
//
//  Created by Phillip Thelen on 04/06/14.
//

#import "MTLModel.h"
#import <Mantle/MTLJSONAdapter.h>

@interface MXIClientUser : MTLModel <MTLJSONSerializing>

@property(nonatomic) NSString *nick;
@property(nonatomic) NSString *realName;
@property(nonatomic) NSString *ircServer;
@property(nonatomic) NSString *mode;
@property(nonatomic) NSNumber *away;

+(id)newUserWithNick:(NSString*)nick;

@end
