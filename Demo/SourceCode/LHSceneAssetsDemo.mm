//
//  MyScene.m
//  SpriteKitAPI-DEVELOPMENT
//
//  Created by Bogdan Vladu on 16/05/14.
//  Copyright (c) 2014 VLADU BOGDAN DANIEL PFA. All rights reserved.
//

#import "LHSceneAssetsDemo.h"

@implementation LHSceneAssetsDemo

+(id)scene
{
    return [[self alloc] initWithContentOfFile:@"PUBLISH_FOLDER/assetsTest.lhplist"];
}

-(id)initWithContentOfFile:(NSString *)levelPlistFile{
    
    if(self = [super initWithContentOfFile:levelPlistFile])
    {
        /*INIT YOUR CONTENT HERE*/
        
        CGSize size = [self size];
        [LHSceneDemo createMultilineLabelAtPosition:CGPointMake(size.width*0.5, size.height - 150)
                                      asChildOfNode:[self uiNode]
                                           withText:@"ASSETS DEMO\nAssets are special objects that when edited they will change\nto the new edited state everywhere they are used in your project.\n\nClick to create a new officer (asset) of a random scale and rotation."];
    }
    
    return self;
}

float randomFloat(float Min, float Max){
    return ((arc4random()%RAND_MAX)/(RAND_MAX*1.0))*(Max-Min)+Min;
}

#if TARGET_OS_IPHONE

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:[self gameWorldNode]];
    
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

-(void)createAssetAtLocation:(CGPoint)location
{
    LHAsset* asset = [LHAsset createWithName:@"myNewAsset"
                               assetFileName:@"PUBLISH_FOLDER/OfficerAsset.lhasset"
                                      parent:[self gameWorldNode]];
    asset.position = location;
    
    asset.xScale = randomFloat(0.3, 0.6f);
    asset.yScale = randomFloat(0.3, 0.6f);
    
    float zRot = randomFloat(-45, 45.0f);
    
    asset.zRotation = LH_DEGREES_TO_RADIANS(zRot);
}

@end
