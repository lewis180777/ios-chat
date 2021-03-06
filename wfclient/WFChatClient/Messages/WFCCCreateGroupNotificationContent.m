//
//  WFCCCreateGroupNotificationContent.m
//  WFChatClient
//
//  Created by heavyrain on 2017/9/19.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import "WFCCCreateGroupNotificationContent.h"
#import "WFCCIMService.h"
#import "WFCCNetworkService.h"
#import "Common.h"

@implementation WFCCCreateGroupNotificationContent
- (WFCCMessagePayload *)encode {
    WFCCMessagePayload *payload = [[WFCCMessagePayload alloc] init];
    payload.contentType = [self.class getContentType];
    
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    if (self.creator) {
        [dataDict setObject:self.creator forKey:@"o"];
    }
    if (self.groupName) {
        [dataDict setObject:self.groupName forKey:@"n"];
    }
    
    payload.binaryContent = [NSJSONSerialization dataWithJSONObject:dataDict
                                                                           options:kNilOptions
                                                                             error:nil];
    
    return payload;
}

- (void)decode:(WFCCMessagePayload *)payload {
    NSError *__error = nil;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:payload.binaryContent
                                                               options:kNilOptions
                                                                 error:&__error];
    if (!__error) {
        self.creator = dictionary[@"o"];
        self.groupName = dictionary[@"n"];
    }
}

+ (int)getContentType {
    return MESSAGE_CONTENT_TYPE_CREATE_GROUP;
}

+ (int)getContentFlags {
    return WFCCPersistFlag_PERSIST;
}



+ (void)load {
    [[WFCCIMService sharedWFCIMService] registerMessageContent:self];
}

- (NSString *)digest {
    return [self formatNotification];
}

- (NSString *)formatNotification {
    if ([[WFCCNetworkService sharedInstance].userId isEqualToString:self.creator]) {
        return [NSString stringWithFormat:@"你创建了群\"%@\"", self.groupName];
    } else {
        WFCCUserInfo *userInfo = [[WFCCIMService sharedWFCIMService] getUserInfo:self.creator refresh:NO];
        if (userInfo.displayName.length > 0) {
            return [NSString stringWithFormat:@"%@创建了群\"%@\"", userInfo.displayName, self.groupName];
        } else {
            return [NSString stringWithFormat:@"用户<%@>创建了群\"%@\"", self.creator, self.groupName];
        }
    }
}
@end
