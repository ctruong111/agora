//
//  DetailedPostViewController.m
//  agora
//
//  Created by Kalvin Loc on 3/19/15.
//  Copyright (c) 2015 Ethan. All rights reserved.
//

#import "DetailedPostViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface DetailedPostViewController ()
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *mainImageView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *catagoryLabel;

@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIButton *contactButton;

@property (weak, nonatomic) IBOutlet UIImageView *FBSellerImageView;
@property (weak, nonatomic) IBOutlet UIButton *FBSellerNameButton;
@property (weak, nonatomic) IBOutlet UILabel *FBMutalFriendsLabel;

@property (weak, nonatomic) IBOutlet UITextView *descriptionTextField;

@property (weak, nonatomic) IBOutlet UICollectionView* collectionView;

@end

@implementation DetailedPostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    Post * post = [ParseInterface getFromParseIndividual:@"FtLA9FwG75"];
    // Must add content to scrollView to scroll
    [[self scrollView] addSubview:[self contentView]];
    CGSize size = [self contentView].frame.size;
    //size.height = 1000;                           // set the end of the scroll view
    [[self scrollView] setContentSize:size];
    
    [[self mainImageView] setImage:[post photo]];
    
    // configure title and description
    [[self titleLabel] setText:[post title]];
    [[self catagoryLabel] setText:[post category]];
    
    // Configure buttons
    CGColorRef buttonColor = [[UIColor blueColor] CGColor];
    [[self shareButton] setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [[[self shareButton] layer] setBorderWidth:2.0f];
    [[[self shareButton] layer] setCornerRadius:4.0f];
    [[[self shareButton] layer] setBorderColor:buttonColor];
    
    [[self contactButton] setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [[self contactButton] setTitleColor:[UIColor grayColor] forState:UIControlStateSelected];
    [[[self contactButton] titleLabel] setFont:[UIFont fontWithName:@"Helvetica-Bold" size:15]];
    [[[self contactButton] layer] setBorderWidth:2.0f];
    [[[self contactButton] layer] setBackgroundColor:buttonColor];
    [[[self contactButton] layer] setCornerRadius:4.0f];
    [[[self contactButton] layer] setBorderColor:buttonColor];
    
    // configure FBSeller info
    //[[self FBSellerImageView] setImage:];
    [[self FBSellerNameButton] setTitle:@"" forState:UIControlStateNormal];
    [[self FBSellerNameButton] setTitle:@"" forState:UIControlStateSelected];
    //[[self FBMutalFriendsLabel] setText:[NSString stringWithFormat:<#(NSString *), ...#>]];
    
    // configure description textField
    [[self descriptionTextField] setText:[post itemDescription]];
}
- (IBAction)clickedShare:(id)sender {
    // open share action sheet
}
- (IBAction)clickedContact:(id)sender {
    // open FB messager to user
}
- (IBAction)clickedFBSellerName:(id)sender {
    // Open seller's facebook page
}

#pragma mark - Collection view data source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 0;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell* postCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"imageCell" forIndexPath:indexPath];
    
    return postCell;
}

@end
