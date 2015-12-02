# Configures the jekyll-everypolitician plugin to use the url in DATASOURCE
Jekyll::Hooks.register :site, :post_read do |site|
  site.config['everypolitician'] ||= {
    'sources' => [File.read('DATASOURCE').chomp]
  }
end

Jekyll::Hooks.register :site, :pre_render do |site, payload|
  sprockets = site.sprockets
  asset = sprockets.find_asset('person-210x210.jpg')
  asset_path = sprockets.prefix_path(sprockets.digest? ? asset.digest_path : asset.logical_path)
  site.collections['people'].docs.each do |person|
    person.data['image'] ||= asset_path
  end
end