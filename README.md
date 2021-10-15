# iOSVisionDemo
iOS Vision 框架

##### **Live Text**
iOS15 当中的 Live Text 功能目前只在 相册, 相机 APP 当中提供, 并没有发现开发可以使用的 API。



##### **Vision**

2017年 iOS11 开始支持的识别框架。

应用计算机视觉算法对输入图像和视频执行各种任务。

视觉框架执行人脸和人脸地标检测、文本检测、条形码识别、图像注册和一般特征跟踪。Vision还允许将自定义核心ML模型用于分类或对象检测等任务。



##### **Demo 相关效果**

原始图片

![image.png](https://i.loli.net/2021/10/15/BDYET3js2cWf81J.png)

##### **Vision 识别效果** 

一.  识别到 character 级别
![image.png](https://i.loli.net/2021/10/15/wNzpqlgJUZsrE5B.png)

二. 识别到 words 级别
![image.png](https://i.loli.net/2021/10/15/4QGcYwLUEPeWnkb.png)

三. iOS13 之后 Vision 支持 VNRecognizeTextRequest 文字识别
![image.png](https://i.loli.net/2021/10/15/Ne1zCWEoAu4ctlS.png)

识别结果

"Dropbox"

"最近使用"

"隔空投送"

"’ 应用程序"

"日桌面"

5

"---- 识别时长：593.3990478515625 毫秒"



##### **相关特点:**

1.  API 1 仅能识别是否有文字. 不能识别出文字到底是什么内容
2.  对中文识别结果不友好
3.  首次识别 200~600 ms 之间, 取决于图片本身的大小
4.  第二次识别时间很短, 猜测是系统做了相关缓存
5.  支持的语言

supportLanguage : [\"en-US\", \"fr-FR\", \"it-IT\", \"de-DE\", \"es-ES\", \"pt-BR\", \"zh-Hans\", \"zh-Hant\"]



##### **结论**

Vision 可以做图片上是否包含文字的判断功能, 和有限的文字内容识别功能
