
//
//  Database.m
//  AutoDiler
//
//  Created by RenZhe Ahn on 1/29/14.
//  Copyright (c) 2014 MRDzA. All rights reserved.
//

#import "Database.h"

@implementation Database

- (id)init
{
    NSLog(@"Database init");
    
    self = [super init];
    
    if (self != nil) {
        dbName = @"database.db";
        [self initDatabase];
    }
    return self;
}

// --------------
- (void)dealloc {
    NSLog(@"Database dealloc");
    
    if (sqlite3_close(database) != SQLITE_OK) {
        NSAssert1(0, @"Error: closing database with message '%s'", sqlite3_errmsg(database));
    }
}

- (void)initDatabase
{
    NSLog(@"Database initDatabase");
    
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSString *dbPath = [NSString stringWithFormat:@"%@/Documents/%@", NSHomeDirectory(), dbName];
    NSLog(@"%@", dbPath);
    BOOL dbExists = [fileMgr fileExistsAtPath:dbPath];
    
    // if DB empty then copy the db file
    if ( !dbExists ) {
        NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath]stringByAppendingPathComponent:dbName];
        
        NSLog(@"Default DB Path: %@", defaultDBPath);
        
        NSError *error;
        BOOL success = [fileMgr copyItemAtPath:defaultDBPath toPath:dbPath error:&error];
        if (!success)
        {
            NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
            return;
        }
    }
    
    if (sqlite3_open_v2([dbPath UTF8String], &database, SQLITE_OPEN_READWRITE |
                        SQLITE_OPEN_CREATE | SQLITE_OPEN_FULLMUTEX, 0) == SQLITE_OK)
    {
        NSLog(@"Database Successfully Opend :)");
    }
    else
    {
        NSLog(@"ERROR: DB opening current database");
		sqlite3_close(database);
		NSAssert1(0, @"Failed to open database with code '%s'.", sqlite3_errmsg(database));
    }
}

- (void)initDatabaseWithJsonFile
{
    NSLog(@"Database initDatabaseWithJsonFile");
    
    [self truncateTable];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"questions" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSError *error;
    NSMutableArray *arrQuestions = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    if ( error ) {
        NSLog(@"Database error: %@", error);
    } else {
        for (NSDictionary *question in arrQuestions) {
            if ( [self saveQuestion:question ID:0] ) {
                NSLog(@"question: %d sucess", [[question valueForKey:@"QuestionID"] intValue]);
            } else {
                NSLog(@"failed %@", question);
                break;
            }
        }
    }
}

- (BOOL)truncateTable
{
    NSLog(@"Database truncateTable");
    BOOL result = NO;
    int returnCode;
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM questions; VACUUM"];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
        returnCode = sqlite3_step(statement);
        result = YES;
    }
    sqlite3_finalize(statement);
    
    return result;
}

- (BOOL)saveQuestion:(NSDictionary *)question ID:(int)index
{
    NSLog(@"Database saveQuestion: %d", index);
    BOOL result = NO;
    sqlite3_stmt *statement;
    NSString *sql;
    if (index > 0) {
        sql = [NSString stringWithFormat:@"UPDATE questions  SET QuestionID=?, Question=?, Answer1=?, Weight1=?, Answer2=?, Weight2=?, Answer3=?, Weight3=?, Answer4=?, Weight4=?, Answer5=?, Weight5=?  WHERE rowid=%d", index];
    } else {
        sql = @"INSERT INTO questions  VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
    }
    if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
        sqlite3_bind_int(statement, 1, [[question objectForKey:@"QuestionID"] intValue]);
        sqlite3_bind_text(statement, 2, [[question valueForKey:@"Question"] UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 3, [[question valueForKey:@"Answer1"] UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(statement, 4, [[question objectForKey:@"Weight1"] intValue]);
        sqlite3_bind_text(statement, 5, [[question valueForKey:@"Answer2"] UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(statement, 6, [[question objectForKey:@"Weight2"] intValue]);
        sqlite3_bind_text(statement, 7, [[question valueForKey:@"Answer3"] UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(statement, 8, [[question objectForKey:@"Weight3"] intValue]);
        sqlite3_bind_text(statement, 9, [[question valueForKey:@"Answer4"] UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(statement, 10, [[question objectForKey:@"Weight4"] intValue]);
        sqlite3_bind_text(statement, 11, [[question valueForKey:@"Answer5"] UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(statement, 12, [[question objectForKey:@"Weight5"] intValue]);
        
        if (sqlite3_step(statement) == SQLITE_DONE) result = YES;
        else result = NO;
    } else {
        result = NO;
        NSLog(@"Error: %s", sqlite3_errmsg(database));
    }
    sqlite3_finalize(statement);
    
    return result;
}

- (int)getCountOfTable
{
    NSLog(@"Database getCountOfTable");
    
    int count = 0;
    NSString *sql = [NSString stringWithFormat:@"SELECT COUNT(*)  FROM questions"];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
        //Loop through all the returned rows (should be just one)
        while (sqlite3_step(statement) == SQLITE_ROW) {
            count = sqlite3_column_int(statement, 0);
        }
    }
    sqlite3_finalize(statement);

    return  count;
}

- (NSMutableDictionary *)getRowById:(int)index
{
    NSLog(@"Database getRowById: %d", index);
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    NSString *sql = [NSString stringWithFormat:@"SELECT *  FROM questions  WHERE rowid=%d", index];
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil) == SQLITE_OK) { 
        //Loop through all the returned rows
        while (sqlite3_step(statement) == SQLITE_ROW) {
            [dic setObject:[NSString stringWithFormat:@"%d", sqlite3_column_int(statement, 0)] forKey:@"QuestionID"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 1)] forKey:@"Question"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 2)] forKey:@"Answer1"];
            [dic setObject:[NSString stringWithFormat:@"%d", sqlite3_column_int(statement, 3)] forKey:@"Weight1"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 4)] forKey:@"Answer2"];
            [dic setObject:[NSString stringWithFormat:@"%d", sqlite3_column_int(statement, 5)] forKey:@"Weight2"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 6)] forKey:@"Answer3"];
            [dic setObject:[NSString stringWithFormat:@"%d", sqlite3_column_int(statement, 7)] forKey:@"Weight3"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 8)] forKey:@"Answer4"];
            [dic setObject:[NSString stringWithFormat:@"%d", sqlite3_column_int(statement, 9)] forKey:@"Weight4"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 10)] forKey:@"Answer5"];
            [dic setObject:[NSString stringWithFormat:@"%d", sqlite3_column_int(statement, 11)] forKey:@"Weight5"];
        }
    }
    sqlite3_finalize(statement);
    
    return dic;
}

@end
