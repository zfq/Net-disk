//
//  CTAssetsViewController.m
//  Cloud
//
//  Created by zzti on 13-12-2.
//  Copyright (c) 2013年 zzti. All rights reserved.
//
#import "CTAssetsViewController.h"
#import "CTAssetsViewCell.h"
#import "CTAssetsPickerController.h"

#define IS_IOS7             ([[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] != NSOrderedAscending)
#define kThumbnailLength    78.0f
#define kThumbnailSize      CGSizeMake(kThumbnailLength, kThumbnailLength)
#define kPopoverContentSize CGSizeMake(320, 480)

#define kAssetsViewCellIdentifier           @"AssetsViewCellIdentifier"
#define kAssetsSupplementaryViewIdentifier  @"AssetsSupplementaryViewIdentifier"

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
#define IOS7_SDK_AVAILABLE 1
#endif

#pragma mark - CTAssetsSupplementaryView声明及实现部分

@interface CTAssetsSupplementaryView : UICollectionReusableView

@property (nonatomic, strong) UILabel *sectionLabel;

- (void)setNumberOfPhotos:(NSInteger)numberOfPhotos numberOfVideos:(NSInteger)numberOfVideos;

@end


@interface CTAssetsSupplementaryView ()

@end

@implementation CTAssetsSupplementaryView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        _sectionLabel               = [[UILabel alloc] initWithFrame:CGRectInset(self.bounds, 8.0, 8.0)];
        _sectionLabel.font          = [UIFont systemFontOfSize:18.0];
        _sectionLabel.textAlignment = NSTextAlignmentCenter;
        
        [self addSubview:_sectionLabel];
    }
    
    return self;
}

- (void)setNumberOfPhotos:(NSInteger)numberOfPhotos numberOfVideos:(NSInteger)numberOfVideos
{
    NSString *title;
    
    if (numberOfVideos == 0)
        title = [NSString stringWithFormat:@"%d张照片", numberOfPhotos];
    else if (numberOfPhotos == 0)
        title = [NSString stringWithFormat:@"%d个视频", numberOfVideos];
    else
        title = [NSString stringWithFormat:NSLocalizedString(@"%d Photos, %d Videos", nil), numberOfPhotos, numberOfVideos];
    
    self.sectionLabel.text = title;
}

@end

#pragma mark - CTAssetsViewController实现部分
@interface CTAssetsViewController ()

@property (nonatomic, strong) NSMutableArray *assets;
@property (nonatomic, assign) NSInteger numberOfPhotos;
@property (nonatomic, assign) NSInteger numberOfVideos;

@end

@implementation CTAssetsViewController
@synthesize assetItem;
@synthesize storePath;
@synthesize uploadBtn;
@synthesize pathBtn;
@synthesize numberOfSelected;
@synthesize catvcDelegate;
- (id)init
{
    UICollectionViewFlowLayout *layout  = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize                     = kThumbnailSize;
    layout.sectionInset                 = UIEdgeInsetsMake(9.0, 0, 0, 0);
    layout.minimumInteritemSpacing      = 2.0;
    layout.minimumLineSpacing           = 2.0;
    layout.footerReferenceSize          = CGSizeMake(0, 44.0);
    
    self.storePath = @"我的网盘";
    self.numberOfSelected = 0;
    self.uploadBtn.enabled = NO;
    
    
    if (self = [super initWithCollectionViewLayout:layout])
    {
        self.collectionView.allowsMultipleSelection = YES;
        
        [self.collectionView registerClass:[CTAssetsViewCell class]
                forCellWithReuseIdentifier:kAssetsViewCellIdentifier];
        
        [self.collectionView registerClass:[CTAssetsSupplementaryView class]
                forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                       withReuseIdentifier:kAssetsSupplementaryViewIdentifier];
    #if IOS7_SDK_AVAILABLE
        if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
            [self setEdgesForExtendedLayout:UIRectEdgeNone];
    #endif
        if ([self respondsToSelector:@selector(setContentSizeForViewInPopover:)])
            [self setContentSizeForViewInPopover:kPopoverContentSize];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupViews];
    [self setupButtons];
    [self addButtons];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setupAssets];
}

- (void)addButtons
{
    pathBtn = [[UIButton alloc] initWithFrame:CGRectMake(10.0, 22.0, 190, 35)];  
    pathBtn.backgroundColor = [UIColor clearColor];
    [pathBtn setBackgroundImage:[UIImage imageNamed:@"pathBtn.png"] forState:UIControlStateNormal];
    [pathBtn setTitle:self.storePath forState:UIControlStateNormal];
    [pathBtn setTitle:self.storePath forState:UIControlStateSelected];
    [pathBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    pathBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 30, 0, 30);
    
    uploadBtn = [[UIButton alloc] initWithFrame:CGRectMake(210, 22.0, 100, 35)];
    uploadBtn.backgroundColor = [UIColor clearColor];
    [uploadBtn setTitle:@"上传" forState:UIControlStateNormal];
    [uploadBtn setTitle:@"上传" forState:UIControlStateSelected];
    [uploadBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [uploadBtn setBackgroundImage:[UIImage imageNamed:@"uploadBtn.png"] forState:UIControlStateNormal];
    
    CGFloat tbY = 0;
//    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
        tbY = self.view.frame.size.height+self.view.frame.origin.y-44-20; //44+20 导航栏+状态栏
//    } else{
//        tbY = self.view.frame.size.height+self.view.frame.origin.y; //44+20 导航栏+状态栏
//    }
    
    UIView *tbbBcg = [[UIView alloc] initWithFrame:CGRectMake(0, tbY-60, 320, 64)];
    tbbBcg.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
    UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(9.0, 4.0, 110, 14)];
    lb.backgroundColor = [UIColor clearColor];
    lb.font = [UIFont systemFontOfSize:12.0];
    lb.textColor = [UIColor lightGrayColor];
    lb.text = @"选择上传路径";
    [tbbBcg addSubview:lb];
    
    [tbbBcg addSubview:uploadBtn];
    [tbbBcg addSubview:pathBtn];
    [self.view addSubview:tbbBcg];
    
    [pathBtn addTarget:self action:@selector(selelctpath:) forControlEvents:UIControlEventTouchUpInside];
    [uploadBtn addTarget:self action:@selector(upload:) forControlEvents:UIControlEventTouchUpInside];
}

- (NSInteger)numberOfSelected
{
    NSMutableArray *assets = [[NSMutableArray alloc] init];
    
    for (NSIndexPath *indexPath in self.collectionView.indexPathsForSelectedItems)
    {
        [assets addObject:[self.assets objectAtIndex:indexPath.item]];
    }
    
    return assets.count;
}

- (void)selelctpath:(id)sender
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    SelectPathViewController *spvc = [[SelectPathViewController alloc] initWithDirectoryAtPath:documentsDirectory];
    spvc.sDelegate = self;
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:spvc];
    nvc.delegate = self;
    [self.navigationController presentViewController:nvc animated:YES completion:nil];
    
}

- (void)upload:(id)sender  //点击上传
{
    if (self.numberOfSelected != 0) {
        self.uploadBtn.enabled = YES;
        [self finishPickingAssets:self];
        NSLog(@"点击上传");
    }
    [catvcDelegate tapUpload:self];
}
#pragma mark UINavigationController代理
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    SelectPathViewController *p =(SelectPathViewController *)viewController;
    p.sDelegate = self;
}
#pragma mark SelectPathViewController代理
- (void)cancelSelect:(SelectPathViewController *)spvc
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 修改路径的名字
- (void)selected:(SelectPathViewController *)spvc
{
    self.pathBtn.titleLabel.text = spvc.navTitle;
    self.storePath = spvc.currentPath; //保存所选择的路径
//    UIButton *btn = (UIButton *)sender;
//    btn.titleLabel.text = spvc.navTitle;
    [spvc.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Setup

- (void)setupViews
{
    self.collectionView.backgroundColor = [UIColor whiteColor];
}

- (void)setupButtons
{
    self.navigationItem.rightBarButtonItem =
    [[UIBarButtonItem alloc] initWithTitle:@"全选"
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(selectAllAssetItem:)];
}

- (void)setupAssets
{
    self.title = [self.assetsGroup valueForProperty:ALAssetsGroupPropertyName]; //获取照片集的名字
    if (!self.assets)
        self.assets = [[NSMutableArray alloc] init];
    else
        [self.assets removeAllObjects];
    
    ALAssetsGroupEnumerationResultsBlock resultsBlock = ^(ALAsset *asset, NSUInteger index, BOOL *stop) {
        
        if (asset)
        {
            [self.assets addObject:asset];
            
            NSString *type = [asset valueForProperty:ALAssetPropertyType];
            
            if ([type isEqual:ALAssetTypePhoto])
                self.numberOfPhotos ++;
            if ([type isEqual:ALAssetTypeVideo])
                self.numberOfVideos ++;
        }
        
        else if (self.assets.count > 0)
        {
            [self.collectionView reloadData];
            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.assets.count-1 inSection:0]
                                        atScrollPosition:UICollectionViewScrollPositionTop
                                                animated:YES];
        }
    };
    
    [self.assetsGroup enumerateAssetsUsingBlock:resultsBlock];
}


#pragma mark - Collection View Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.assets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = kAssetsViewCellIdentifier;
    
    CTAssetsViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    [cell bind:[self.assets objectAtIndex:indexPath.row]];
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    static NSString *viewIdentifiert = kAssetsSupplementaryViewIdentifier;
    
    CTAssetsSupplementaryView *view =
    [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:viewIdentifiert forIndexPath:indexPath];
    
    [view setNumberOfPhotos:self.numberOfPhotos numberOfVideos:self.numberOfVideos];
    
    return view;
}


#pragma mark - Collection View Delegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    CTAssetsPickerController *vc = (CTAssetsPickerController *)self.navigationController;
    
    return ([collectionView indexPathsForSelectedItems].count < vc.maximumNumberOfSelection);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self setTitleWithSelectedIndexPaths:collectionView.indexPathsForSelectedItems];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self setTitleWithSelectedIndexPaths:collectionView.indexPathsForSelectedItems];
}


#pragma mark - Title

- (void)setTitleWithSelectedIndexPaths:(NSArray *)indexPaths
{
    // Reset title to group name
    if (indexPaths.count == 0)
    {
        self.title = [self.assetsGroup valueForProperty:ALAssetsGroupPropertyName];
        return;
    }
    
    BOOL photosSelected = NO;
    BOOL videoSelected  = NO;
    
    for (NSIndexPath *indexPath in indexPaths)
    {
        ALAsset *asset = [self.assets objectAtIndex:indexPath.item];
        
        if ([[asset valueForProperty:ALAssetPropertyType] isEqual:ALAssetTypePhoto])
            photosSelected  = YES;
        
        if ([[asset valueForProperty:ALAssetPropertyType] isEqual:ALAssetTypeVideo])
            videoSelected   = YES;
        
        if (photosSelected && videoSelected)
            break;
    }
    
    NSString *format;
    
    if (photosSelected && videoSelected)
        format = @"已选择%d项";
    
    else if (photosSelected)
        format = (indexPaths.count > 0) ?  @"已选择%d张照片": @"";
    else if (videoSelected)
        format = (indexPaths.count > 0) ?  @"已选择%d个视频": @"";
    
    self.title = [NSString stringWithFormat:format, indexPaths.count];
}


#pragma mark - Actions
//   全选  还没实现
- (void)selectAllAssetItem:(id)sender
{
    //    self.assetItem.setSele;
    //    self.collectionView
    //    [self.assetItem.window setNeedsDisplay];
}

- (void)finishPickingAssets:(id)sender  //这个是点击上传时在upload:里面调用的
{
    NSMutableArray *assets = [[NSMutableArray alloc] init];
    
    for (NSIndexPath *indexPath in self.collectionView.indexPathsForSelectedItems)
    {
        [assets addObject:[self.assets objectAtIndex:indexPath.item]];
    }
    CTAssetsViewController *avc = sender;
    
    CTAssetsPickerController *picker = (CTAssetsPickerController *)self.navigationController;
    picker.storePath = avc.storePath; //目的是要把所选择的路径放在picker中，供代理对象uploadItemStore使用
    if ([picker.delegate respondsToSelector:@selector(assetsPickerController:didFinishPickingAssets:)])
        [picker.delegate assetsPickerController:picker didFinishPickingAssets:assets];
    
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

@end
