require "aws-sdk-s3"

SitemapGenerator::Sitemap.default_host = "https://railsdevs.com"
SitemapGenerator::Sitemap.public_path = "tmp"
SitemapGenerator::Sitemap.sitemaps_host = Rails.configuration.sitemaps_host
SitemapGenerator::Sitemap.sitemaps_path = "sitemaps/"

if Rails.configuration.upload_sitemap
  SitemapGenerator::Sitemap.adapter = SitemapGenerator::AwsSdkAdapter.new(
    Rails.application.credentials.dig(:aws, :sitemaps_bucket),
    aws_access_key_id: Rails.application.credentials.dig(:aws, :access_key_id),
    aws_secret_access_key: Rails.application.credentials.dig(:aws, :secret_access_key),
    aws_region: Rails.application.credentials.dig(:aws, :region)
  )
end

SitemapGenerator::Sitemap.create do
  add root_path, changefreq: "always", priority: 1, lastmod: Developer.maximum(:updated_at)
  add developers_path, changefreq: "always", priority: 1, lastmod: Developer.maximum(:updated_at)
  add about_path, changefreq: "weekly", priority: 0.9

  Developer.most_recently_added.find_each do |developer|
    add developer_path(id: developer.id), changefreq: "always", priority: 0.8, lastmod: developer.updated_at
  end

  add new_user_session_path, changefreq: "weekly", priority: 0.7
  add new_user_registration_path, changefreq: "weekly", priority: 0.7
  add new_user_password_path, changefreq: "monthly", priority: 0.7
  add new_user_confirmation_path, changefreq: "monthly", priority: 0.7

  add new_role_path, changefreq: "weekly", priority: 0.6
  add pricing_path, changefreq: "weekly", priority: 0.5
end
