# hdselecter
仿京东地址选择

![a](http://ybz-1251448224.cossh.myqcloud.com/dir/hdselecter.gif)

## 导入方式:

### pod:
> pod hdselecter

### 或者
下载源代码，拖入hdselecter文件夹


## 使用方式

```
#import "HDSelecterViewController.h"

...

HDSelecterViewController *vc = [[HDSelecterViewController alloc]initWithDefualtProvince:self.defualtProvince city:self.defualtCity districts:self.defualtDistricts];
vc.title = @"请选择地址";
__weak typeof(self) weakSelf = self;
[vc setCompleteSelectBlock:^(NSString *province, NSString *city, NSString *districts) {
weakSelf.defualtProvince = province;
weakSelf.defualtCity = city;
weakSelf.defualtDistricts = districts;
NSLog(@"%@,%@,%@",province,city,districts);
[weakSelf dismissViewControllerAnimated:true completion:nil];
}];
[self presentViewController:vc animated:true completion:nil];

```
