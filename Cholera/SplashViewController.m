//
//  SplashViewController.m
//  ACEM
//
//  Created by Pavel Poel on 12/25/13.
//  Copyright (c) 2013 DianWei. All rights reserved.
//

#import "SplashViewController.h"
#import "QuizViewController.h"
#import "TermsViewController.h"
#import "Database.h"

@interface SplashViewController ()

@end

@implementation SplashViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    BOOL isAccepted = [[standardUserDefaults objectForKey:@"isAccepted"] boolValue];
    
//  NSString *requestURL = @"http://www.hugostephenson.com/acem/phrm_pull.json";
//  JSONReaderResponse *readResponse = [[JSONReaderResponse alloc] init];
//  readResponse.delegate = self;
//  readResponse.parserURL = requestURL;
//  [readResponse parseJSONDataAtURL:[NSURL URLWithString:[requestURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    
    if ( isAccepted ) {
        QuizViewController *quizCtlr = [[QuizViewController alloc] initWithNibName:@"QuizViewController" bundle:nil];
        [self.navigationController pushViewController:quizCtlr animated:NO];
    } else {
        Database *db = [[Database alloc] init];
        [db initDatabaseWithJsonFile];
        
        /*
        NSData *jsonData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"questions" ofType:@"json"]];
        
        NSString *responseString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        //NSLog(@"%@", responseString);
        
        NSError *error;
        SBJsonParser *jsonParser = [SBJsonParser new];
        NSMutableArray *arrayQuiz = [NSMutableArray arrayWithArray:(NSArray *)[jsonParser objectWithString:responseString error:&error]];
        [standardUserDefaults setObject:arrayQuiz forKey:@"arrayQuiz"];
        [standardUserDefaults synchronize];
        */
        
        TermsViewController *termsCtlr = [[TermsViewController alloc] initWithNibName:@"TermsViewController" bundle:nil];
        [self.navigationController pushViewController:termsCtlr animated:NO]; 
    }
}

#pragma mark - JSONReaderResponseDelegate

- (void)readDataFinished:(BOOL)isSuccess :(NSMutableDictionary *)aryAnswers
{  
    if (isSuccess) {
        NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
        NSMutableArray *arrayQ = [[NSMutableArray alloc] initWithArray:[standardUserDefaults objectForKey:@"arrayQuiz"]];
        for (int i = 0; i < [arrayQ count]; i++) {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:[arrayQ objectAtIndex:i]];
            [arrayQ removeObjectAtIndex:i];
            NSString *strKey = [dict objectForKey:@"QuestionID"];
            if ([aryAnswers objectForKey:strKey] != nil) {
                NSArray *tempAnswers = [aryAnswers objectForKey:strKey];
                for (int j = 0; j < [tempAnswers count]; j++) {
                    NSString *strWKey = [NSString stringWithFormat:@"Weight%d", j + 1];
                    int weight = [[tempAnswers objectAtIndex:j] intValue];
                    [dict setObject:[NSString stringWithFormat:@"%d", weight] forKey:strWKey];
                }
            }
            [arrayQ insertObject:dict atIndex:i];
        }
        [standardUserDefaults setObject:arrayQ forKey:@"arrayQuiz"];
        [standardUserDefaults synchronize];
    }
    
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSLog(@"%@", [standardUserDefaults objectForKey:@"arrayQuiz"]);
    BOOL isAccepted = [[standardUserDefaults objectForKey:@"isAccepted"] boolValue];
    
    if (isAccepted) {
        QuizViewController *quizCtlr = [[QuizViewController alloc] initWithNibName:@"QuizViewController" bundle:nil];
        [self.navigationController pushViewController:quizCtlr animated:NO];
    }
    else
    {
        NSData *jsonData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"questions" ofType:@"json"]];
        
        NSString *responseString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"%@", responseString);
        
        NSError *error;
        SBJsonParser *jsonParser = [SBJsonParser new];
        NSMutableArray *arrayQuiz = [NSMutableArray arrayWithArray:(NSArray *)[jsonParser objectWithString:responseString error:&error]];
        [standardUserDefaults setObject:arrayQuiz forKey:@"arrayQuiz"];
        [standardUserDefaults synchronize];
        
        TermsViewController *termsCtlr = [[TermsViewController alloc] initWithNibName:@"TermsViewController" bundle:nil];
        [self.navigationController pushViewController:termsCtlr animated:NO];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
