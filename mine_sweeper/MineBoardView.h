//
//  MineBoardView.h
//  mine_sweeper
//
//  Created by 赵小健 on 2/24/16.
//  Copyright © 2016 赵小健. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MineBoard.h"

@interface MineBoardView : UIView
- (void)setMineBoard:(MineBoard *)mineBoard;
- (MineBoard *)mineBoard;
@end
