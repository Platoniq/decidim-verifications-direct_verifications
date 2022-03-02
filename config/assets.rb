# frozen_string_literal: true

# This file is located at `config/assets.rb` of your module.

# Define the base path of your module. Please note that `Rails.root` may not be
# used because we are not inside the Rails environment when this file is loaded.
base_path = File.expand_path("..", __dir__)

# Register an additional load path for webpack. All the assets within these
# directories will be available for inclusion within the Decidim assets. For
# example, if you have `app/packs/src/decidim/foo.js`, you can include that file
# in your JavaScript entrypoints (or other JavaScript files within Decidim)
# using `import "src/decidim/foo"` after you have registered the additional path
# as follows.
Decidim::Webpacker.register_path("#{base_path}/app/packs")

# Register the entrypoints for your module. These entrypoints can be included
# within your application using `javascript_pack_tag` and if you include any
# SCSS files within the entrypoints, they become available for inclusion using
# `stylesheet_pack_tag`.
Decidim::Webpacker.register_entrypoints(
  decidim_direct_verifications: "#{base_path}/app/packs/entrypoints/decidim_direct_verifications.js",
  decidim_direct_verifications_css: "#{base_path}/app/packs/entrypoints/decidim_direct_verifications.scss"
)
