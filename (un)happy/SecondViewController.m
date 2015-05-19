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
@interface SecondViewController () <BEMSimpleLineGraphDelegate, BEMSimpleLineGraphDataSource,UIActionSheetDelegate>

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
-(void)viewWillDisappear:(BOOL)animated{
    NSLog(@"im melting");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSData* imageData = UIImagePNGRepresentation([self.graphView graphSnapshotImage]);
    NSData* myEncodedImageData = [NSKeyedArchiver archivedDataWithRootObject:imageData];
    
    [defaults setObject:myEncodedImageData forKey:@"bg"];
    [defaults synchronize];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.pointsArray = [[NSMutableArray alloc]init];
    float width = [ [ UIScreen mainScreen ] applicationFrame ].size.width;
    float height = [ [ UIScreen mainScreen ] applicationFrame ].size.height - 100;
    
    _graphView = [[BEMSimpleLineGraphView alloc] initWithFrame:CGRectMake(0, 100, width - 20, height - 100)];
    _graphView.delegate = self;
    _graphView.center = self.view.center;
    _graphView.dataSource = self;
    _graphView.colorYaxisLabel = [UIColor whiteColor];
    _graphView.colorXaxisLabel = [UIColor whiteColor];
    // Enable and disable various graph properties and axis displays
    _graphView.enableTouchReport = YES;
    _graphView.enablePopUpReport = YES;
    _graphView.enableYAxisLabel = NO;
    _graphView.autoScaleYAxis = YES;
    _graphView.alwaysDisplayDots = NO;

    
    [self.view addSubview:_graphView];
    
    _graphView.enableBezierCurve = YES;
    _graphView.animationGraphEntranceTime = 1.0f;
    
    // Do any additional setup after loading the view, typically from a nib.
}
-(void)clearAllData{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [_pointsArray removeAllObjects];
    [defaults setObject:_pointsArray forKey:@"points"];
    //Li'l hacky hacks
    [defaults setObject:[[NSDate date] dateByAddingTimeInterval: -86400.0] forKey:@"updated"];
    [defaults synchronize];
    [_graphView reloadGraph];
    
}
-(void)viewDidAppear:(BOOL)animated{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSData* imageData = UIImagePNGRepresentation([self.graphView graphSnapshotImage]);
    NSData* myEncodedImageData = [NSKeyedArchiver archivedDataWithRootObject:imageData];
    
    [defaults setObject:myEncodedImageData forKey:@"bg"];
    [defaults synchronize];

  //  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.pointsArray = [NSMutableArray arrayWithArray:[defaults objectForKey:@"points"]];
    self.view.userInteractionEnabled = false;
    
    [self.graphView reloadGraph];
    
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
