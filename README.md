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

### 1. Config

增加文件：`config/initializers/redis_page.rb`

```
require "redis"
RedisPage.configure do |config|
  # 通过访问 http://cache:ewHN84JZLyRurX@example.com:8081/products/1 来刷新缓存
  config.sweeper = { port: 8081, username: 'cache', password: 'ewHN84JZLyRurX' }
  config.redis = Redis.new(host: "redis", port: 6379, db: 10)
  config.ttl   = 604800    # 缓存 1 周后(默认)过期
end

Sidekiq.configure_server do |config|
  config.redis = { url: "redis://redis:6379/15" }
end

Sidekiq.configure_client do |config|
  config.redis = { url: "redis://redis:6379/15" }
end
```

### 2. Controller

生成页面缓存

```
class ProductController < ActionController::Base
  caches_redis_page :show                                            # 或者使用下面两行的格式
  #caches_redis_page :show, append_country: true                     # cache key 会在 path 后面加上国家代码，例如：/products-US
  #caches_redis_page :show, unless: Proc.new { params[:preview] }    # 带上 preview 参数，则不进行缓存，方便管理员对未保存的内容进行预览

  def show
    @product = Product.find(params[:id])
  end
end
```

### 3. View

记录哪些实体更新时要刷新的 url，例如：iPhone 在首页中显示了，则记录下 iPhone 实体与首页的关联关系

```
- Product.all.each do |product|
  = @product.title
```

修改为：

```
- c(Product).all.each do |product|
  = c(@product).title
```

c 方法会记录当前页面 url, c(Product) 表示添加、删除商品也会刷新当前页面

### 4. Model

更新、删除、添加实体后刷新所有关联的页面缓存

```
class Product < ActiveRecord::Base
  include RedisPage::Sweeper
end
```

### 5. Collection

删除子记录时要触发父记录更新

```
collection.products.delete product
```

在父记录的 model 关系中增加 after_remove，触发父记录更新

```
  has_many :products, through: :collections_products, after_remove: proc { |a| a.touch }
```

## Contribution

```
gem build redis_page.gemspec
gem push redis_page-0.1.1.gem
```
