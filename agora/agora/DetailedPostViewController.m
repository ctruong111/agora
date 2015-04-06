//
//  DetailedPostViewController.m
//  agora
//
//  Created by Kalvin Loc on 3/19/15.
//  Copyright (c) 2015 Ethan. All rights reserved.
//

#import "DetailedPostViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "UILabel+FormattedText.h"

#import "UIColor+AGColors.h"
#import "UILabel+FormattedText.h"

#define post [self post]

@interface DetailedPostViewController ()

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *mainImageView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIButton *contactButton;

@property (weak, nonatomic) IBOutlet FBSDKProfilePictureView *FBSellerImageView;
@property (weak, nonatomic) IBOutlet UIButton *FBSellerNameButton;
@property (weak, nonatomic) IBOutlet UILabel *FBMutualFriendsLabel;

@property (weak, nonatomic) IBOutlet UITextView *descriptionTextField;

@property (weak, nonatomic) IBOutlet UICollectionView* collectionView;

@end

@implementation DetailedPostViewController

#pragma mark - view did load and helpers

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[self scrollView] setContentSize:[[UIScreen mainScreen] bounds].size];
    
    [[self mainImageView] setContentMode:UIViewContentModeScaleAspectFill];
    [[self mainImageView] setClipsToBounds:YES];
    [[self mainImageView] setImage:[post headerPhoto]];
    
    // configure title, description and price
    [[self titleLabel] setText:[post title]];
    [self setUpCategoryLabel];
    [[self priceLabel] setText:[@"$" stringByAppendingString:[[post price] stringValue]]];
    
    // configure description textField
    [[self descriptionTextField] setText:[post itemDescription]];
    
    [self setUpButtons];
    [self setUpFBSeller];
}

- (void)setUpCategoryLabel {
    //[[self categoryLabel] setText:[post category]];
    
    NSString * catText = [NSString stringWithFormat:@"%@ %@",@"⦁",[post category]];
    
    NSAttributedString * cat = [[NSAttributedString alloc]initWithString:catText];
    [[self categoryLabel] setAttributedText:cat];
    [self.categoryLabel setTextColor:[UIColor catColor:[post category]] range:NSMakeRange(0, 1)];
    
    
}

- (void)setUpButtons{
    CGColorRef buttonColor = [[UIColor indigoColor] CGColor];
    [[self shareButton] setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [[[self shareButton] layer] setBorderWidth:1.5f];
    [[[self shareButton] layer] setCornerRadius:4.0f];
    [[[self shareButton] layer] setBorderColor:buttonColor];
    
    [[self contactButton] setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [[self contactButton] setTitleColor:[UIColor grayColor] forState:UIControlStateSelected];
    [[[self contactButton] titleLabel] setFont:[UIFont fontWithName:@"Helvetica-Bold" size:15]];
    [[[self contactButton] layer] setBorderWidth:2.0f];
    [[[self contactButton] layer] setBackgroundColor:buttonColor];
    [[[self contactButton] layer] setCornerRadius:4.0f];
    [[[self contactButton] layer] setBorderColor:buttonColor];
}

- (void)setUpFBSeller{
    [[[self FBSellerImageView] layer] setCornerRadius:[[self FBSellerImageView] frame].size.height/2];
    [[[self FBSellerImageView] layer] setMasksToBounds:YES];
    [[[self FBSellerImageView] layer] setBorderWidth:0];
    
    [[self FBSellerNameButton] setTitle:@"" forState:UIControlStateNormal];
    [[self FBMutualFriendsLabel] setText:@""];

    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:[post creatorFacebookId] parameters:nil];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        if(!error){
            //NSString* college = [[[[result objectForKey:@"education"] objectAtIndex:2] objectForKey:@"school"] objectForKey:@"name"];
            //NSLog(@"College: %@", college);
            [[self FBSellerImageView] setProfileID:result[@"id"]];
            [[self FBSellerNameButton] setTitle:result[@"name"] forState:UIControlStateNormal];
        }else{
            NSLog(@"Error Grabing FB Data in Detail");
            // An error occurred, we need to handle the error
            // See: https://developers.facebook.com/docs/ios/errors
        }
    }];
    
    if(!([[post creatorFacebookId] isEqualToString:[[PFUser currentUser] objectForKey:@"facebookId"]])){
        FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:[post creatorFacebookId] parameters:@{@"fields": @"context.fields(mutual_friends)",} HTTPMethod:@"GET"];
        [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, NSDictionary* result, NSError *error) {
            NSString* mutualText = [NSString stringWithFormat:@"%@ mutual friends", result[@"context"][@"mutual_friends"][@"summary"][@"total_count"]];
            NSArray* mutualFriends = result[@"context"][@"mutual_friends"][@"data"];
            
            for(int i=0; i<[mutualFriends count]; i++){
                NSString* friendName = mutualFriends[i][@"name"];
                if(i == 0)
                    mutualText = [mutualText stringByAppendingFormat:@" including %@", friendName];
                else if(i == ([mutualFriends count]-1))
                    mutualText = [mutualText stringByAppendingFormat:@" and %@,", friendName];
                else
                    mutualText = [mutualText stringByAppendingFormat:@" %@,", friendName];
            }
            // Format: 8 mutual friends including xx, xx, and xx
            [[self FBMutualFriendsLabel] setText:mutualText];
        }];
    }else{
        // User is viewing their own post
        [[self FBMutualFriendsLabel] setText:@""];
        [[self contactButton] setEnabled:NO];
        [[[self contactButton] layer] setBackgroundColor:[[UIColor grayColor] CGColor]];
        [[[self contactButton] layer] setBorderColor:[[UIColor grayColor] CGColor]];
    }
}

#pragma mark - IB Actions

- (IBAction)clickedShare:(id)sender {
    // open share action sheet
}

- (IBAction)clickedContact:(id)sender {
    // open FB messager to user
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"fb-messenger://user-thread/%@", [post creatorFacebookId]]];
    if([[UIApplication sharedApplication] canOpenURL:url]){
        [[UIApplication sharedApplication] openURL:url];
    }else{
        // Did not install FB MSGER or misc error. What Do
    }
}

- (IBAction)clickedFBSellerName:(id)sender {
    // Open seller's facebook page
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"fb://profile/%@", [post creatorFacebookId]]];
    [[UIApplication sharedApplication] openURL:url];
    if([[UIApplication sharedApplication] canOpenURL:url]){
        [[UIApplication sharedApplication] openURL:url];
    }else{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.facebook.com/%@", [post creatorFacebookId]]]];
    }
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
