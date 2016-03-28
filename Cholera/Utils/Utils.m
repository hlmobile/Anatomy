//
//  Utils.m
//  Cholera
//
//  Created by DianWei on 10/29/13.
//  Copyright (c) 2013 DianWei. All rights reserved.
//

#import "Utils.h"

@implementation Utils

UIViewController *g_ControllerToPop = nil;

+ (void)addObjectToUserDefaults:(NSString *)strURL
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSData *requestData = [standardUserDefaults objectForKey:@"requestsArray"];
    NSMutableArray *aryRequests = nil;
    if (requestData) {
        aryRequests = [[NSMutableArray alloc] initWithArray:[NSMutableArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:requestData]]];
    } else {
        aryRequests = [[NSMutableArray alloc] init];
    }
    
    BOOL bExist = NO;
    for (int i = 0; i < [aryRequests count]; i++) {
        if ([strURL isEqualToString:[aryRequests objectAtIndex:i]]) {
            bExist = YES;
        }
    }
    if (!bExist) {
        [aryRequests addObject:strURL];
    }
    
    NSData *savingRequests = [NSKeyedArchiver archivedDataWithRootObject:aryRequests];
    [standardUserDefaults setObject:savingRequests forKey:@"requestsArray"];
    [standardUserDefaults synchronize];
}

+ (void)removeObjectFromUserDefaults:(NSString *)strURL
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSData *requestData = [standardUserDefaults objectForKey:@"requestsArray"];
    NSMutableArray *aryRequests = nil;
    if (requestData) {
        aryRequests = [[NSMutableArray alloc] initWithArray:[NSMutableArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:requestData]]];
    } else {
        aryRequests = [[NSMutableArray alloc] init];
    }
    NSMutableArray *aryEquals = [[NSMutableArray alloc] init];
    for (int i = 0; i < [aryRequests count]; i++) {
        if ([strURL isEqualToString:[aryRequests objectAtIndex:i]]) {
            [aryEquals addObject:[aryRequests objectAtIndex:i]];
        }
    }
    for (int i = 0; i < [aryEquals count]; i++) {
        [aryRequests removeObject:[aryEquals objectAtIndex:i]];
    }
    NSData *savingRequests = [NSKeyedArchiver archivedDataWithRootObject:aryRequests];
    [standardUserDefaults setObject:savingRequests forKey:@"requestsArray"];
    [standardUserDefaults synchronize];
}


@end
