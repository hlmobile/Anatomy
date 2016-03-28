//
//  Utils.h
//  Cholera
//
//  Created by DianWei on 10/29/13.
//  Copyright (c) 2013 DianWei. All rights reserved.
//

#import <Foundation/Foundation.h>

#define IS_IPHONE_5                         [[UIScreen mainScreen] bounds].size.height > 480 ? TRUE : FALSE

#define DUKORALPRODUCTINFO_URL              @"http://www.csl.com.au/docs/389/536/20131115-Dukoral%20PI%20AU%20appr_clean.pdf"

extern UIViewController *g_ControllerToPop;

@interface Utils : NSObject

+ (void)addObjectToUserDefaults:(NSString *)strURL;
+ (void)removeObjectFromUserDefaults:(NSString *)strURL;

@end
