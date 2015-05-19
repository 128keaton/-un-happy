//
//  FirstViewController.m
//  (un)happy
//
//  Created by Keaton Burleson on 5/19/15.
//  Copyright (c) 2015 Keaton Burleson. All rights reserved.
//

#import "FirstViewController.h"
#import "BEMSimpleLineGraphView.h"
#import "SecondViewController.h"
#import <QuartzCore/QuartzCore.h>
@interface FirstViewController (){
    IBOutlet UIImageView *imageBG;
    IBOutlet UIButton *yesButton;
    IBOutlet UIButton *noButton;
    IBOutlet UIButton *mootButton;
}

@end

@implementation FirstViewController
-(void)viewDidAppear:(BOOL)animated{
    
     NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDate *updatedDate = [defaults objectForKey:@"updated"];
    if([self daysBetweenDate:updatedDate andDate:[NSDate date]] == 1){
        yesButton.enabled = true;
        mootButton.enabled = true;
        noButton.enabled = true;
        
    }else{
        NSLog(@"No way Josè");
        
    }
    
}
-(IBAction)refresh:(id)sender{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDate *updatedDate = [defaults objectForKey:@"updated"];
    if([self daysBetweenDate:updatedDate andDate:[NSDate date]] == 1){
        yesButton.enabled = true;
        mootButton.enabled = true;
        noButton.enabled = true;
        
    }else{
        NSLog(@"No way Josè");
        
    }

}

- (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime
{
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate
                 interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate
                 interval:NULL forDate:toDateTime];
    
    NSDateComponents *difference = [calendar components:NSCalendarUnitDay
                                               fromDate:fromDate toDate:toDate options:0];
    
    return [difference day];
}

-(IBAction)addPointHappy:(id)sender{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    NSMutableArray *pointsArray = [[NSMutableArray alloc]initWithArray:[defaults objectForKey:@"points"]];
    
    NSDictionary *itemDictionary = [[NSDictionary alloc]initWithObjectsAndKeys:@"Happy", @"status", [NSDate date], @"date", nil];
    [pointsArray addObject:itemDictionary];
    
    [defaults setObject:pointsArray forKey:@"points"];       
      [self setTime];
       [defaults synchronize];
    
}
-(IBAction)addPointUnHappy:(id)sender{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableArray *pointsArray = [[NSMutableArray alloc]initWithArray:[defaults objectForKey:@"points"]];
    NSDictionary *itemDictionary = [[NSDictionary alloc]initWithObjectsAndKeys:@"Unhappy", @"status", [NSDate date], @"date", nil];
    [pointsArray addObject:itemDictionary];
      [self setTime];
    [defaults setObject:pointsArray forKey:@"points"];
    [defaults synchronize];
    
}
-(IBAction)addPointNeutral:(id)sender{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableArray *pointsArray = [[NSMutableArray alloc]initWithArray:[defaults objectForKey:@"points"]];
    NSDictionary *itemDictionary = [[NSDictionary alloc]initWithObjectsAndKeys:@"Neutral", @"status", [NSDate date], @"date", nil];
    [pointsArray addObject:itemDictionary];
    [defaults setObject:pointsArray forKey:@"points"];
    [self setTime];
    [defaults synchronize];
    
}

-(void)setTime{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSDate date] forKey:@"updated"];
    [defaults synchronize];
    yesButton.enabled = false;
    mootButton.enabled = false;
    noButton.enabled = false;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
     
  
    
    UIBezierPath *maskPathYesButton = [UIBezierPath bezierPathWithRoundedRect:yesButton.bounds
                                                   byRoundingCorners:(UIRectCornerBottomLeft|UIRectCornerTopLeft)

                                                        cornerRadii:CGSizeMake(5.0, 5.0)];
    
    // Create the shape layer and set its path
    CAShapeLayer *maskLayerYesButton = [CAShapeLayer layer];
    maskLayerYesButton.frame = yesButton.bounds;
    maskLayerYesButton.path = maskPathYesButton.CGPath;
    
    // Set the newly created shape layer as the mask for the image view's layer
    yesButton.layer.mask = maskLayerYesButton;
    
    UIBezierPath *maskPathNoButton = [UIBezierPath bezierPathWithRoundedRect:noButton.bounds
                                                            byRoundingCorners:(UIRectCornerBottomRight|UIRectCornerTopRight)
                                       
                                                                  cornerRadii:CGSizeMake(5.0, 5.0)];
    
    // Create the shape layer and set its path
    CAShapeLayer *maskLayerNoButton = [CAShapeLayer layer];
    maskLayerNoButton.frame = noButton.bounds;
    maskLayerNoButton.path = maskPathNoButton.CGPath;
    
    // Set the newly created shape layer as the mask for the image view's layer
    noButton.layer.mask = maskLayerNoButton;
   
    
   
   
    
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
