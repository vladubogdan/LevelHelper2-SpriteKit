//
//  LHSceneCharacterAnimationDemo.m
//  SpriteKitAPI-DEVELOPMENT
//
//  Created by Bogdan Vladu on 16/05/14.
//  Copyright (c) 2014 VLADU BOGDAN DANIEL PFA. All rights reserved.
//

#import "LHSceneCharacterAnimationDemo.h"

@implementation LHSceneCharacterAnimationDemo

+(id)scene
{
    return [[self alloc] initWithContentOfFile:@"PUBLISH_FOLDER/characterAnimation.lhplist"];
}

-(id)initWithContentOfFile:(NSString *)levelPlistFile{
    
    if(self = [super initWithContentOfFile:levelPlistFile])
    {
        /*INIT YOUR CONTENT HERE*/
        

        CGSize size = [self size];
        [LHSceneDemo createMultilineLabelAtPosition:CGPointMake(size.width*0.5, size.height - 100)
                                      asChildOfNode:[self uiNode]
                                           withText:@"CHARACTER ANIMATION DEMO\nDemonstrate a character animation.\nThis demo also uses per device positioning.\nChange the device and run this demo again\nto see how the character is placed in a different position on each device.\nPer device positioning is mostly useful for User Interface elements,\nlike a life bar that you always want to be displayed in the top right corner.\n\nClick the left side of the screen to toggle play/pause.\nClick the right side of the screen\nto change to a new random animation.Walk animation only plays 2 times.\nWatch console for notifications like did finish animation or did finish repetition."];
        
    }
    
    return self;
}

-(void)didFinishedPlayingAnimation:(LHAnimation*)anim{
    
    NSLog(@"DID FINISH PLAYING ANIMATION %@", anim);
    
}
-(void)didFinishedRepetitionOnAnimation:(LHAnimation*)anim{
    
    NSLog(@"DID FINISH ANIMATION REPETITION %@", anim);
    
}

#if TARGET_OS_IPHONE

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];

    [self handleAnimationForLocation:location];

    [super touchesBegan:touches withEvent:event];
}

#else
-(void)mouseDown:(NSEvent *)theEvent{
    
    CGPoint location = [theEvent locationInNode:self];
    
    [self handleAnimationForLocation:location];
    
    [super mouseDown:theEvent];
}
#endif

-(void)handleAnimationForLocation:(CGPoint)location
{
    LHNode* officerNode = (LHNode*)[self childNodeWithName:@"Officer"];
    
    if(officerNode)
    {
        if(location.x > self.size.width*0.5)
        {
            NSArray* anims = [officerNode animations];
            int animIdx = arc4random() % [anims count];
            LHAnimation* anim = [anims objectAtIndex:animIdx];
            NSLog(@"Changing animation to %@.", [anim name]);
            [anim restart];
            [officerNode setActiveAnimation:anim];
        }
        else{
            
            LHAnimation* anim = [officerNode activeAnimation];
            [anim setAnimating:![anim animating]];
            NSLog(@"ANIMATION: %@ %@.", [anim animating] ? @"Playing" : @"Pausing", [anim name]);
        }
    }
}
@end
