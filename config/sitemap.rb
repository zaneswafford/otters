# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = Rails.application.secrets.app_url

SitemapGenerator::Sitemap.create do
  Article.find_each do |article|
    add article_path(article), :lastmod => article.updated_at
  end
end

SitemapGenerator::Sitemap.ping_search_engines
