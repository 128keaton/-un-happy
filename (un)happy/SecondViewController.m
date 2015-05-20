//
//  SecondViewController.m
//  (un)happy
//
//  Created by Keaton Burleson on 5/19/15.
//  Copyright (c) 2015 Keaton Burleson. All rights reserved.
//

#import "SecondViewController.h"
#import "BEMSimpleLineGraphView.h"
#import <BEMSimpleLineGraph/BEMPermanentPopupView.h>
#import <QuartzCore/QuartzCore.h>
#import "MBProgressHUD.h"
@interface SecondViewController () <BEMSimpleLineGraphDelegate, BEMSimpleLineGraphDataSource,UIActionSheetDelegate, UIScrollViewDelegate>

@property (nonatomic)NSMutableArray *pointsArray;
@property (strong, nonatomic)UILabel *pointLabel;
@end

@implementation SecondViewController


- (NSInteger)numberOfPointsInLineGraph:(BEMSimpleLineGraphView *)graph {
    NSLog(@"%lu", (unsigned long)[self.pointsArray count]);

    
    return [self.pointsArray count]; // Number of points in the graph.
}


-(IBAction)initateAction:(id)sender{
    UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Clear all data" otherButtonTitles:
        @"Share Graph",
                        
                            nil];
    popup.tag = 1;
    [popup showInView:[UIApplication sharedApplication].keyWindow];
}
-(void)viewWillDisappear:(BOOL)animated{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:self.pointsArray.count forKey:@"count"];
    [defaults synchronize];
}
- (CGFloat)lineGraph:(BEMSimpleLineGraphView *)graph valueForPointAtIndex:(NSInteger)index {
    
    NSDictionary *itemDictionary = [[NSDictionary alloc]initWithDictionary:[_pointsArray objectAtIndex:index]];
    
    NSString *status = [itemDictionary objectForKey:@"status"];
    
    if ([status  isEqual: @"Unhappy"]) {
        return -5;
    }else if ([status isEqual:@"Happy"]){
        if(index == 0){
            return 0;
        }else{
              return 5;
        }
      
        
    }else if ([status isEqual:@"Neutral"]){
        return 0;
    }
       return 0;
}
- (void) lineGraphDidFinishDrawing:(BEMSimpleLineGraphView *)graph {
    self.view.userInteractionEnabled = YES;
}
-(void)beginSharing{

    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        UIImage *imageToShare = [_graphView graphSnapshotImage];
        
        NSArray *itemsToShare = @[imageToShare];
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:nil];
        activityVC.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact]; //or whichever you don't need
        [self presentViewController:activityVC animated:YES completion:nil];

        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
    }
- (NSString *)popUpSuffixForlineGraph:(BEMSimpleLineGraphView *)graph {
    return @"miles";
}

-(BEMSimpleLineGraphPopoverView *)popUpViewForLineGraph:(BEMSimpleLineGraphView *)graph{
    UIView *popover = (BEMSimpleLineGraphPopoverView *)[[UIView alloc]initWithFrame:CGRectMake(0, 0, 80, 30)];
    popover.backgroundColor = [UIColor whiteColor];
    popover.layer.cornerRadius = 3;
    popover.layer.masksToBounds = YES;
    
    _pointLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 80, 30)];
    _pointLabel.textColor = [UIColor blackColor];
   _pointLabel.textAlignment = NSTextAlignmentCenter;
    _pointLabel.center = popover.center;
    
       
    
    
        [popover addSubview:_pointLabel];
    return (BEMSimpleLineGraphPopoverView *)popover;
    
}

- (void)lineGraph:(BEMSimpleLineGraphView *)graph didTouchGraphWithClosestIndex:(NSInteger)index {
    
    NSDictionary *itemDictionary = [[NSDictionary alloc]initWithDictionary:[_pointsArray objectAtIndex:index]];
    
    if(index == 0){
       _pointLabel.text = @"Neutral";
    }else{
       
        _pointLabel.text = [NSString stringWithFormat:@"%@", [itemDictionary objectForKey:@"status"]];
    }
    
}
- (NSString *)lineGraph:(BEMSimpleLineGraphView *)graph labelOnXAxisForIndex:(NSInteger)index {
      NSDictionary *itemDictionary = [[NSDictionary alloc]initWithDictionary:[_pointsArray objectAtIndex:index]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateStyle = NSDateFormatterShortStyle;
    NSString *dateString = [dateFormatter stringFromDate:[itemDictionary objectForKey:@"date"]];
    
    return dateString;
}

- (void)viewDidLoad {
    float width;
    float height;
    
    [super viewDidLoad];
    self.pointsArray = [[NSMutableArray alloc]init];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if(![defaults floatForKey:@"width"]){
        width = self.view.bounds.size.width;

    }else{
                 width = [defaults floatForKey:@"width"];
    }
    height = self.view.bounds.size.height;
    [self configureView:width height:height];
    
    
   // _graphView = [[BEMSimpleLineGraphView alloc] initWithFrame:CGRectMake(0, 20, width , height - 100)];
    _graphView.delegate = self;
    
    _graphView.dataSource = self;
    _graphView.colorYaxisLabel = [UIColor whiteColor];
    _graphView.colorXaxisLabel = [UIColor whiteColor];
    // Enable and disable various graph properties and axis displays
    _graphView.enableTouchReport = YES;
    _graphView.enablePopUpReport = YES;
    _graphView.enableYAxisLabel = NO;
    _graphView.autoScaleYAxis = YES;
    _graphView.alwaysDisplayDots = NO;

    
    
    
    _graphView.enableBezierCurve = YES;
    _graphView.animationGraphEntranceTime = 1.0f;
    
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)clearAllData{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [_pointsArray removeAllObjects];
    [defaults removeObjectForKey:@"width"];
    [defaults setObject:_pointsArray forKey:@"points"];
    //Li'l hacky hacks
    [defaults setObject:[[NSDate date] dateByAddingTimeInterval: -86400.0] forKey:@"updated"];
    [defaults synchronize];
    [_graphView reloadGraph];
    
}

-(void)configureView:(float)width height:(float)height{
    [_graphView removeFromSuperview];
    _graphView = nil;
    _graphView = [[BEMSimpleLineGraphView alloc] initWithFrame:CGRectMake(0, 20, width , height - 150)];
    UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, height)];
    [scrollView removeFromSuperview];
    
    [self.view addSubview:scrollView];
    [scrollView setContentSize:CGSizeMake(width, height-150)];
    [scrollView setScrollEnabled:YES];
    self.view.userInteractionEnabled = YES;
    [scrollView addSubview:_graphView];
    
    
}
-(id)init{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNotification:)
                                                 name:@"Update"
                                               object:nil];
    return self;

}
-(void)receiveNotification:(NSNotification *) notification{
    if ([[notification name] isEqualToString:@"Update"]){
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    float width;
    float height;

        if(![defaults floatForKey:@"width"]){
            width = self.view.bounds.size.width;
            NSLog(@"Crap, well: %f", [defaults floatForKey:@"width"]);
        }else{
            
            width = [defaults floatForKey:@"width"]+100;
            NSLog(@"added a point");
        }
        
        
        [defaults setFloat:width forKey:@"width"];
        [defaults synchronize];
        height = self.view.bounds.size.height;
        [self configureView:width height:height];
    }
    
}

-(void)viewDidAppear:(BOOL)animated{
    if(self.pointsArray.count < 2){
        UIView *oopsView = [[UIView alloc]initWithFrame:self.view.frame];
        oopsView.backgroundColor = self.view.backgroundColor;
        UILabel *oopsLabel = [[UILabel alloc]initWithFrame:self.view.frame];
        oopsLabel.text = @"You need to add more data";
        oopsLabel.textColor = [UIColor whiteColor];
        oopsLabel.textAlignment = NSTextAlignmentCenter;
        oopsLabel.center = oopsView.center;
         [oopsView addSubview:oopsLabel];
        [self.view addSubview:oopsView];
       
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    self.pointsArray = [NSMutableArray arrayWithArray:[defaults objectForKey:@"points"]];

 [self.graphView reloadGraph];
  //  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
}
-(void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (popup.tag) {
        case 1: {
            switch (buttonIndex) {
                case 0:
                    [self clearAllData];
                    break;
                case 1:
                    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                    [self beginSharing];
                    break;
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
