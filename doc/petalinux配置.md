### 1.下载petalinux安装器

参考csdn博客：[petalinux下载](https://blog.csdn.net/sinat_15028281/article/details/120758985)

这里需下载对应vivado版本的petalinux，可以用MD5的形式查看

按如上教程下载后需要配置环境变量

### 2.环境变量配置

参考csdn博客：[petalinux实现zynq的linux程序开发](https://blog.csdn.net/weixin_43760266/article/details/123520322)

这里只需参考实现步骤中开发环境搭建部分内容以及petalinux安装部分的内容

### 3.在QEMU上运行

参考csdn博客：[petalinux使用](https://blog.csdn.net/xiang_shao344/article/details/83144126)

这里的hdf文件在2019.2以后的vivado版本应为xsa文件

配置过程中在导入xsa文件处可能出现以下错误：

![image-20240408234600746](C:\Users\gong\AppData\Roaming\Typora\typora-user-images\image-20240408234600746.png)

可能的解决方案是将终端窗口全屏化。如果不能解决可能是必要文件缺失，尝试运行以下指令：

```shell
sudo apt-get install libtinfo5
```

出现如下界面则文件导入成功：

![在这里插入图片描述](https://img-blog.csdnimg.cn/20210314170610456.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80NDg4MjU0Ng==,size_16,color_FFFFFF,t_70)

这里直接esc采用默认配置，相关具体配置有兴趣了解参考博客：[petalinux工程配置项详解](https://blog.csdn.net/weixin_44882546/article/details/114738341)