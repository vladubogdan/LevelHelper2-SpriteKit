//
//  LHSceneAdvancedPhysicsDemo.m
//  SpriteKitAPI-DEVELOPMENT
//
//  Created by Bogdan Vladu on 16/05/14.
//  Copyright (c) 2014 VLADU BOGDAN DANIEL PFA. All rights reserved.
//

#import "LHSceneAdvancedPhysicsDemo.h"

@implementation LHSceneAdvancedPhysicsDemo

+(id)scene
{
    return [[self alloc] initWithContentOfFile:@"PUBLISH_FOLDER/complexPhysicsShapes.lhplist"];
}

-(id)initWithContentOfFile:(NSString *)levelPlistFile{
    
    if(self = [super initWithContentOfFile:levelPlistFile])
    {
        /*INIT YOUR CONTENT HERE*/
        

        CGSize size = [self size];
        
        [LHSceneDemo createMultilineLabelAtPosition:CGPointMake(size.width*0.5, size.height - 150)
                                      asChildOfNode:[self uiNode]
                                           withText:@"Advanced Physics Shapes."];
        
    }
    
    return self;
}


#if LH_USE_BOX2D


//-(void)didBeginContact:(LHContactInfo *)contact
//{
//    NSLog(@"did BEGIN contact with info.............");
//    NSLog(@"NODE A: %@", [[contact nodeA] name]);
//    NSLog(@"NODE B: %@", [[contact nodeB] name]);
//    NSLog(@"NODE A SHAPE NAME: %@", [contact nodeAShapeName]);
//    NSLog(@"NODE B SHAPE NAME: %@", [contact nodeBShapeName]);
//    NSLog(@"NODE A SHAPE ID: %d", [contact nodeAShapeID]);
//    NSLog(@"NODE B SHAPE ID: %d", [contact nodeBShapeID]);
//    NSLog(@"CONTACT POINT: %f %f", [contact contactPoint].x, [contact contactPoint].y);
//    NSLog(@"IMPULSE %f", [contact impulse]);
//    NSLog(@"BOX2D CONTACT OBJ %p", [contact box2dContact]);
//    
//}
//
//-(void)didEndContact:(LHContactInfo *)contact
//{
//    NSLog(@"did END contact with info.............");
//    NSLog(@"NODE A: %@", [[contact nodeA] name]);
//    NSLog(@"NODE B: %@", [[contact nodeB] name]);
//    NSLog(@"NODE A SHAPE NAME: %@", [contact nodeAShapeName]);
//    NSLog(@"NODE B SHAPE NAME: %@", [contact nodeBShapeName]);
//    NSLog(@"NODE A SHAPE ID: %d", [contact nodeAShapeID]);
//    NSLog(@"NODE B SHAPE ID: %d", [contact nodeBShapeID]);
//    NSLog(@"CONTACT POINT: %f %f", [contact contactPoint].x, [contact contactPoint].y);
//    NSLog(@"IMPULSE %f", [contact impulse]);
//    NSLog(@"BOX2D CONTACT OBJ %p", [contact box2dContact]);
//    
//}

#else

//spritekit

#endif

@end
