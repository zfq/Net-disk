//
//  SelectPathViewController.m
//  Cloud
//
//  Created by zhaofuqiang on 13-11-30.
//  Copyright (c) 2013年 zzti. All rights reserved.
//

#import "SelectPathViewController.h"
#import "MyFileItemStore.h"
#import "MainContentCell.h"
#import "MainContentItem.h"
@interface SelectPathViewController ()

@end

@implementation SelectPathViewController

@synthesize selectPathTableView;
@synthesize itemDictionaryStore;
@synthesize currentPath;
@synthesize itemSotre;
@synthesize newFolderBtn;
@synthesize navTitle;
@synthesize sDelegate = _sDelegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelSelect:)];
        self.navigationItem.rightBarButtonItem = rightButtonItem;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.selectPathTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
    [self.view addSubview:self.selectPathTableView];
    self.selectPathTableView.delegate = self;
    self.selectPathTableView.dataSource = self;
    [self setExtraCellLineHidden:self.selectPathTableView];
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    if ([self.currentPath isEqualToString:documentsDirectory]) {
        self.navigationItem.title = @"网盘"; //根据全部中选择可改为文档、图片 等等
    } else {
        self.navigationItem.title = self.navTitle;
    }

    UINib *nibMainContentCell = [UINib nibWithNibName:@"MainContentCell" bundle:nil];
    [self.selectPathTableView registerNib:nibMainContentCell forCellReuseIdentifier:@"MainContentCell"];
    [self addToolbar];
}

- (void)setExtraCellLineHidden:(UITableView *)tableView
{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    [self.selectPathTableView setTableFooterView:view];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addToolbar
{
    newFolderBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    newFolderBtn = [[UIButton alloc] initWithFrame:CGRectMake(10.0, 12.0, 190, 35)];
    newFolderBtn.backgroundColor = [UIColor blackColor];
    [newFolderBtn setBackgroundImage:[UIImage imageNamed:@"pathBtn.png"] forState:UIControlStateNormal];
   
    [newFolderBtn setTitle:@"新建文件夹" forState:UIControlStateNormal];
    [newFolderBtn setTitle:@"新建文件夹" forState:UIControlStateSelected];
    [newFolderBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    newFolderBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 30, 0, 30);
    
    UIButton *selectedBtn =  [[UIButton alloc] initWithFrame:CGRectMake(210, 12.0, 100, 35)];
    selectedBtn.backgroundColor = [UIColor whiteColor];
    [selectedBtn setTitle:@"选定" forState:UIControlStateNormal];
    [selectedBtn setTitle:@"选定" forState:UIControlStateSelected];
    [selectedBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [selectedBtn setBackgroundImage:[UIImage imageNamed:@"uploadBtn.png"] forState:UIControlStateNormal];
    
    CGFloat tbY = 0;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
        tbY = self.view.frame.size.height+self.view.frame.origin.y-44-20; //44+20 导航栏+状态栏
    } else{
        tbY = self.view.frame.size.height+self.view.frame.origin.y; //44+20 导航栏+状态栏
    }
    
    UIView *tbbBcg = [[UIView alloc] initWithFrame:CGRectMake(0, tbY-50, 320, 54)];
    tbbBcg.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
    
    [tbbBcg addSubview:newFolderBtn];
    [tbbBcg addSubview:selectedBtn];
    [self.view addSubview:tbbBcg];
    
    [newFolderBtn addTarget:self action:@selector(tapNewFolderBtn:) forControlEvents:UIControlEventTouchUpInside];
    [selectedBtn addTarget:self action:@selector(tapSelectedBtn:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)cancelSelect:(id)sender
{
    [_sDelegate cancelSelect:self];
}

- (void)tapNewFolderBtn:(id)sender
{
    
    if (!nfvc) {
        nfvc = [[NewFolderViewController alloc] init];
        nfvc.nDelegate = self;
    }
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:nfvc];
    [self.navigationController presentViewController:nvc animated:YES completion:nil];
}

- (void)tapSelectedBtn:(id)sender
{
    [_sDelegate selected:self];
    
}

- (SelectPathViewController *)initWithDirectoryAtPath:(NSString *)dirPath
{
    self = [super init];
    
    if (self) {
        self.itemSotre = [[MyFileItemStore alloc] init];
        self.itemDictionaryStore = [[NSMutableDictionary alloc] init];
        self.currentPath = dirPath;
        [self rebuildFileList:self.currentPath];
    }
    
    return self;
}

-(NSArray *)sortFilesByModDate: (NSString *)fullPath
{
    NSError* error = nil;
    NSArray* files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:fullPath
                                                                         error:&error];
    if(error == nil)
    {
        NSMutableDictionary* filesAndProperties = [NSMutableDictionary	dictionaryWithCapacity:[files count]];
        for(NSString* path in files)
        {
            NSDictionary* properties = [[NSFileManager defaultManager]
                                        attributesOfItemAtPath:[fullPath stringByAppendingPathComponent:path]
                                        error:&error];
            NSDate* modDate = [properties objectForKey:NSFileModificationDate];
            
            if(error == nil)
            {
                [filesAndProperties setValue:modDate forKey:path];
            }
        }
        
        return [filesAndProperties keysSortedByValueUsingSelector:@selector(compare:)];
        
    }
    
	return [NSArray arrayWithObjects:nil];
}

- (void)rebuildFileList:(NSString *)dirPath
{
    //获取这个路径里的所有文件，相当于文件名,allFiles要按创建日期排序
    NSArray *allFiles = [self sortFilesByModDate:dirPath];
    NSMutableArray *visibleFolders = [[NSMutableArray alloc] initWithCapacity:allFiles.count]; //分配指定大小的数组
    
    for (NSString *file in allFiles)
    {
        if (![file hasPrefix:@"."])
        { //如果不是隐藏文件，将文件名追加到当前路径path中
            NSString *fullPath = [[self currentPath] stringByAppendingPathComponent:file];
            
            BOOL isDir = NO;
            //判断当前文件或文件夹是否存在，返回值是isDir
            BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:fullPath isDirectory:&isDir];
            if (isExist)
            {
                //获取文件创建日期
                NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:fullPath error:nil];
                NSDate *date = [fileAttributes objectForKey:NSFileModificationDate];
                if (isDir)
                {
                    //MainContentItem保存某个文件的名称、路径
                    MainContentItem *item = [itemSotre createSingleFolderWithName:file date:date folderPath:fullPath isDir:YES];
                    [visibleFolders addObject:item];
                    [itemDictionaryStore setObject:item forKey:file]; //用临时的array将所有的PSDirectoryPickerEntry对象保存起来
                }
            }
            
        }
    }
    
    [self.itemSotre setAllItems:visibleFolders]; //将临时的array 赋给files,
}

- (void)newFolder:(id)sender
{
    if (!nfvc) {
        nfvc = [[NewFolderViewController alloc] init];
        nfvc.nDelegate = self;
    }
    
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:nfvc];
    [self.navigationController presentViewController:nvc animated:YES completion:nil];
}

#pragma mark NewFolderViewController代理
- (void)tapCancel:(NewFolderViewController *)newFolderViewController
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    nfvc = nil;
}

- (void)tapDone:(NewFolderViewController *)newFolderViewController
{
    static NSInteger i = 1;
    NSString *itemName = newFolderViewController.folderName.text;
    MainContentItem *tempItem = [self.itemDictionaryStore objectForKey:itemName];
    while (tempItem !=nil ) {
        itemName = [itemName stringByAppendingFormat:@"(%i)",i++];
        tempItem = [self.itemDictionaryStore objectForKey:itemName];
    }
    //尝试向服务器写入这个文件夹，如果写入成功，再往本地写入文件夹
    
    NSString *itemPath = [self.currentPath stringByAppendingPathComponent:itemName];
    
    NSDate *currentDate = [NSDate date];
    [[NSFileManager defaultManager] createDirectoryAtPath:itemPath withIntermediateDirectories:YES attributes:nil error:nil];
    
    MainContentItem *newItem = [itemSotre createFolderWithName:itemName date:currentDate folderPath:itemPath isDir:YES];
    
    NSInteger lastRow = [itemSotre.allItems indexOfObject:newItem];
    [self rebuildFileList:self.currentPath];
    
    NSIndexPath *ip = [NSIndexPath indexPathForRow:lastRow inSection:0];
    [self.selectPathTableView insertRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationLeft];
    [newFolderViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - tableViewDataSource代理
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    MainContentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MainContentCell"];
    
    MainContentItem *item = [itemSotre.allItems objectAtIndex:indexPath.row]; //最后一个添加不上去
    //cell的name应该是当前item的名字，
    cell.nameLabel.text = item.fileName;
    cell.thumbnailView.image = [UIImage imageNamed:@"folder32x32.png"];
    
    NSDate *currentDate = item.dateCreated;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm";
    cell.dateLabel.text = [dateFormatter stringFromDate:currentDate];
    return cell;
   
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = [itemSotre.allItems count];
    return count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*要能多选，必须设置下面两项，且setSelected为YES*/
    [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO animated:YES];
    [[tableView cellForRowAtIndexPath:indexPath] setSelectionStyle:UITableViewCellSelectionStyleBlue];
    
    MainContentItem *item = [self.itemSotre.allItems objectAtIndex:indexPath.row];

    SelectPathViewController *spvc = [[SelectPathViewController alloc] initWithDirectoryAtPath:item.currentFolderPath];
    spvc.navTitle = item.fileName;
    [self.navigationController pushViewController:spvc animated:YES];
}

@end
