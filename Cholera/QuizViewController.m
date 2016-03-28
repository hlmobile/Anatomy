//
//  QuizViewController.m
//  ACEM
//
//  Created by Pavel Poel on 12/23/13.
//  Copyright (c) 2013 DianWei. All rights reserved.
//

#import "QuizViewController.h"
#import "AudioPool.h"
#import "Database.h"

@implementation AnswerCell : UITableViewCell

@synthesize lblOrder;
@synthesize lblAnswer;
@synthesize vwWeight1;
@synthesize vwWeight2;
@synthesize vwWeight3;
@synthesize vwWeight4;
@synthesize vwWeight5;

@end

@interface QuizViewController ()

@end

@implementation QuizViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    NSLog(@"QuizViewController initWithNibName");
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.db = [[Database alloc] init];
    }
    return self;
}

- (NSMutableArray *)random:(int)count
{
    NSMutableArray *arrTemp = [[NSMutableArray alloc] init];
    while ([arrTemp count] < count) {
        int x = arc4random_uniform(count);
        NSString *xString = [NSString stringWithFormat:@"%d", x+1];
        if ([arrTemp containsObject:xString]) continue;
        else {
            [arrTemp addObject:xString];
        }
    }
    
    return arrTemp;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    arrQOrders = [self random:[self.db getCountOfTable]];
    nQuizIndex = 0;
    
    nRCnt = nGCnt = nYCnt = 0;
    
    selectedCellView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellback_yellow.png"]];
    greenCellView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellback_green.png"]];
    redCellView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellback_red.png"]];
    yellowCellView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellback_yellow.png"]];
    
    [self showNextQuestion];
}

- (void)showNextQuestion
{
    NSLog(@"QuizViewController showNextQuestion");
    
    tblAnswers.userInteractionEnabled = YES;

    lblIndex.hidden = NO;
    arrAOrders = [self random:5];
    int index = [[arrQOrders objectAtIndex:nQuizIndex] intValue];
    self.question = [self.db getRowById:index+1];

    BOOL hasNone = NO;

    for (int i = 0; i < 5; i++) {
        NSString *strAKey = [NSString stringWithFormat:@"Answer%@", [arrAOrders objectAtIndex:i]];
        NSString *strAnswer = [self.question objectForKey:strAKey];
        if ([strAnswer isEqualToString:@"None of the above"]) {
            NSString *strI = [arrAOrders objectAtIndex:i];
            NSString *strLast = [arrAOrders objectAtIndex:4];
            [arrAOrders removeObjectAtIndex:i];
            [arrAOrders insertObject:strLast atIndex:i];
            [arrAOrders removeObjectAtIndex:4];
            [arrAOrders insertObject:strI atIndex:4];
            hasNone = YES;
        }
    }

    for (int i = 0; i < 5; i++) {
        NSString *strAKey = [NSString stringWithFormat:@"Answer%@", [arrAOrders objectAtIndex:i]];
        NSString *strAnswer = [self.question objectForKey:strAKey];
        if ([strAnswer isEqualToString:@"All of the above"]) {
            NSString *strI = [arrAOrders objectAtIndex:i];
            if (hasNone == YES) {
                NSString *strLast = [arrAOrders objectAtIndex:3];
                [arrAOrders removeObjectAtIndex:i];
                [arrAOrders insertObject:strLast atIndex:i];
                [arrAOrders removeObjectAtIndex:3];
                [arrAOrders insertObject:strI atIndex:3];
            }
            else
            {
                NSString *strLast = [arrAOrders objectAtIndex:4];
                [arrAOrders removeObjectAtIndex:i];
                [arrAOrders insertObject:strLast atIndex:i];
                [arrAOrders removeObjectAtIndex:4];
                [arrAOrders insertObject:strI atIndex:4];
            }
        }
    }
    
    NSString *requestURL = [NSString stringWithFormat:@"http://www.hugostephenson.com/acem/phrm_pull.json?q=%@", [self.question objectForKey:@"QuestionID"]];
    NSLog(@"%@", requestURL);
    JSONReaderResponse *readResponse = [[JSONReaderResponse alloc] init];
    readResponse.delegate = self;
    readResponse.parserURL = requestURL;
    [readResponse parseJSONDataAtURL:[NSURL URLWithString:[requestURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    
    vwAlert.hidden = YES;
    vwNextQ.hidden = YES;
    vwTrack.hidden = NO;
    lblIndex.hidden = YES;
    
    lblGreen.text = [NSString stringWithFormat:@"%d", nGCnt];
    lblRed.text = [NSString stringWithFormat:@"%d", nRCnt];
    lblYellow.text = [NSString stringWithFormat:@"%d", nYCnt];
}

- (void)readDataFinished:(BOOL)isSuccess :(NSMutableDictionary *)aryAnswers
{
    NSLog(@"QuizViewController readDataFinished");
    
    int index = [[arrQOrders objectAtIndex:nQuizIndex] intValue];
    if (isSuccess) {
        NSString *strKey = [NSString stringWithFormat:@"%@", [self.question objectForKey:@"QuestionID"]];
        NSArray *tempAnswers = [aryAnswers objectForKey:strKey];
        for (int j = 0; j < [tempAnswers count]; j++) {
            NSString *strWKey = [NSString stringWithFormat:@"Weight%d", j + 1];
            int weight = [[tempAnswers objectAtIndex:j] intValue];
            [self.question setObject:[NSString stringWithFormat:@"%d", weight] forKey:strWKey];
        }
        [self.db saveQuestion:self.question ID:index+1];
    }
    
    lblIndex.text = [NSString stringWithFormat:@"%d of %d", nQuizIndex + 1, [self.db getCountOfTable]];
    
    NSString *strQuestion = (NSString *)[self.question objectForKey:@"Question"];
    
    if (![[strQuestion substringFromIndex:[strQuestion length] - 1] isEqualToString:@":"] && ![[strQuestion substringFromIndex:[strQuestion length] - 1] isEqualToString:@"?"]) {
        strQuestion = [NSString stringWithFormat:@"%@:", strQuestion];
    }
    
    lblQuestion.frame = CGRectMake(13, 52, 295, 0);
    lblQuestion.text = strQuestion;
    lblQuestion.numberOfLines = 0;
    [lblQuestion sizeToFit];
    
    vwScroll.frame = CGRectMake(vwScroll.frame.origin.x, lblQuestion.frame.origin.y + lblQuestion.frame.size.height + 15, vwScroll.frame.size.width, vwScroll.frame.size.height);
    vwScroll.contentSize = CGSizeMake(320, 325);
    
    isLoadAvailable = YES;

    [tblAnswers reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (isLoadAvailable) {
        return 5;
    }
    return 0;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CarTableCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"AnswerCell" owner:self options:nil];
        
		// [m_categoryCell.m_imgThumb.layer setCornerRadius:7];
        cell = cellAnswer;
		cellAnswer = nil;
		// cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    // Configure the cell...
	AnswerCell *ansCell = (AnswerCell *)cell;
    ansCell.selectedBackgroundView = selectedCellView;
    ansCell.backgroundView = nil;
    
    ansCell.selectionStyle = UITableViewCellSelectionStyleBlue;
    ansCell.accessoryType = UITableViewCellAccessoryNone;
    
    if (indexPath.row == 0) {
        ansCell.lblOrder.text = @"A.";
    }
    if (indexPath.row == 1) {
        ansCell.lblOrder.text = @"B.";
    }
    if (indexPath.row == 2) {
        ansCell.lblOrder.text = @"C.";
    }
    if (indexPath.row == 3) {
        ansCell.lblOrder.text = @"D.";
    }
    if (indexPath.row == 4) {
        ansCell.lblOrder.text = @"E.";
    }
    
    NSString *strAKey = [NSString stringWithFormat:@"Answer%@", [arrAOrders objectAtIndex:indexPath.row]];
    NSString *strAnswer = [self.question objectForKey:strAKey];
    if ([[strAnswer substringFromIndex:[strAnswer length] - 1] isEqualToString:@" "]) {
        strAnswer = [strAnswer substringFromIndex:1];
    }
    strAnswer = [NSString stringWithFormat:@"%@%@",[[strAnswer substringToIndex:1] uppercaseString], [strAnswer substringFromIndex:1]];
    ansCell.lblAnswer.text = strAnswer;
    ansCell.lblAnswer.numberOfLines = 0;
    [ansCell.lblAnswer sizeToFit];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    nSelectedAnswer = indexPath.row;
    
    vwAlert.hidden = NO;
    vwNextQ.hidden = YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 61;
}

- (BOOL)hasNumber:(NSArray *)aryNumbers :(int)num
{
    for (int i = 0; i < [aryNumbers count]; i++) {
        int temp = [[aryNumbers objectAtIndex:i] intValue];
        if (temp == num) {
            return YES;
        }
    }
    return NO;
}

- (void)checkMyAnswer
{
    tblAnswers.userInteractionEnabled = NO;

    int max = 0, maxIndex = 0, totalWeight = 0;
    for (int i = 0; i < 5; i++) {
        NSString *strOKey = [NSString stringWithFormat:@"Weight%@",[arrAOrders objectAtIndex:i]];
        int weight = [[self.question objectForKey:strOKey] intValue];
        if (weight > max) {
            max = weight; maxIndex = [[arrAOrders objectAtIndex:i] intValue];
        }
        totalWeight = totalWeight + weight;
    }
    
    NSMutableArray *arrHighest = [[NSMutableArray alloc] init];;
    
    for (int i = 0; i < 5; i++) {
        NSString *strOKey = [NSString stringWithFormat:@"Weight%@",[arrAOrders objectAtIndex:i]];
        int weight = [[self.question objectForKey:strOKey] intValue];
        if (weight == max) {
            [arrHighest addObject:[arrAOrders objectAtIndex:i]];
        }
    }
    
    int curIndex = [[arrAOrders objectAtIndex:nSelectedAnswer] intValue];
    
    
    for (int j = 0; j < 5; j++) {
        AnswerCell *cellTemp = (AnswerCell *)[tblAnswers cellForRowAtIndexPath:[NSIndexPath indexPathForRow:j inSection:0]];
        int totalWeight = 0;
        for (int i = 0; i < 5; i++) {
            NSString *strAKey = [NSString stringWithFormat:@"Weight%d", i + 1];
            int weight = [[self.question objectForKey:strAKey] intValue];
            totalWeight = totalWeight + weight;
        }
        
        int fifWeight = totalWeight / 5;
        
        NSString *strWKey = [NSString stringWithFormat:@"Weight%@", [arrAOrders objectAtIndex:j]];
        int weight = [[self.question objectForKey:strWKey] intValue];
        
        int frequency = weight == 0 || fifWeight == 0? 0 : weight / fifWeight;
        if (frequency > 4) {
            cellTemp.vwWeight5.hidden = NO;
        }
        
        if (frequency > 3) {
            cellTemp.vwWeight4.hidden = NO;
        }
        
        if (frequency > 2) {
            cellTemp.vwWeight3.hidden = NO;
        }
        
        if (frequency > 1) {
            cellTemp.vwWeight2.hidden = NO;
        }
        
        if (frequency > 0) {
            cellTemp.vwWeight1.hidden = NO;
        }
    }
    
    vwTrack.hidden = NO;
    lblIndex.hidden = YES;
    lblGreen.text = [NSString stringWithFormat:@"%d", nGCnt];
    lblRed.text = [NSString stringWithFormat:@"%d", nRCnt];
    lblYellow.text = [NSString stringWithFormat:@"%d", nYCnt];

    AnswerCell *cellA = (AnswerCell *)[tblAnswers cellForRowAtIndexPath:[NSIndexPath indexPathForRow:nSelectedAnswer inSection:0]];
    
    if (totalWeight < 5) {
        cellA.selectedBackgroundView = yellowCellView;
        [AudioPool stopSound];
        [AudioPool playSound:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"bump" ofType:@"wav"]] loop:0 delegate:nil];
        [AudioPool setVolume:1.0];
        nYCnt = nYCnt + 1;
        vwAlert.hidden = YES;
        vwNextQ.hidden = YES;
        [self onNext:nil];
    }
    else
    {
        if ([self hasNumber:arrHighest :curIndex]) {
            cellA.selectedBackgroundView = greenCellView;
            lblIndex.text = [NSString stringWithFormat:@"%d of %d Right!", nQuizIndex + 1, [self.db getCountOfTable]];
            [AudioPool stopSound];
            [AudioPool playSound:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"ding" ofType:@"wav"]] loop:0 delegate:nil];
            [AudioPool setVolume:1.0];
            nGCnt = nGCnt + 1;
        }
        else
        {
            cellA.selectedBackgroundView = redCellView;
            lblIndex.text = [NSString stringWithFormat:@"%d of %d Wrong!", nQuizIndex + 1, [self.db getCountOfTable]];
            [AudioPool stopSound];
            [AudioPool playSound:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"bump" ofType:@"wav"]] loop:0 delegate:nil];
            [AudioPool setVolume:1.0];
            nRCnt = nRCnt + 1;
        }
    }
}

- (IBAction)onGuess:(id)sender
{
    vwAlert.hidden = YES;
    vwNextQ.hidden = NO;
    [NSThread detachNewThreadSelector:@selector(increaseWeight:) toTarget:self withObject:@"G"];
    [self checkMyAnswer];
}

- (void)increaseWeight:(NSString *)strGuess
{
    int index = [[arrQOrders objectAtIndex:nQuizIndex] intValue];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:[self.db getRowById:index+1]];

//    NSString *requestURL = [NSString stringWithFormat:@"http://www.hugostephenson.com/acem/phrm_push.json?q=%@&r=%@&guess=%@", [dict objectForKey:@"QuestionID"], [arrAOrders objectAtIndex:nSelectedAnswer], strGuess];
//    NSData *reqData = [NSData dataWithContentsOfURL:[NSURL URLWithString:requestURL]];
//    NSLog(@"Response = %@", reqData);
}

- (IBAction)onSure:(id)sender
{
    vwAlert.hidden = YES;
    vwNextQ.hidden = NO;
    int index = [[arrQOrders objectAtIndex:nQuizIndex] intValue];
    int curIndex = [[arrAOrders objectAtIndex:nSelectedAnswer] intValue];
    NSString *strWKey = [NSString stringWithFormat:@"Weight%d", curIndex];
    int weight = [[self.question objectForKey:strWKey] intValue];
    [self.question setObject:[NSString stringWithFormat:@"%d", weight + 1] forKey:strWKey];
    [self.db saveQuestion:self.question ID:index+1];
    
    [NSThread detachNewThreadSelector:@selector(increaseWeight:) toTarget:self withObject:@"S"];

    [self checkMyAnswer];
}

- (IBAction)onNext:(id)sender
{
    nQuizIndex = nQuizIndex + 1;
    [self showNextQuestion];
}

- (IBAction)onQuit:(id)sender
{
    nRCnt = 0;
    nGCnt = 0;
    nYCnt = 0;
    lblGreen.text = [NSString stringWithFormat:@"%d", nGCnt];
    lblRed.text = [NSString stringWithFormat:@"%d", nRCnt];
    lblYellow.text = [NSString stringWithFormat:@"%d", nYCnt];
}

@end
