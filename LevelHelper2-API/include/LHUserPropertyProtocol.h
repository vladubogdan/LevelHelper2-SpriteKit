//
//  LHUserPropertyProtocol.h
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 29/04/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LHUserPropertyProtocol <NSObject>

@required
////////////////////////////////////////////////////////////////////////////////

+(id) customClassInstanceWithNode:(id)node;
-(NSString*) className;
-(id) node;
-(void) setPropertiesFromDictionary:(NSDictionary*)dictionary;


@end
