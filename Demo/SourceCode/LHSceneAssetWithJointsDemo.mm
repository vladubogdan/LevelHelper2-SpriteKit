//
//  LHSceneAssetWithJointsDemo.m
//  SpriteKitAPI-DEVELOPMENT
//
//  Created by Bogdan Vladu on 16/05/14.
//  Copyright (c) 2014 VLADU BOGDAN DANIEL PFA. All rights reserved.
//

#import "LHSceneAssetWithJointsDemo.h"

@implementation LHSceneAssetWithJointsDemo

+(id)scene
{
    return [[self alloc] initWithContentOfFile:@"PUBLISH_FOLDER/simpleCar.lhplist"];
}

-(id)initWithContentOfFile:(NSString *)levelPlistFile{
    
    if(self = [super initWithContentOfFile:levelPlistFile])
    {
        /*INIT YOUR CONTENT HERE*/
        
        CGSize size = [self size];
        [LHSceneDemo createMultilineLabelAtPosition:CGPointMake(size.width*0.5, size.height - 150)
                                      asChildOfNode:[self uiNode]
                                           withText:@"CAR ASSETS DEMO\nAnother asset demo. This time demonstrating an asset containing joints.\n\nClick to create a new car of a random rotation."];
    }
    
    return self;
}

-(float)randomFloat:(float)Min max:(float)Max
{
    return ((arc4random()%RAND_MAX)/(RAND_MAX*1.0))*(Max-Min)+Min;
}

#if TARGET_OS_IPHONE

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    
   [self createAssetAtLocation:location];
    
    //dont forget to call super
    [super touchesBegan:touches withEvent:event];
}

#else
-(void)mouseDown:(NSEvent *)theEvent{
    
    CGPoint location = [theEvent locationInNode:self];
    [self createAssetAtLocation:location];
    
    [super mouseDown:theEvent];
}
#endif

-(void)createAssetAtLocation:(CGPoint)location{
    
    LHAsset* asset = [LHAsset createWithName:@"myNewAsset"
                               assetFileName:@"PUBLISH_FOLDER/carAsset.lhasset"
                                      parent:[self gameWorldNode]];
    
    asset.position = location;
    
    //NOTE: you should not scale nodes containig joints or nodes that are connected to joints.
    //The joints will break or will have strange behaviour..
    //The only way to use scale is to scale the node prior creating the joint - so from inside LevelHelper 2 app.
    
    float zRot = [self randomFloat:-60 max:60.0f];
    asset.zRotation = LH_DEGREES_TO_RADIANS(zRot);
}

@end
