//
//  ConversationVC.m
//  agora
//
//  Created by Ethan Gates on 4/17/15.
//  Copyright (c) 2015 Ethan. All rights reserved.
//

#import "ConversationVC.h"
#import "MessageView.h"
#import "Message.h"
#import "Conversation.h"
#import "UIColor+AGColors.h"
#import "ParseInterface.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>

#define SEND_VIEW_HEIGHT 44
#define SEND_BUTTON_WIDTH 50
#define MARGIN 6
#define FIELD_BUTTON_PADDING 9

#define KEYBOARD_SPEED 0.27

@interface ConversationVC() <UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>

@property NSMutableArray * messageViews;
@property NSArray * messages;

@property (weak, nonatomic) IBOutlet UITableView *tableview;

@property UIView * sendMsgView;
@property UITextField * sendMsgField;
@property UIButton * sendMsgButton;


@property CGFloat tableHeight;

@end

@implementation ConversationVC




#pragma mark - view life cycle methods

-(void) viewWillDisappear:(BOOL)animated {
        [super viewWillDisappear:animated];
        
        
}

-(void)viewDidLoad {
        [super viewDidLoad];
        
        FBSDKGraphRequest * request = [[FBSDKGraphRequest alloc]initWithGraphPath:[self.convo.recipient objectForKey:@"facebookId"] parameters:NULL];
        [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                if (!error) {
                        self.title = result[@"name"];
                        [self.tableview reloadData];
                }
        }];
        
        
        self.tableview.delegate = self;
        self.tableview.dataSource = self;
        
        //[self setupTextInputView];
        
        [self setupKeyboardAnimations];
        
        //[self loadMessages];
        
        [ParseInterface getMessagesOfConversation:self.convo completion:^(NSArray *result) {
                self.messages = result;
        }];
        
        for (int i = 0; i < self.messages.count; i++) {
                [self.messageViews addObject:[MessageView viewForMessage:(Message*)self.messages[i]]];
        }
        
        self.tableHeight = self.tableview.frame.size.height;
        
}

-(void)viewDidAppear:(BOOL)animated {
        [super viewDidAppear:animated];
        
        [self setupTextInputView];

        
        //CGSize s = [UIScreen mainScreen].bounds.size;
        //self.view.frame = CGRectMake(0, 0, s.width, s.height - 1);
        // the tableview for this vc was instantiated by the storyboard for the parent nav controller with the wrongg
        // frame.  It ends up being too tall by the height of a nav bar and just pushes it off screen.  obvi the nav bar
        // height should be subtracted, but when i do that, it suddenly instantiates with the correct frame and the
        // adjustment makes it too short.  somehow when you subtract 1 point it does it corretly, but the subtraction
        // is too small to see so id doesn't matter
        
        
        
        
}

#pragma mark - setup one time things

-(void) setupKeyboardAnimations {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(keyboardOnScreen:) name:UIKeyboardDidShowNotification object:nil];
}



-(void) setupTextInputView {
        CGRect r = self.view.frame;
        //NSLog(@"%@",self.view.description);
        
        // parent view setup
        self.sendMsgView = [[UIView alloc]initWithFrame:CGRectMake(0, r.size.height-SEND_VIEW_HEIGHT, self.view.frame.size.width, SEND_VIEW_HEIGHT)];
        [self.sendMsgView setBackgroundColor:[UIColor sendMsgGrey]];
        
        // text field setup
        self.sendMsgField = [[UITextField alloc]initWithFrame:CGRectMake(MARGIN, 7, r.size.width - 2*MARGIN - FIELD_BUTTON_PADDING - 50, 30)];
        [self.sendMsgField setBorderStyle:UITextBorderStyleRoundedRect];
        [self.sendMsgField setPlaceholder:@"Type a Message..."];
        [self.sendMsgField setBackgroundColor:[UIColor whiteColor]];
        [self.sendMsgField setDelegate:self];
        
        // send button setup
        self.sendMsgButton = [[UIButton alloc]initWithFrame:CGRectMake(self.sendMsgField.frame.size.width + MARGIN + FIELD_BUTTON_PADDING, 7, 50, 30)];
        
        [self.sendMsgView addSubview:self.sendMsgButton];
        [self.sendMsgView addSubview:self.sendMsgField];
        
        [self.view insertSubview:self.sendMsgView aboveSubview:self.tableview];
}

-(void) loadMessages {
        if (!self.messageViews) {
                self.messageViews = [[NSMutableArray alloc] init];
        }
        
        Message * firstMsg = [[Message alloc]init];
        firstMsg.chatMessage = @"Hey I'm interested in buying your raybans, setup a meet?";
        firstMsg.sentDate = [NSDate date];
        firstMsg.sender = [[PFUser currentUser] objectForKey:@"facebookId"];
        
        MessageView * firstView = [MessageView viewForMessage:firstMsg];
        [self.messageViews addObject:firstView];
        
        
        Message * second = [[Message alloc]init];
        second.chatMessage = @"yeah sure lets meet lantern tomorrow noon";
        firstMsg.sentDate = [NSDate date];
        second.sender = @"956635704369806";
        
        [self.messageViews addObject:[MessageView viewForMessage:second]];
        
        [self.messageViews addObject:[MessageView viewForMessage:second]];
        
        [self.messageViews addObject:[MessageView viewForMessage:second]];
        
        [self.messageViews addObject:[MessageView viewForMessage:second]];
        
        [self.messageViews addObject:[MessageView viewForMessage:second]];
        [self.messageViews addObject:[MessageView viewForMessage:second]];
        [self.messageViews addObject:[MessageView viewForMessage:second]];
        [self.messageViews addObject:[MessageView viewForMessage:second]];
        
}

#pragma mark - connections for keyboard

CGFloat previousHeight;
CGFloat defaultHeight;
-(IBAction)keyboardOnScreen:(NSNotification*) note {
        [self checkTableViewForHeight];
        NSDictionary *info  = note.userInfo;
        NSValue      *value = info[UIKeyboardFrameEndUserInfoKey];
        
        CGRect rawFrame      = [value CGRectValue];
        CGRect keyboardFrame = [self.view convertRect:rawFrame fromView:nil];
        CGFloat height = keyboardFrame.size.height;
        //NSLog(@"height: %f", height);
        
        
        
        [self animateFieldChange:previousHeight - height withDuration:0.0];
        previousHeight = height;
        defaultHeight = height;
        
}

-(void) checkTableViewForHeight {
        if (self.tableview.frame.size.height != self.tableHeight && self.tableHeight != 0) {
                CGRect oldFrame = self.tableview.frame;
                self.tableview.frame = CGRectMake(oldFrame.origin.x, oldFrame.origin.y, oldFrame.size.width, self.tableHeight);
        }
}

-(void) animateFieldChange:(CGFloat) changeHeight withDuration:(CGFloat) sec {
        
        NSLog(@"animate with change %f",changeHeight);
        [UIView animateWithDuration:sec animations:^{
                CGPoint old = self.sendMsgView.center;
                self.sendMsgView.center = CGPointMake(old.x, old.y + changeHeight);
                
                CGRect tableFrame = self.tableview.frame;
                self.tableview.frame = CGRectMake(tableFrame.origin.x, tableFrame.origin.y, tableFrame.size.width, tableFrame.size.height +changeHeight); // for status bar
                self.tableHeight = self.tableview.frame.size.height;
                CGRect newFrame = self.tableview.frame;
                NSLog(@"{%f %f, %f %f",newFrame.origin.x,newFrame.origin.y,newFrame.size.width,newFrame.size.height);
        } completion:^(BOOL finished) {
                NSIndexPath* path = [NSIndexPath indexPathForRow:self.messageViews.count-1 inSection:0];
                
                [self.tableview scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionTop animated:YES];

        }];
        
}

#pragma mark - Text field delegates

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
        [self animateFieldChange:-defaultHeight withDuration:KEYBOARD_SPEED];
        previousHeight = defaultHeight;
                return YES;
        // upon return tableview frame is correct
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
        [textField resignFirstResponder];
        [self animateFieldChange:previousHeight withDuration:KEYBOARD_SPEED];
        previousHeight = 0;

        return YES;
}

#pragma mark - Table View delegates

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
        return self.messageViews.count?self.messageViews.count:0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
        MessageView * msgView = (MessageView*)self.messageViews[indexPath.row];
        CGFloat height = msgView.frame.size.height + msgView.frame.origin.y*2.0;
        return height;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"message cell"];
        
        MessageView * msgView = (MessageView*)self.messageViews[indexPath.row];
        [cell.contentView addSubview:msgView];
        
        
        
        
        return cell;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
        return 1;
}



@end


























