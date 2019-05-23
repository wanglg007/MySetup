#!/bin/bash
# (1)判断参数个数
if [ $# -le 1 ]; then
        echo "参数个数必须大于1..."
	exit 0
fi

# (2)设置常量参数
target=./
work_dir=work
uncompress_dir=uncompress
library_dir=BOOT-INF/lib

# (3)设置输入文件和输出文件参数
# (3.1)the name of the library that should be uncompressed
#library_name="spring-boot-starter-web-2.1.4.RELEASE.jar"
# (3.2)the obfuscated artifact
original_jar='springboot-kafka-storm-0.0.1-SNAPSHOT.jar'
# (3.3)the new obfuscated artifact (can be the same)
repacked_jar='springboot-kafka-storm-repack-0.0.1-SNAPSHOT.jar'

# (4)build the obfuscated library
mvn clean package -Dobfuscation

# (5)create working directory and copy obfuscated artifact
mkdir target/$work_dir
cp target/$original_jar target/$work_dir
cd target/$work_dir

# (6)extract contents of obfuscated artifact
jar xvf $original_jar
# (6.1)do not delete original file
#rm $original_jar

# (7)uncompress the target library and jar again without compression (c0)
##########Begin##########
# 若传入多个参数，将各个包进行解压即可
# 循环获取相应的参数，并对其进行解压
for param in $@
do
########Action########
echo "创建目录"$uncompress_dir
mkdir $uncompress_dir

#(7.1)将library_name赋值为参数，并将其移动到解压目录
library_name=$param
mv $library_dir/$library_name $uncompress_dir

#(7.2)进入解压目录，将Jar包进行解压；并删除原Jar包
cd $uncompress_dir
jar xvf $library_name
rm $library_name

#(7.3)将解压的内容重新打包,并将新Jar包拷贝到Lib目录
jar c0mf ./META-INF/MANIFEST.MF $library_name *
mv $library_name ../$library_dir
cd ..

#(7.4)删除加压的临时目录
rm -r $uncompress_dir
echo "删除目录"$uncompress_dir
echo "解压成功..."$library_name
########Action########
done

#删除servlet-api
rm -f $library_dir/servlet-api-2.5.jar
##########End  ##########

#(8) jar the complete obfuscated artifact again
#(8.1) it is important here to copy the manifest as otherwise the library would not be executeable any more by spring-boot
jar c0mf ./META-INF/MANIFEST.MF ../$repacked_jar *

#(9) cleanup work dir
cd ..
rm -r $work_dir

#(10)End
echo "解压成功......\n"
