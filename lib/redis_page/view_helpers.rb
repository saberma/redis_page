module RedisPage
  module ViewHelpers
    # 记录当前实体相关的页面，方便实体更新时，刷新页面缓存
    def c(object_or_clazz)
      if @page_need_to_cache
        object_or_clazz.is_a?(Class) ? mark_cache_clazz(object_or_clazz) : mark_cache_instance(object_or_clazz)
      end
      object_or_clazz
    end

    # 记录当前实体相关的页面，方便实体更新时，刷新页面缓存
    # @params
    # 1. object 直接传递实体对象
    # 2. name, id 或者传递实体表名及id
    def mark_cache_instance(*array)
      name, id = array
      object   = array.first
      if id
        name = name.downcase
      else
        name = object.class.table_name.downcase
        id   = object.id
      end
      Rails.logger.info "[page cache]record: #{name}##{id}"
      RedisPage.redis.sadd("i:#{name}:#{id}", { url: request.url, country: @cache_country }.to_json)
    end

    # 记录类相关的页面，方便实体创建时，刷新页面缓存
    def mark_cache_clazz(clazz)
      name = clazz.table_name
      Rails.logger.info "[page cache]class: #{name}"
      RedisPage.redis.sadd("c:#{name}", { url: request.url, country: @cache_country }.to_json)
    end

  end
end
