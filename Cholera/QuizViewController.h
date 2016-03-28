//
//  QuizViewController.h
//  ACEM
//
//  Created by Pavel Poel on 12/23/13.
//  Copyright (c) 2013 DianWei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSONReaderResponse.h"
#import "Database.h"

@interface AnswerCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel      *lblOrder;
@property (strong, nonatomic) IBOutlet UILabel      *lblAnswer;
@property (strong, nonatomic) IBOutlet UIImageView  *vwWeight1;
@property (strong, nonatomic) IBOutlet UIImageView  *vwWeight2;
@property (strong, nonatomic) IBOutlet UIImageView  *vwWeight3;
@property (strong, nonatomic) IBOutlet UIImageView  *vwWeight4;
@property (strong, nonatomic) IBOutlet UIImageView  *vwWeight5;

@end

@interface QuizViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, JSONReaderResponseDelegate>
{
    IBOutlet UILabel            *lblIndex;
    IBOutlet UILabel            *lblQuestion;
    IBOutlet UITableView        *tblAnswers;
    IBOutlet AnswerCell         *cellAnswer;
    IBOutlet UIView             *vwNextQ;
    IBOutlet UIView             *vwAlert;
    IBOutlet UIScrollView       *vwScroll;
    NSMutableArray              *arrQOrders;
    NSMutableArray              *arrAOrders;
    int                         nQuizIndex;
    UIImageView                 *selectedCellView;
    UIImageView                 *greenCellView;
    UIImageView                 *redCellView;
    UIImageView                 *yellowCellView;
    int                         nSelectedAnswer;
    
    BOOL                        isLoadAvailable;
    
    int                         nRCnt, nGCnt, nYCnt;
    
    IBOutlet UIView             *vwTrack;
    IBOutlet UILabel            *lblRed, *lblGreen, *lblYellow;
}

@property (nonatomic, retain) Database *db;
@property (nonatomic, retain) NSMutableDictionary *question;

- (IBAction)onGuess:(id)sender;
- (IBAction)onSure:(id)sender;
- (IBAction)onNext:(id)sender;
- (IBAction)onQuit:(id)sender;

@end
