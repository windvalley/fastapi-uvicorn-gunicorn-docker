项目说明
=======

## 文件结构说明

- Dockerfile    
    默认使用`Python3.8`作为基础镜像.
- app/main.py    
    项目的示例入口模块.
- app/prestart.sh    
    项目的示例预执行脚本, 在启动`fastapi`前执行的脚本.
- gunicorn_conf.py    
    `gunicorn`的配置文件, 使用将在下面介绍的环境变量进行配置, 并设置有默认值.
- start.sh    
    容器默认的启动命令, 用于生产环境.
- start-reload.sh    
    用于在开发环境下启动容器, 只会运行`uvicorn`, 不会启动`gunicorn`,    
    `gunicorn_conf.py`文件不起作用, 不过将在下面说明的环境变量都有效.

## 启动容器时可设置的环境变量说明

```
# Gunicorn要导入的python模块名称;
# 值为main对应容器内目录结构是/app/main.py;
# 值为app.main则对应容器内目录结构为/app/app/main.py
MODULE_NAME="main"

# 项目代码入口文件main.py中的FastAPI实例的名称.
VARIABLE_NAME="app"

# 值默认是MODULE_NAME:VARIABLE_NAME, 可以根据实际情况自定义,
# 自定义值后会忽略MODULE_NAME和VARIABLE_NAME变量.
APP_MODULE="main:app"

# 宿主机每个CPU开启几个worker, 默认是1, 如果宿主机只有一个cpu, 则将开启2个worker;
# 也可以自定义为浮点数, 比如0.5, 此时如果宿主机是4核cpu, 则只会开启2个worker.
WORKERS_PER_CORE="1"

# 这个变量值默认为WORKERS_PER_CORE变量值*宿主机cpu核数;
# 我们可以自定义这个变量值来定义一共开启多少个worker,
# 此时将忽略宿主机有多少核和WORKERS_PER_CORE变量.
WEB_CONCURRENCY=None

# 容器中Gunicorn监听的地址, 默认为0.0.0.0, 一般不用改.
HOST="0.0.0.0"

# 容器中Gunicorn监听的端口, 默认为80, 一般不用改.
PORT="80"

# 容器中Gunicorn监听的地址和端口, 默认值是HOST:PORT, 自定义后将忽略HOST和PORT变量的设置.
BIND="0.0.0.0:80"

# Gunicorn的日志等级, 默认是info, 全部等级依次为: debug info warning error critical
LOG_LEVEL="info"

# fastapi项目的预启动脚本的位置, 默认为容器中的/app/prestart.sh
PRE_START_PATH="/app/prestart.sh"

# 指定Gunicorn的配置文件, 如果不指定,
# 默认依次查找/app/gunicorn_conf.py、/app/app/gunicorn_conf.py、/gunicorn_conf.py(默认位置)
GUNICORN_CONF="/app/your_custom_gunicorn_conf.py"
```

环境变量使用方式举例:

`docker run -d --name container_name -p80:80 -e WEB_CONCURRENCY="2" image_name`


使用说明
=======

## 构建基础镜像

```bash
docker build -t fastapi:python3.8 .
docker images
```

## 基于基础镜像构建项目镜像

### 创建并进入到项目目录
```bash
mkdir opsapi && cd opsapi
```

### 创建项目的Dockerfile
```bash
cat > Dockerfile <<-EOF
    FROM fastapi:python3.8
    COPY ./app /app
EOF
```

### 创建项目源代码目录
```bash
mkdir app
```

### 将fastapi项目代码放到app目录下

如果不放置项目代码, `/app`下将是基础镜像提供的示例文件`main.py`和`prestart.sh`;

你的项目代码中的入口文件和预启动文件建议保持main.py和prestart.sh的文件命名,
否则你在启动容器时需要`-e`参数设置相关的环境变量.

### 构建项目镜像

```bash
docker build -t opsapi:0.1 .
docker images
```


## 运行容器

### 生产环境下运行容器

```bash
docker run -d --name opsapi -p80:80 -e WEB_CONCURRENCY="6" opsapi:0.1
```

### 开发环境下运行容器

```bash
docker run -d --name opsapi -p80:80 -e LOG_LEVEL="debug" -v $PWD/app:/app opsapi:0.1 /start-reload.sh
```

## 测试

浏览器分别访问:

```
localhost

localhost/docs

localhost/redoc
```


参考
===

https://github.com/tiangolo/uvicorn-gunicorn-docker

https://github.com/tiangolo/uvicorn-gunicorn-fastapi-docker
