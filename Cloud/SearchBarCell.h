//
//  SearchBarCell.h
//  Cloud
//
//  Created by zzti on 13-11-18.
//  Copyright (c) 2013年 zzti. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchBarCell : UITableViewCell
{
    __weak IBOutlet UIButton *_newFolderButton;
}

@property (nonatomic,weak) IBOutlet UISearchBar *searchBar;

- (UIButton *)newFolderButton;
@end
