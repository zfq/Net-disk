
#import <UIKit/UIKit.h>
@class TBXML;

@interface RegisterViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>
{
    NSMutableData *receivedData;
    NSMutableURLRequest *urlRequest;
    TBXML *xml;
}

@property (strong, nonatomic) UITextField *nameField1;
@property (strong, nonatomic) UITextField *pwdField1;
@property (strong, nonatomic) UITextField *emailField;

@end
