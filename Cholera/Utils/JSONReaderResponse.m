//
//  JSONReaderResponse.m
//  Bahsqft
//
//  Created by DianWei on 10/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "JSONReaderResponse.h"


@implementation JSONReaderResponse

@synthesize delegate;
@synthesize m_result;
@synthesize m_nType;
@synthesize parserURL;

- (id)init {
	if (self = [super init]) {
		m_responseData = [NSMutableData data];
		m_result = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (void)parseJSONDataAtURL:(NSURL *)URL
{
	NSURLRequest *request = [NSURLRequest requestWithURL:URL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:1.0];
	[[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	[m_responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[m_responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	NSLog(@"Connection failed: %@", [error localizedDescription]);
	[self.delegate readDataFinished:NO :nil];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	NSString *responseString = [[NSString alloc] initWithData:m_responseData encoding:NSUTF8StringEncoding];
    NSLog(@"%@", responseString);

	NSError *error;
	SBJsonParser *jsonParser = [SBJsonParser new];
	NSMutableDictionary *rDict = (NSMutableDictionary *)[jsonParser objectWithString:responseString error:&error];
    [self.delegate readDataFinished:YES :rDict];
}

@end
