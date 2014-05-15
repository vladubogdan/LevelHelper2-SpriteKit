//
//  ViewController.m
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 15/05/14.
//  Copyright (c) 2014 VLADU BOGDAN DANIEL PFA. All rights reserved.
//

#import "ViewController.h"
#import "MyScene.h"

#import "LevelHelper2API.h"

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Configure the view.
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
    
    [[LHConfig sharedInstance] enableDebug];
    
    // Create and configure the scene.
//    SKScene * scene = [LHScene sceneWithContentOfFile:@"levels/assetTestLevel.plist"];
//    SKScene * scene = [LHScene sceneWithContentOfFile:@"levels/cameraTest.plist"];
//    SKScene * scene = [LHScene sceneWithContentOfFile:@"levels/childrenAnimTest.plist"];
//    SKScene * scene = [LHScene sceneWithContentOfFile:@"levels/level01.plist"];
//    SKScene * scene = [LHScene sceneWithContentOfFile:@"levels/level02-beziers.plist"];
//    SKScene * scene = [LHScene sceneWithContentOfFile:@"levels/movementAnimationTest.plist"];
    SKScene * scene = [LHScene sceneWithContentOfFile:@"levels/officerLevel.plist"];
//    SKScene * scene = [LHScene sceneWithContentOfFile:@"levels/parallaxTest.plist"];
//    SKScene * scene = [LHScene sceneWithContentOfFile:@"levels/rectangleGravityArea.plist"];
    
    // Present the scene.
    [skView presentScene:scene];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

@end
