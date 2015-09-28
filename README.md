# redis_page

[actionpack-page_caching](https://github.com/rails/actionpack-page_caching) 是将页面缓存到文件中，这样有两个缺点：

1. nginx web 服务器需要访问到 app 服务器生成的文件；
2. 多台 app 服务器都会生成自己的缓存文件，难以共享，NFS 等又不大稳定；

redis_page 改为将页面缓存至 redis，nginx 安装 redis 插件后即可直接使用。

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'redis_page'
```

And then execute:

    $ bundle

## Usage

### 0. Config

增加文件：`config/initializers/redis_page.rb`

```
require "redis"
RedisPage.configure do |config|
  # 通过访问 http://cache:ewHN84JZLyRurX@example.com:8081/products/1 来刷新缓存
  config.sweeper = { port: 8081, username: 'cache', password: 'ewHN84JZLyRurX' }
  config.redis = Redis.new(host: "redis", port: 6379, db: 10)
end
```

### 1. Controller

生成页面缓存

```
class ProductController < ActionController::Base
  caches_redis_page :show

  def show
    @product = Product.find(params[:id])
  end
end
```

### 2. View

记录哪些实体更新时要刷新的 url，例如：iPhone 在首页中显示了，则记录下 iPhone 实体与首页的关联关系

```
- Product.all.each do |product|
  = @product.title
```

修改为：

```
- Product.all.each do |product|
  = c(@product).title
```

c 方法会记录当前页面 url

### 3. Model

更新实体后刷新所有关联的页面缓存

```
class Product < ActiveRecord::Base
  include RedisPage::Sweeper
end
```

## Contribution

```
gem build redis_page.gemspec
gem push redis_page-0.1.0.gem
```
