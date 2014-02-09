

#import <UIKit/UIKit.h>

@class TBXML;

@interface LoginViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UINavigationControllerDelegate>
{
    NSMutableData *receivedData;
    NSMutableURLRequest *urlRequest;
//    TBXML *xml;
}

@property (strong, nonatomic) UITextField *nameField;
@property (strong, nonatomic) UITextField *pwdField;

/*保存用户信息*/
- (void)saveUserInfo;

@end

