# add our navigation tab
Deface::Override.new(:virtual_path => "spree/admin/shared/_menu",
                     :name => "boards_admin_tab",
                     :insert_bottom => "[data-hook='admin_tabs']",
                     :text => "<%= tab(:boards, :icon => 'icon-file') %>",
                     :disabled => false)
Deface::Override.new(:virtual_path => "spree/admin/shared/_menu",
                    :name => "registrations_admin_tab",
                    :insert_bottom => "[data-hook='admin_tabs']",
                    :text => "<%= tab(:designer_registrations, :icon => 'icon-file') %>",
                    :disabled => false)
