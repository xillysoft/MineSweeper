//
//  CellLocation.h
//  mine_sweeper
//
//  Created by 赵小健 on 2/28/16.
//  Copyright © 2016 赵小健. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CellLocation : NSObject
@property int row;
@property int column;
-(instancetype)init;
-(instancetype)initWithRow:(int)row column:(int)column;
@end

