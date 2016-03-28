//
//  TermsViewController.m
//  ACEM
//
//  Created by Pavel Poel on 12/23/13.
//  Copyright (c) 2013 DianWei. All rights reserved.
//

#import "TermsViewController.h"
#import "QuizViewController.h"
#import "JSON.h"

@interface TermsViewController ()

@end

@implementation TermsViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onAccept:(id)sender
{
    NSUserDefaults *standardUserDeafults = [NSUserDefaults standardUserDefaults];
    [standardUserDeafults setBool:YES forKey:@"isAccepted"];
    [standardUserDeafults synchronize];
    QuizViewController *quizCtlr = [[QuizViewController alloc] init];
    [self.navigationController pushViewController:quizCtlr animated:YES];
}

@end
