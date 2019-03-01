require 'pathname'
dir = Pathname.new(__FILE__).parent
<%= @configs['ap_lib_loadpath'] %>

require 'rubygems'

require 'simplecov'
unless RUBY_VERSION =~ /^1\.8/
  require 'coveralls'
  SimpleCov.formatter = Coveralls::SimpleCov::Formatter
end
SimpleCov.start do
  add_group "Puppet Types", "/lib/puppet/type/"
  add_group "Puppet Providers", "/lib/puppet/provider/"

  add_filter "/spec/fixtures/"
  add_filter "/spec/unit/"
  add_filter "/spec/support/"
end

require 'puppetlabs_spec_helper/module_spec_helper'
require 'augeas_spec'

Puppet[:modulepath] = File.join(dir, 'fixtures', 'modules')

<% if @configs['ap_load_core'] -%>
# There's no real need to make this version dependent, but it helps find
# regressions in Puppet
#
# 1. Workaround for issue #16277 where default settings aren't initialised from
# a spec and so the libdir is never initialised (3.0.x)
# 2. Workaround for 2.7.20 that now only loads types for the current node
# environment (#13858) so Puppet[:modulepath] seems to get ignored
# 3. Workaround for 3.5 where context hasn't been configured yet,
# ticket https://tickets.puppetlabs.com/browse/MODULES-823
#
ver = Gem::Version.new(Puppet.version.split('-').first)
if ver >= Gem::Version.new("2.7.20")
    puts "augeasproviders: setting $LOAD_PATH to work around broken type autoloading"
    Puppet.initialize_settings
    $LOAD_PATH.unshift(
        dir,
        File.join(dir, 'fixtures/modules/augeasproviders_core/spec/lib'),
        File.join(dir, 'fixtures/modules/augeasproviders_core/lib')
    )

    <%= @configs['ap_load_workaround_extra'] -%>
<%- if @configs['puppet_core_modules'] -%>
if ver >= Gem::Version.new("6.0.0")
        $LOAD_PATH.unshift(
<% @configs['puppet_core_modules'].each do |mod| -%>
            File.join(dir, 'fixtures/modules/<%= mod %>/lib'),
<% end -%>
        )
    end
<%- end -%>

    $LOAD_PATH.unshift(File.join(dir, '..', 'lib'))
end

<% end -%>
# Load all shared contexts and shared examples
Dir["#{dir}/support/**/*.rb"].sort.each {|f| require f}
