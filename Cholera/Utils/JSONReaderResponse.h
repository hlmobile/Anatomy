//
//  JSONReaderData.h
//  Bahsqft
//
//  Created by DianWei on 10/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSON.h"

@protocol JSONReaderResponseDelegate

- (void)readDataFinished:(BOOL)isSuccess :(NSMutableDictionary *)aryAnswers;

@end


@interface JSONReaderResponse : NSObject {
	NSMutableData				*m_responseData;
	NSMutableDictionary         *m_result;
}

@property (nonatomic) id<JSONReaderResponseDelegate>	delegate;
@property (nonatomic) NSMutableDictionary               *m_result;
@property (nonatomic) int                               m_nType;
@property (nonatomic) NSString                          *parserURL;


- (void)parseJSONDataAtURL:(NSURL *)URL;
- (void)getData:(NSMutableDictionary*)rData;

@end
