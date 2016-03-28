//
//  Database.h
//  AutoDiler
//
//  Created by RenZhe Ahn on 1/29/14.
//  Copyright (c) 2014 MRDzA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface Database : NSObject
{
    sqlite3 *database;
    NSString *dbName;
}

- (id)init;
- (void)initDatabase;
- (void)initDatabaseWithJsonFile;
- (BOOL)saveQuestion:(NSDictionary *)question ID:(int)index;
- (int)getCountOfTable;
- (NSMutableDictionary *)getRowById:(int)index;

@end
