# add our navigation tab
Deface::Override.new(:virtual_path => "spree/layouts/admin",
                     :name => "boards_admin_tab",
                     :insert_bottom => "[data-hook='admin_tabs']",
                     :text => "<%= tab(:boards, :icon => 'icon-file') %>",
                     :disabled => false)
