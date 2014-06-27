//
//  MyScene.m
//  SpriteKitAPI-DEVELOPMENT
//
//  Created by Bogdan Vladu on 16/05/14.
//  Copyright (c) 2014 VLADU BOGDAN DANIEL PFA. All rights reserved.
//

#import "LHSceneRopeJointDemo.h"

@implementation LHSceneRopeJointDemo

+(id)scene
{
    return [[self alloc] initWithContentOfFile:@"DEMO_PUBLISH_FOLDER/ropeJointTest.plist"];
}

-(id)initWithContentOfFile:(NSString *)levelPlistFile{
    
    if(self = [super initWithContentOfFile:levelPlistFile])
    {
        /*INIT YOUR CONTENT HERE*/
        

        CGSize size = [[self scene] size];
        
        SKLabelNode* label = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
        [label setName:@"InfoLabel"];
        [label setFontSize:16];
        [label setZPosition:60];
        [label setText:@"Rope Joint Test"];
        [label setFontColor:[SKColor magentaColor]];
        [label setColor:[SKColor whiteColor]];
        [label setPosition:CGPointMake(size.width*0.5, size.height-50)];
        [label setVerticalAlignmentMode:SKLabelVerticalAlignmentModeCenter];
        [label setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeCenter];
        [[self uiNode] addChild:label];
        
        float txtOffset = 70;
        {
            SKLabelNode* labelLine = [label copy];
            [labelLine setText:@"This test demonstrate rope joints."];
            [labelLine setPosition:CGPointMake(size.width*0.5, size.height-txtOffset)];
            [[self uiNode] addChild:labelLine];
            txtOffset += 20;
        }
        
        {
            SKLabelNode* labelLine = [label copy];
            [labelLine setText:@"Draw a line over the joint on the right side to cut it. Click to flip gravity."];
            [labelLine setPosition:CGPointMake(size.width*0.5, size.height-txtOffset)];
            [[self uiNode] addChild:labelLine];
            txtOffset += 20;
        }

        {
            SKLabelNode* labelLine = [label copy];
            [labelLine setText:@"The rope on the left side is setup so that you cannot cut it."];
            [labelLine setPosition:CGPointMake(size.width*0.5, size.height-txtOffset)];
            [[self uiNode] addChild:labelLine];
            txtOffset += 20;
        }
        {
            SKLabelNode* labelLine = [label copy];
            [labelLine setText:@"You can also control the z order of the joint drawing. Left rop joint is draw on top."];
            [labelLine setPosition:CGPointMake(size.width*0.5, size.height-txtOffset)];
            [[self uiNode] addChild:labelLine];
        }
        
    }
    
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
//    CGPoint gravity = [self globalGravity];
//    NSLog(@"Changing gravity direction %f %f.", gravity.x, gravity.y);
//    [self setGlobalGravity:CGPointMake(gravity.x, -gravity.y)];
    
    //dont forget to call super
    [super touchesBegan:touches withEvent:event];
}
@end
